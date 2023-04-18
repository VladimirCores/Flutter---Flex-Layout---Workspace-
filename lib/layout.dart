import 'package:flutter/material.dart';
import 'package:workspace_layout/handler.dart';
import 'package:workspace_layout/utils.dart';

class LayoutCell {
  LayoutCell({this.right, this.bottom, this.width = -1, this.height = -1, this.colorCode = -1});

  double parentWidth = -1;
  double parentHeight = -1;

  get contentWidth => width * parentWidth;
  get contentHeight => height * parentHeight;

  double width;
  double height;
  int colorCode;

  LayoutCell? right;
  LayoutCell? bottom;
  LayoutCell? previous;
}

class Layout {
  Layout();

  int xCount = 0;
  int yCount = 0;

  final List<LayoutCell> _items = [];

  LayoutCell get chain => _items.first;
  List<LayoutCell> get cells => _items;

  _breakPrevious(LayoutCell gc) {
    if (gc.previous?.right == gc) gc.previous!.right = null;
    if (gc.previous?.bottom == gc) gc.previous!.bottom = null;
  }

  LayoutCell add(LayoutCell gc) {
    if (!_items.contains(gc)) _items.add(gc);
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
            if (hasRight) cell.width = blockWidth / parentWidth;
            return Row(
              children: [
                ValueListenableBuilder(
                    valueListenable: verticalResizer,
                    builder: (_, double blockHeight, Widget? child) {
                      if (hasBottom) cell.height = blockHeight / parentHeight;
                      return Column(
                        children: [
                          Container(
                            width: blockWidth,
                            height: blockHeight,
                            color: Color(
                              cell.colorCode > 0 ? cell.colorCode : rndColorCode(),
                            ).withOpacity(1),
                          ),
                          if (hasBottom) ...[
                            Handler(
                              blockWidth,
                              resizer: verticalResizer,
                              isHorizontal: true,
                              size: handlerSize,
                            ),
                            positionWidgetsFrom(
                              cell.bottom!,
                              parentWidth: blockWidth,
                              parentHeight: parentHeight - (blockHeight + handleDeltaY),
                            ),
                          ]
                        ],
                      );
                    }),
                if (hasRight) ...[
                  Handler(
                    parentHeight,
                    resizer: horizontalResizer,
                    isHorizontal: false,
                    size: handlerSize,
                  ),
                  positionWidgetsFrom(
                    cell.right!,
                    parentWidth: parentWidth - (blockWidth + handleDeltaX),
                    parentHeight: parentHeight,
                  ),
                ],
              ],
            );
          }),
    );
    return items;
  }
}
