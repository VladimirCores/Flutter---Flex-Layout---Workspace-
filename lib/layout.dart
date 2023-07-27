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

  void removeCell(LayoutCell cell) {
    print('> Layout -> removeCell -> ${cell}');
    final previous = cell.previous;
    if (previous != null) {
      if (previous.bottom == cell) {
        if (cell.right != null) {
          previous.bottom = cell.right;
          cell.right!.previous = previous;
        } else if (cell.bottom != null) {
          previous.bottom = cell.bottom;
          cell.bottom!.previous = previous;
        } else {
          previous.bottom = null;
        }
      } else if (previous.right == cell) {
        previous.right = null;
      }
      previous.width = previous.height = -1;
      cell.previous = null;
    }
    _items.value = _items.value.where((el) => el != cell).toList();
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

    // print(
    //   '(${hasHeight ? 'hasHeight(${cell.height})' : 'noHeight'}:${hasWidth ? 'hasWidth' : 'noWidth'}) '
    //   '(${hasBottom ? 'hasBottom' : 'noBottom'}:${hasRight ? 'hasRight' : 'noRight'}) ',
    // );

    cell.parentWidth = parentWidth;
    cell.parentHeight = parentHeight;

    final initialWidth = hasWidth ? cell.width * parentWidth : (parentWidth / (hasRight ? 2 : 1) - handleSizeX);
    final initialHeight = hasHeight ? cell.height * parentHeight : (parentHeight / (hasBottom ? 2 : 1) - handleSizeY);

    ValueNotifier<double> horizontalResizer = ValueNotifier(initialWidth);
    ValueNotifier<double> verticalResizer = ValueNotifier(initialHeight);

    final cellContent = Column(
      children: [
        CellHeader(
          title: 'Cell',
          onPointerDown: () => selectedCell.value = cell,
          onPointerUp: () {
            print('> Layout -> CellHeader - onPointerUp: ${selectedCell.value} | ${selectedCellRegionSide.value}');
            final canRearrange = selectedCellRegionSide.value?.side != null;
            if (canRearrange) {
              final cellSideIndex = selectedCellRegionSide.value!.cell!.findCellSideIndex(selectedCell.value!);
              if (cellSideIndex > -1) {
                final cellSide = CellRegionSide.values[cellSideIndex];
                print('> \t cell position: ${cellSideIndex} | $cellSide');
              }
            }
            selectedCell.value = null;
            selectedCellRegionSide.value = null;
          },
          onRemove: cell.hasConnections ? () => removeCell(cell) : null,
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: selectedCell,
            builder: (_, LayoutCell? selected, Widget? child) {
              final hasSelected = selected != null && selected != cell;
              // print('> cellContent -> hasSelected: ${hasSelected}');
              return Stack(
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

    final isBottomFirst = cell.isBottomFirst;

    return SizedBox(
      width: parentWidth,
      height: parentHeight,
      child: ValueListenableBuilder(
        valueListenable: isBottomFirst ? verticalResizer : horizontalResizer,
        builder: (_, double blockHeightWidth, Widget? child) {
          final outerSize = blockHeightWidth > handlerSize ? blockHeightWidth : handlerSize;

          if (isBottomFirst && hasBottom) cell.parentHeight = outerSize / parentHeight;
          if (!isBottomFirst && hasRight) cell.parentWidth = outerSize / parentWidth;

          return Flex(
            direction: isBottomFirst ? Axis.vertical : Axis.horizontal,
            children: [
              ValueListenableBuilder(
                valueListenable: isBottomFirst ? horizontalResizer : verticalResizer,
                builder: (_, double blockWidthHeight, Widget? child) {
                  final innerSize = blockWidthHeight > handlerSize ? blockWidthHeight : handlerSize;

                  if (isBottomFirst && hasRight) cell.parentWidth = innerSize / parentWidth;
                  if (!isBottomFirst && hasBottom) cell.parentHeight = innerSize / parentHeight;

                  return Flex(
                    direction: isBottomFirst ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: isBottomFirst ? innerSize : outerSize,
                        height: isBottomFirst ? outerSize : innerSize,
                        child: cellContent,
                      ),
                      if (isBottomFirst ? hasRight : hasBottom)
                        ...createNextSideWithHandler(isBottomFirst
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
                ...createNextSideWithHandler(isBottomFirst
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
}
