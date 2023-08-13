part of workspace;

class WorkspaceInherited extends InheritedWidget {
  const WorkspaceInherited({
    super.key,
    required this.workspace,
    required super.child,
  });

  final Workspace workspace;

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
