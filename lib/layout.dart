import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/cell_header.dart';
import 'package:workspace_layout/cell/layout_cell.dart';
import 'package:workspace_layout/handler.dart';
import 'package:workspace_layout/regions.dart';
import 'package:workspace_layout/utils.dart';

class Layout {
  Layout();

  int xCount = 0;
  int yCount = 0;

  final List<LayoutCell> _items = [];

  ValueNotifier<LayoutCell?> selectedCell = ValueNotifier(null);

  LayoutCell get chain => _items.first;
  List<LayoutCell> get cells => _items;

  _breakPrevious(LayoutCell gc) {
    if (gc.previous?.right == gc) gc.previous!.right = null;
    if (gc.previous?.bottom == gc) gc.previous!.bottom = null;
  }

  LayoutCell add(LayoutCell gc) {
    if (!_items.contains(gc)) {
      gc.index = _items.length;
      _items.add(gc);
    }
    return gc;
  }

  LayoutCell addRight(LayoutCell to, LayoutCell gc) {
    _breakPrevious(gc);
    to.right = gc;
    gc.previous = to;
    return add(gc);
  }

  LayoutCell addBottom(LayoutCell to, LayoutCell gc) {
    _breakPrevious(gc);
    to.bottom = gc;
    gc.previous = to;
    return add(gc);
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

    final handleDeltaX = (hasRight ? handlerSize : 0);
    final handleDeltaY = (hasBottom ? handlerSize : 0);

    print(
      '(${hasHeight ? 'hasHeight(${cell.height})' : 'noHeight'}:${hasWidth ? 'hasWidth' : 'noWidth'}) '
      '(${hasBottom ? 'hasBottom' : 'noBottom'}:${hasRight ? 'hasRight' : 'noRight'}) ',
    );

    cell.parentWidth = parentWidth;
    cell.parentHeight = parentHeight;

    ValueNotifier<double> horizontalResizer = ValueNotifier(
        hasWidth ? cell.width * parentWidth : parentWidth / (hasRight ? 2 : 1) - handleDeltaX);
    ValueNotifier<double> verticalResizer = ValueNotifier(
        hasHeight ? cell.height * parentHeight : parentHeight / (hasBottom ? 2 : 1) - handleDeltaY);

    Widget items = SizedBox(
      width: parentWidth,
      height: parentHeight,
      child: ValueListenableBuilder(
        valueListenable: horizontalResizer,
        builder: (_, double blockWidth, Widget? child) {
          final constrainedWidth = blockWidth > handlerSize ? blockWidth : handlerSize;
          if (hasRight) cell.width = constrainedWidth / parentWidth;
          return Row(
            children: [
              ValueListenableBuilder(
                valueListenable: verticalResizer,
                builder: (_, double blockHeight, Widget? child) {
                  final constrainedHeight = blockHeight > handlerSize ? blockHeight : handlerSize;
                  if (hasBottom) cell.height = constrainedHeight / parentHeight;
                  final color = cell.colorCode > 0 ? cell.colorCode : rndColorCode();
                  return Column(
                    children: [
                      Container(
                        width: constrainedWidth,
                        height: constrainedHeight,
                        color: Color(color).withOpacity(1),
                        child: Column(
                          children: [
                            CellHeader(
                              cell: cell,
                              title: 'Cell: ${cell.index}',
                              onCellSelected: selectedCell,
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                  valueListenable: selectedCell,
                                  builder: (_, LayoutCell? selectedCellValue, Widget? child) {
                                    return Stack(
                                      children: [
                                        cell.widget ?? Container(),
                                        LayoutRegions(cell)
                                        // selectedCellValue != null && selectedCellValue != cell
                                        //     ? LayoutRegions(cell)
                                        //     : Container(),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      if (hasBottom) ...[
                        Handler(
                          constrainedWidth,
                          resizer: verticalResizer,
                          isHorizontal: true,
                          size: handlerSize,
                        ),
                        positionWidgetsFrom(
                          cell.bottom!,
                          parentWidth: constrainedWidth,
                          parentHeight: parentHeight - (constrainedHeight + handleDeltaY),
                        ),
                      ]
                    ],
                  );
                },
              ),
              if (hasRight) ...[
                Handler(
                  parentHeight,
                  resizer: horizontalResizer,
                  isHorizontal: false,
                  size: handlerSize,
                ),
                positionWidgetsFrom(
                  cell.right!,
                  parentWidth: parentWidth - (constrainedWidth + handleDeltaX),
                  parentHeight: parentHeight,
                ),
              ],
            ],
          );
        },
      ),
    );
    return items;
  }
}
