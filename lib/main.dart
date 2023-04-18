import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:workspace_layout/grid.dart';
import 'package:workspace_layout/handler.dart';
import 'package:workspace_layout/layout.dart';

final rndColor = () => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

void main() {
  runApp(WorkspaceGrid());
}

class WorkspaceGrid extends StatelessWidget {
  WorkspaceGrid({super.key}) {
    final gc1 = GridCell();
    final gc2 = GridCell();

    grid.add(GridCell());
    // grid.addRight(grid.chain, gc1);
    grid.addBottom(grid.chain, GridCell());
    // grid.addRight(gc1, gc2);
  }

  final Grid grid = Grid();

  Widget positionItems(
    GridCell gc, {
    required double parentWidth,
    required double parentHeight,
    double handlerSize = 8,
  }) {
    final hasRight = gc.right != null;
    final hasBottom = gc.bottom != null;
    final hasWidth = gc.width > 0;
    final hasHeight = gc.height > 0;

    final contentWidth = hasWidth ? gc.width * parentWidth : parentWidth / (hasRight ? 2 : 1);
    final contentHeight = hasHeight ? gc.height * parentHeight : parentHeight / (hasBottom ? 2 : 1);

    print(
      '(${hasHeight ? 'hasHeight(${gc.height})' : 'noHeight'}:${hasWidth ? 'hasWidth' : 'noWidth'}) '
      '(${hasBottom ? 'hasBottom' : 'noBottom'}:${hasRight ? 'hasRight' : 'noRight'}) '
      '(w:$contentWidth,h:$contentHeight) ',
    );

    gc.parentWidth = parentWidth;
    gc.parentHeight = parentHeight;

    if (!hasWidth && hasRight) gc.width = contentWidth / parentWidth;
    if (!hasHeight && hasBottom) gc.height = contentHeight / parentHeight;

    final content = Box(
      mix: Mix(
        w(contentWidth - (hasRight ? handlerSize : 0)),
        h(contentHeight - (hasBottom ? handlerSize : 0)),
        bgColor(rndColor()),
      ),
    );

    Widget items = Box(
      mix: Mix(
        w(parentWidth),
        h(parentHeight),
        bgColor(Colors.black),
      ),
      child: HBox(
        mix: Mix(
          mainAxis(MainAxisAlignment.start),
          mainAxisSize(MainAxisSize.min),
          crossAxis(CrossAxisAlignment.start),
          verticalDirection(VerticalDirection.down),
        ),
        children: [
          VBox(
            mix: Mix(
              mainAxis(MainAxisAlignment.start),
              mainAxisSize(MainAxisSize.max),
              crossAxis(CrossAxisAlignment.start),
              verticalDirection(VerticalDirection.down),
            ),
            children: [
              content,
              if (hasBottom) ...[
                Handler(
                  gc,
                  isHorizontal: true,
                  size: handlerSize,
                ),
                // positionItems(
                //   gc.bottom!,
                //   parentWidth: contentWidth,
                //   parentHeight: parentHeight - contentHeight,
                // ),
              ]
            ],
          ),
          if (hasRight) ...[
            Handler(gc),
            positionItems(
              gc.right!,
              parentWidth: parentWidth - contentWidth,
              parentHeight: parentHeight,
            ),
          ],
        ],
      ),
    );
    return items;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkspaceGrid',
      home: Layout(
        grid: grid.cells,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return StreamBuilder(
              stream: Layout.of(context).resizeController.stream,
              builder: (_, AsyncSnapshot<double> snapshot) {
                print('> StreamBuilder');
                return positionItems(
                  grid.chain,
                  parentWidth: constraints.maxWidth,
                  parentHeight: constraints.maxHeight,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
