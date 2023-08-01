import 'package:flutter/material.dart';
import 'package:workspace/panel/panel_params.dart';

class Handler extends StatefulWidget {
  const Handler(
    this.size,
    this.params, {
    super.key,
  });

  final double size;
  final WorkspaceHandleParams params;

  @override
  State<Handler> createState() => _HandlerState();
}

class _HandlerState extends State<Handler> {
  @override
  Widget build(_) {
    final params = widget.params;
    final isHorizontal = params.isHorizontal;
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerMove: (_) {
        // print('DragHandle > onPointerMove: ${_.position} - ${_.delta}');
        final delta = isHorizontal ? _.delta.dy : _.delta.dx;
        params.resizer.value += delta;
      },
      child: MouseRegion(
        cursor: isHorizontal ? SystemMouseCursors.resizeRow : SystemMouseCursors.resizeColumn,
        child: Container(
          height: isHorizontal ? widget.size : params.parentSize,
          width: isHorizontal ? params.parentSize : widget.size,
          color: isHorizontal ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
