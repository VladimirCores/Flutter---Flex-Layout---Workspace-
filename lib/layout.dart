import 'dart:math';

import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/cell_header.dart';
import 'package:workspace_layout/cell/layout_cell.dart';
import 'package:workspace_layout/consts/enums.dart';
import 'package:workspace_layout/handler.dart';
import 'package:workspace_layout/regions.dart';

class LayoutHandleParams {
  final ValueNotifier<double> resizer;
  final double parentSize;
  final double size;
  final bool isHorizontal;

  LayoutHandleParams(this.resizer, this.parentSize, this.size, this.isHorizontal);
}

class LayoutCellParams {
  final LayoutCell cell;
  final double parentWidth;
  final double parentHeight;

  final LayoutHandleParams handleParams;

  LayoutCellParams(
    this.cell,
    this.parentWidth,
    this.parentHeight,
    this.handleParams,
  );
}

class Layout {
  Layout();

  int xCount = 0;
  int yCount = 0;

  final ValueNotifier<List<LayoutCell>> _items = ValueNotifier([]);

  final ValueNotifier<LayoutCell?> selectedCell = ValueNotifier(null);
  final ValueNotifier<({LayoutCell? cell, CellRegionSide? side})?> selectedCellRegionSide = ValueNotifier(null);

  LayoutCell get chain => _items.value.first;
  ValueNotifier<List<LayoutCell>> get cells => _items;

  _breakPrevious(LayoutCell cell) {
    if (cell.previous?.right == cell) cell.previous!.right = null;
    if (cell.previous?.bottom == cell) cell.previous!.bottom = null;
  }

  LayoutCell add(LayoutCell cell) {
    if (!_items.value.contains(cell)) {
      _items.value.add(cell);
    }
    return cell;
  }

  LayoutCell addRight(LayoutCell to, LayoutCell gc) {
    _breakPrevious(gc);
    to.right = gc;
    gc.previous = to;
    return add(gc);
  }

  LayoutCell addBottom(LayoutCell to, LayoutCell cell) {
    _breakPrevious(cell);
    to.bottom = cell;
    cell.previous = to;
    return add(cell);
  }

  _connectRightToBottomMostRight(LayoutCell cell, LayoutCell cellBottom, double handleSize) {
    LayoutCell? right = cellBottom;
    double parentWidth = cell.parentWidth;
    print('parent width = ${parentWidth}');
    while (right != null) {
      final rightWidthRelative = right.absoluteWidth / parentWidth;
      print('right width = ${rightWidthRelative} | ${right.width} | ${right.absoluteWidth}');
      right.parentWidth = parentWidth;
      right.width = rightWidthRelative;
      parentWidth -= right.absoluteWidth + handleSize;
      right = right.right;
    }
    final bottomMostRight = cellBottom.findMostRight();
    bottomMostRight.right = cell.right;
  }

