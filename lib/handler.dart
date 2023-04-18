import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class Handler extends StatefulWidget {
  const Handler(
    this.parentSize, {
    super.key,
    this.isHorizontal = false,
    required this.resizer,
    required this.size,
  });

  final bool isHorizontal;
  final ValueNotifier<double> resizer;
  final double parentSize;
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
        widget.resizer.value += delta;
      },
      child: MouseRegion(
        cursor:
            widget.isHorizontal ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
        child: Box(
          mix: Mix.chooser(
            condition: widget.isHorizontal,
            ifTrue: Mix(h(widget.size), w(widget.parentSize)),
            ifFalse: Mix(w(widget.size), h(widget.parentSize)),
          ).apply(Mix(bgColor(Colors.transparent))),
        ),
      ),
    );
  }
}
