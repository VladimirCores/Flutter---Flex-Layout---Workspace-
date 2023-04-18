import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:workspace_layout/grid.dart';
import 'package:workspace_layout/layout.dart';

class Handler extends StatefulWidget {
  const Handler(this.gc, {super.key, this.isHorizontal = false, this.size = 8});

  final GridCell gc;
  final bool isHorizontal;
  final double size;

  @override
  State<Handler> createState() => _HandlerState();
}

class _HandlerState extends State<Handler> {
  @override
  Widget build(_) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerMove: (_) {
        print('DragHandle > onPointerMove: ${_.position} - ${_.delta}');
        final delta = widget.isHorizontal ? _.delta.dy : _.delta.dx;
        if (widget.isHorizontal) {
          widget.gc.height += delta / widget.gc.parentHeight;
        } else {
          widget.gc.width += delta / widget.gc.parentWidth;
        }
        Layout.of(context).resizeController.add(delta);
      },
      child: MouseRegion(
        cursor:
            widget.isHorizontal ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
        child: Box(
          mix: Mix.chooser(
            condition: widget.isHorizontal,
            ifTrue: Mix(h(widget.size), w(widget.gc.parentWidth)),
            ifFalse: Mix(w(widget.size), h(widget.gc.parentHeight)),
          ).apply(Mix(bgColor(Colors.red))),
        ),
      ),
    );
  }
}
