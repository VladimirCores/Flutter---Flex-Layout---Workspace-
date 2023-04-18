import 'package:flutter/material.dart';

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
        // print('DragHandle > onPointerMove: ${_.position} - ${_.delta}');
        final delta = widget.isHorizontal ? _.delta.dy : _.delta.dx;
        widget.resizer.value += delta;
      },
      child: MouseRegion(
        cursor:
            widget.isHorizontal ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
        child: Container(
          height: widget.isHorizontal ? widget.size : widget.parentSize,
          width: widget.isHorizontal ? widget.parentSize : widget.size,
          color: Colors.black26,
        ),
      ),
    );
  }
}
