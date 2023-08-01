import 'package:flutter/material.dart';
import 'package:workspace/workspace.dart';

class WorkspaceInherited extends InheritedWidget {
  const WorkspaceInherited({
    super.key,
    required this.layout,
    required super.child,
  });

  final Workspace layout;

  static WorkspaceInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WorkspaceInherited>();
  }

  static WorkspaceInherited of(BuildContext context) {
    final WorkspaceInherited? result = maybeOf(context);
    assert(result != null, 'No Inherit found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(WorkspaceInherited old) {
    return true;
  }
}