  _rearrangeConnectionWithPrevious(
    LayoutCell prev,
    LayoutCell cell,
    double handleSize, [
    isRemoveFromPreviousBottom = true,
  ]) {
    print('> \t -> rearrange: isRemoveFromPreviousBottom = ${isRemoveFromPreviousBottom}');
    final hasBottomOnCell = cell.bottom != null;
    final hasRightOnCell = cell.right != null;
    final isHorizontal = cell.isHorizontal;
    print('> \t\t -> isHorizontal: ${isHorizontal}');
    print('> \t\t -> hasBottomOnCell = ${hasBottomOnCell}');
    print('> \t\t -> hasRightOnCell: ${hasRightOnCell}');
    if (hasBottomOnCell) {
      final cellBottom = cell.bottom!;
      if (isRemoveFromPreviousBottom) {
        prev.bottom = cellBottom;
        final shouldConnectRightToBottomRight = hasRightOnCell && cellBottom.hasRight;
        print('> \t\t\t -> shouldConnectRightToBottomRight: ${shouldConnectRightToBottomRight}');
        if (shouldConnectRightToBottomRight) {
          _connectRightToBottomMostRight(cell, cellBottom, handleSize);
        } else {
          if (hasRightOnCell) {
            print('> \t\t\t -> but cell has');
            cellBottom.right = cell.right;
            cellBottom.width = cell.width;
          }
        }
      } else {
        final shouldShiftRightToLeft = cell.isHorizontal && hasRightOnCell;
        print('> \t\t\t -> shouldShiftRightToLeft: ${shouldShiftRightToLeft}');
        if (shouldShiftRightToLeft) {
          final cellRight = cell.right!;
          prev.right = cellRight;
          final shouldConnectBottomToRightBottom = cellRight.bottom != null;
          print('> \t\t\t -> shouldConnectBottomToRightBottom: ${shouldConnectBottomToRightBottom}');
          if (shouldConnectBottomToRightBottom) {
            final rightMostBottom = cellRight.findMostBottom();
            rightMostBottom.bottom = cellBottom;
          } else {
            cellRight.bottom = cellBottom;
          }
          cellRight.height = -1;
        } else {
          final shouldConnectRightToBottomRight = hasRightOnCell && cellBottom.hasRight;
          print('> \t\t\t -> shouldConnectRightToBottomRight: ${shouldConnectRightToBottomRight}');
          print('> \t\t\t -> cell width: ${cell.width}');
          print('> \t\t\t -> cellBottom width: ${cellBottom.width}');
          prev.right = cellBottom;
          if (shouldConnectRightToBottomRight) {
            _connectRightToBottomMostRight(cell, cellBottom, handleSize);
          } else {
            print('> \t\t\t -> cell bottom has no right');
            if (hasRightOnCell) {
              print('> \t\t\t -> cellBottom.isHorizontal = ${cellBottom.isHorizontal}');
              if (cellBottom.isHorizontal) {
                final tempCellBottomBottom = cellBottom.bottom;
                cellBottom.bottom = null;
                cellBottom.right = cell.right;
                cellBottom.bottom = tempCellBottomBottom;
                cellBottom.width = cell.width;
              } else {
                print('> \t\t\t -> but cell has');
                cellBottom.right = cell.right;
                cellBottom.width = cell.width;
              }
            }
          }
        }
      }
    } else if (hasRightOnCell) {
      final cellRight = cell.right!;
      print('> \t\t -> remove - right only');
      if (isRemoveFromPreviousBottom) {
        // print('> \t\t\t -> isPreviousHorizontal (before): ${isPreviousHorizontal}');
        prev.bottom = cellRight;
        // print('> \t\t\t -> isPreviousHorizontal (after): ${prev.isHorizontal}');
      } else {
        prev.right = cellRight;
      }
      cellRight.parentWidth = cell.parentWidth;
      cellRight.width = cell.width + (cellRight.absoluteWidth + handleSize) / cell.parentWidth;
    } else {
      print('> \t\t -> remove - no further connections');
      if (isRemoveFromPreviousBottom) {
        prev.bottom = null;
        prev.height = -1;
      } else {
        prev.right = null;
        prev.width = -1;
      }
    }
  }

  void removeCell(LayoutCell deleteCell, double handleSize) {
    print('> Layout -> removeCell -> ${deleteCell}');
    final previous = deleteCell.previous;
    final hasPrevious = previous != null;
    // print('> \t -> hasPrevious = ${hasPrevious}');
    if (hasPrevious) {
      final isFromBottom = previous.bottom == deleteCell;
      _rearrangeConnectionWithPrevious(
        previous,
        deleteCell,
        handleSize,
        isFromBottom,
      );
      deleteCell.clearConnection();
    }
    _items.value = _items.value.where((el) => el != deleteCell).toList();
  }

  List<Widget> createNextSideWithHandler(LayoutCellParams params) {
    return [
      Handler(params.handleParams),
      positionWidgetsFrom(
        params.cell,
        parentWidth: params.parentWidth,
        parentHeight: params.parentHeight,
      ),
    ];
  }

