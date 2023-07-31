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

  LayoutCell get root => _items.value.first;
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
    if (to.hasBottom) {
      if (cell.hasBottom && !cell.isRoot) {
        cell.previous!.bottom = cell.bottom;
      }
      cell.bottom = to.bottom;
    }
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
            cellBottom.absoluteWidth = cell.absoluteWidth;
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
              } else {
                print('> \t\t\t -> but cell has');
                cellBottom.right = cell.right;
              }
              cellBottom.absoluteWidth = cell.absoluteWidth;
              cellBottom.width = cell.width;
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

  void removeCell(LayoutCell deleteCell, double handleSize, {keep = false, willBecomeRoot = false}) {
    print('> Layout -> removeCell: keep = ${keep}');
    final previous = deleteCell.previous;
    final hasPrevious = previous != null;
    print('> \t -> hasPrevious = ${hasPrevious}');
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
    if (keep) {
      if (willBecomeRoot) {
        _items.value.remove(deleteCell);
        _items.value.insert(0, deleteCell);
      }
      _items.notifyListeners();
    } else {
      _items.value = _items.value.where((el) => el != deleteCell).toList();
    }
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
    double handlerSize = 4,
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
      color: cell.colorCode,
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

  final REMOVABLE_SIDES = [
    CellRegionSide.TOP,
    CellRegionSide.RIGHT,
    CellRegionSide.BOTTOM,
    CellRegionSide.LEFT,
  ];

  Widget _buildCellContent(LayoutCell cell, double handlerSize) {
    return Column(
      children: [
        CellHeader(
          title: 'Cell',
          onPointerDown: () => selectedCell.value = cell,
          onPointerUp: () {
            final canRearrange = selectedCellRegionSide.value?.side != null && selectedCell.value != null;
            print('> Layout -> CellHeader - onPointerUp: canRearrange = ${canRearrange}');
            if (canRearrange) {
              final cellSide = selectedCellRegionSide.value?.side;
              final targetCell = selectedCellRegionSide.value!.cell;
              final movingCell = selectedCell.value!;
              final cellSideIndex = targetCell!.findCellSideIndex(selectedCell.value!);
              final isMovingCellPrevious = movingCell == targetCell.previous;
              final isTargetRoot = targetCell.previous == null;

              print('> \t cell side: ${cellSide}');
              print('> \t cell index: ${cellSideIndex}');

              final isMovingCellBecomeRoot = isTargetRoot && cellSide == CellRegionSide.LEFT;

              if (REMOVABLE_SIDES.contains(cellSide)) {
                removeCell(movingCell, handlerSize, keep: true, willBecomeRoot: isMovingCellBecomeRoot);
              }

              final isTargetHorizontal = targetCell.isHorizontal;
              final isTargetWithSideConnections = targetCell.hasRight || targetCell.hasBottom;

              final isTargetOnBottom = !isTargetRoot && targetCell.previous!.bottom == targetCell;
              final isTargetOnRight = !isTargetRoot && targetCell.previous!.right == targetCell;

              switch (cellSide) {
                case CellRegionSide.TOP:
                  if (isTargetRoot) {
                  } else {
                    if (isTargetOnBottom) {
                      targetCell.previous!.bottom = movingCell;
                    } else if (isTargetOnRight) {
                      targetCell.previous!.right = movingCell;
                    }
                    if (isTargetWithSideConnections) {
                      final right = targetCell.right;
                      targetCell.right = null;
                      if (isTargetHorizontal) {
                        movingCell.bottom = targetCell;
                        movingCell.right = right;
                      } else {
                        movingCell.right = right;
                        movingCell.bottom = targetCell;
                      }
                      movingCell.right?.previous = movingCell;
                    } else {
                      movingCell.bottom = targetCell;
                    }

                    movingCell.width = targetCell.width;
                    movingCell.height = -1;
                    targetCell.width = -1;
                  }
                  break;
                case CellRegionSide.BOTTOM:
                  final targetAbsoluteHeight = targetCell.absoluteHeight;
                  final bottomHeight = 1 / targetCell.height - 1;
                  final bottomAbsoluteHeight = bottomHeight * targetAbsoluteHeight;
                  final targetAbsoluteHeightAfterMove = targetAbsoluteHeight * 0.5;
                  final bottomAbsoluteHeightAfterMove = bottomAbsoluteHeight + targetAbsoluteHeightAfterMove;

                  movingCell.bottom = targetCell.bottom;
                  targetCell.bottom = movingCell;

                  print('> \t bottomHeight: ${targetAbsoluteHeight}|${bottomAbsoluteHeight}');
                  targetCell.absoluteHeight = targetAbsoluteHeightAfterMove;
                  movingCell.absoluteHeight = targetAbsoluteHeightAfterMove;
                  targetCell.height *= 0.5;
                  movingCell.height = (targetCell.absoluteHeight - handlerSize) / bottomAbsoluteHeightAfterMove;
                  movingCell.width = -1;
                case CellRegionSide.RIGHT:
                  print('> RIGHT');
                  final targetAbsoluteWidth = targetCell.absoluteWidth;
                  final rightWidth = 1 / targetCell.width - 1;
                  final rightAbsoluteWidth = rightWidth * targetAbsoluteWidth;
                  final targetAbsoluteWidthAfterMove = targetAbsoluteWidth * 0.5;
                  final rightAbsoluteWidthAfterMove = rightAbsoluteWidth + targetAbsoluteWidthAfterMove;

                  print('> \t targetCell.isHorizontal: ${targetCell.isHorizontal}');
                  print('> \t targetCell.hasRight: ${targetCell.hasRight}');

                  movingCell.right = targetCell.right;
                  targetCell.right = movingCell;

                  targetCell.absoluteWidth = targetAbsoluteWidthAfterMove;
                  movingCell.absoluteWidth = targetAbsoluteWidthAfterMove;
                  targetCell.width *= 0.5;
                  if (movingCell.hasRight) {
                    movingCell.width = (targetCell.absoluteWidth - handlerSize) / rightAbsoluteWidthAfterMove;
                  } else {
                    movingCell.width = -1;
                  }
                  movingCell.height = -1;
                case CellRegionSide.LEFT:
                  print('> LEFT: isTargetRoot = ${isTargetRoot}');
                  print('> \t\t isTargetHorizontal = ${isTargetHorizontal}');
                  print('> \t\t movingCell.previous = ${movingCell.previous}');
                  if (isTargetRoot) {
                    final bottom = targetCell.bottom;
                    targetCell.bottom = null;
                    if (isTargetHorizontal) {
                      movingCell.bottom = bottom;
                      movingCell.right = targetCell;
                    } else {
                      movingCell.right = targetCell;
                      movingCell.bottom = bottom;
                    }
                    movingCell.absoluteWidth = targetCell.absoluteWidth;
                    movingCell.width = targetCell.width = targetCell.width * 0.5;
                    movingCell.height = targetCell.height;
                  } else {
                    final targetAbsoluteWidth = targetCell.absoluteWidth;
                    final rightWidth = 1 / targetCell.width - 1;
                    final rightAbsoluteWidth = rightWidth * targetAbsoluteWidth;
                    final targetAbsoluteWidthAfterMove = targetAbsoluteWidth * 0.5;
                    final rightAbsoluteWidthAfterMove = rightAbsoluteWidth + targetAbsoluteWidthAfterMove;

                    targetCell.absoluteWidth = movingCell.absoluteWidth = targetAbsoluteWidthAfterMove;
                    movingCell.width *= 0.5;

                    if (targetCell.hasRight) {
                      targetCell.width = (targetAbsoluteWidthAfterMove - handlerSize) / rightAbsoluteWidthAfterMove;
                    } else {
                      movingCell.width = targetCell.width = -1;
                    }
                    print('> \t isTargetOnBottom = ${isTargetOnBottom}');
                    print('> \t isTargetOnRight = ${isTargetOnRight}');
                    if (!isMovingCellPrevious) {
                      if (isTargetOnBottom) {
                        targetCell.previous!.bottom = movingCell;
                      } else if (isTargetOnRight) {
                        targetCell.previous!.right = movingCell;
                      }
                    } else {
                      if (targetCell.previous!.right == targetCell) {
                        targetCell.previous!.right = movingCell;
                      } else if (targetCell.previous!.bottom == targetCell) {
                        targetCell.previous!.bottom = movingCell;
                      }
                    }
                    movingCell.right = targetCell;
                  }
                  break;
                case CellRegionSide.CENTER:
                case null:
              }
            }
            selectedCell.value = null;
            selectedCellRegionSide.value = null;
          },
          onRemove: !cell.isRoot ? () => removeCell(cell, handlerSize) : null,
        ),
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              cell.widget ?? Container(),
              ValueListenableBuilder(
                valueListenable: selectedCell,
                builder: (_, LayoutCell? selected, __) {
                  final hasSelected = selected != null;
                  final isDifferent = selected != cell;
                  // print('> cellContent -> hasSelected: ${hasSelected}');
                  return hasSelected && isDifferent
                      ? LayoutRegions(
                          cell,
                          selected,
                          selectedCellRegionSide,
                        )
                      : Container();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
