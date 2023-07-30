import 'package:flutter/material.dart';
import 'package:workspace_layout/layout.dart';

class Handler extends StatefulWidget {
  const Handler(
    this.params, {
    super.key,
  });

  final LayoutHandleParams params;

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
        final delta = widget.params.isHorizontal ? _.delta.dy : _.delta.dx;
        widget.params.resizer.value += delta;
      },
      child: MouseRegion(
        cursor: widget.params.isHorizontal ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
        child: Container(
          height: widget.params.isHorizontal ? widget.params.size : widget.params.parentSize,
          width: widget.params.isHorizontal ? widget.params.parentSize : widget.params.size,
          color: widget.params.isHorizontal ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
