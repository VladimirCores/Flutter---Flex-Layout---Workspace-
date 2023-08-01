import 'package:flutter/foundation.dart';
import 'package:workspace/panel.dart';

class WorkspaceHandleParams {
  final ValueNotifier<double> resizer;
  final double parentSize;
  final double size;
  final bool isHorizontal;

  WorkspaceHandleParams(this.resizer, this.parentSize, this.size, this.isHorizontal);
}

class WorkspacePanelParams {
  final WorkspacePanel panel;
  final double parentWidth;
  final double parentHeight;

  final WorkspaceHandleParams handleParams;

  WorkspacePanelParams(
    this.panel,
    this.parentWidth,
    this.parentHeight,
    this.handleParams,
  );
}