  Widget positionWidgetsFrom(
    LayoutCell cell, {
    required double parentWidth,
    required double parentHeight,
    double handlerSize = 8,
  }) {
    final hasRight = cell.right != null;
    final hasBottom = cell.bottom != null;

    final hasWidth = cell.width > 0;
    final hasHeight = cell.height > 0;

    final double handleSizeX = (hasRight ? handlerSize : 0);
    final double handleSizeY = (hasBottom ? handlerSize : 0);

    cell.parentWidth = parentWidth;
    cell.parentHeight = parentHeight;

    final initialWidth = hasWidth ? cell.width * parentWidth : (parentWidth / (hasRight ? 2 : 1) - handleSizeX);
    final initialHeight = hasHeight ? cell.height * parentHeight : (parentHeight / (hasBottom ? 2 : 1) - handleSizeY);

    // print(
    //     '(${hasHeight ? 'hasHeight(${cell.height})' : 'noHeight'}:${hasWidth ? 'hasWidth(${cell.width})' : 'noWidth'}) '
    //     // '(${hasBottom ? 'hasBottom' : 'noBottom'}:${hasRight ? 'hasRight' : 'noRight'}) ',
    //     );

    ValueNotifier<double> horizontalResizer = ValueNotifier(initialWidth);
    ValueNotifier<double> verticalResizer = ValueNotifier(initialHeight);

    final isHorizontal = cell.isHorizontal;

    return Container(
      width: parentWidth,
      height: parentHeight,
      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
      child: ValueListenableBuilder(
        valueListenable: isHorizontal ? verticalResizer : horizontalResizer,
        builder: (_, double blockHeightWidth, __) {
          final outerSize = blockHeightWidth > handlerSize ? blockHeightWidth : handlerSize;

          // if (isHorizontal && hasBottom) cell.absoluteHeight = outerSize;
          // if (!isHorizontal && hasRight) cell.absoluteWidth = outerSize;

          return Flex(
            direction: isHorizontal ? Axis.vertical : Axis.horizontal,
            children: [
              ValueListenableBuilder(
                valueListenable: isHorizontal ? horizontalResizer : verticalResizer,
                builder: (_, double blockWidthHeight, __) {
                  final innerSize = blockWidthHeight > handlerSize ? blockWidthHeight : handlerSize;

                  // if (isHorizontal && hasRight) cell.absoluteWidth = innerSize;
                  // if (!isHorizontal && hasBottom) cell.absoluteHeight = innerSize;

                  cell.absoluteWidth = (isHorizontal ? innerSize : outerSize);
                  cell.absoluteHeight = (isHorizontal ? outerSize : innerSize);

                  cell.width = cell.absoluteWidth / parentWidth;
                  cell.height = cell.absoluteHeight / parentHeight;

                  return Flex(
                    direction: isHorizontal ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: cell.absoluteWidth,
                        height: cell.absoluteHeight,
                        child: _buildCellContent(cell, handlerSize),
                      ),
                      if (isHorizontal ? hasRight : hasBottom)
                        ...createNextSideWithHandler(isHorizontal
                            ? LayoutCellParams(
                                cell.right!,
                                parentWidth - (innerSize + handleSizeX),
                                outerSize,
                                LayoutHandleParams(horizontalResizer, outerSize, handleSizeX, false),
                              )
                            : LayoutCellParams(
                                cell.bottom!,
                                outerSize,
                                parentHeight - (innerSize + handleSizeY),
                                LayoutHandleParams(verticalResizer, outerSize, handleSizeY, true),
                              )),
                    ],
                  );
                },
              ),
              if (hasBottom || hasRight)
                ...createNextSideWithHandler(isHorizontal
                    ? LayoutCellParams(
                        cell.bottom!,
                        parentWidth,
                        parentHeight - (outerSize + handleSizeY),
                        LayoutHandleParams(verticalResizer, parentWidth, handleSizeY, true),
                      )
                    : LayoutCellParams(
                        cell.right!,
                        parentWidth - (outerSize + handleSizeX),
                        parentHeight,
                        LayoutHandleParams(horizontalResizer, parentHeight, handleSizeX, false),
                      ))
            ],
          );
        },
      ),
    );
  }

  Widget _buildCellContent(LayoutCell cell, double handlerSize) {
    return Column(
      children: [
        CellHeader(
          title: 'Cell',
          onPointerDown: () => selectedCell.value = cell,
          onPointerUp: () {
            final canRearrange = selectedCellRegionSide.value?.side != null;
            print('> Layout -> CellHeader - onPointerUp: canRearrange = ${canRearrange}');
            if (canRearrange) {
              final cellSide = selectedCellRegionSide.value?.side;
              final cellSideIndex = selectedCellRegionSide.value!.cell!.findCellSideIndex(selectedCell.value!);
              print('> \t cell side: ${cellSide}');
              print('> \t cell index: ${cellSideIndex}');
              // if (cellSideIndex > -1) {
              //   final cellSide = CellRegionSide.values[cellSideIndex];
              //   print('> \t cell side: $cellSide');
              // }
            }
            selectedCell.value = null;
            selectedCellRegionSide.value = null;
          },
          onRemove: cell.hasConnections ? () => removeCell(cell, handlerSize) : null,
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: selectedCell,
            builder: (_, LayoutCell? selected, Widget? child) {
              final hasSelected = selected != null && selected != cell;
              // print('> cellContent -> hasSelected: ${hasSelected}');
              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  cell.widget ?? Container(),
                  if (hasSelected)
                    LayoutRegions(
                      cell,
                      selectedCell.value!,
                      selectedCellRegionSide,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
