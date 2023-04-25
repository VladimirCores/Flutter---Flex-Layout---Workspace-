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

  final ValueNotifier<List<LayoutCell>> _items = ValueNotifier([]);

  ValueNotifier<LayoutCell?> selectedCell = ValueNotifier(null);

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
    print('removeCell -> ${cell}');
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
                  final isRemovable = cell.hasConnections;
                  return Column(
                    children: [
                      Container(
                        width: constrainedWidth,
                        height: constrainedHeight,
                        color: Color(color).withAlpha(90),
                        child: Column(
                          children: [
                            CellHeader(
                              title: 'Cell',
                              onPointerDown: () => selectedCell.value = cell,
                              onPointerUp: () => selectedCell.value = null,
                              onRemove: isRemovable ? () => removeCell(cell) : null,
                            ),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: selectedCell,
                                builder: (_, LayoutCell? selectedCellValue, Widget? child) {
                                  return Stack(
                                    children: [
                                      cell.widget ?? Container(),
                                      selectedCellValue != null && selectedCellValue != cell
                                          ? LayoutRegions(cell)
                                          : Container(),
                                    ],
                                  );
                                },
                              ),
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
