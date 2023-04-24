import 'package:flutter/material.dart';
import 'package:workspace_layout/layout.dart';

class LayoutInherited extends InheritedWidget {
  const LayoutInherited({
    super.key,
    required this.layout,
    required super.child,
  });

  final Layout layout;

  static LayoutInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LayoutInherited>();
  }

  static LayoutInherited of(BuildContext context) {
    final LayoutInherited? result = maybeOf(context);
    assert(result != null, 'No Inherit found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LayoutInherited old) {
    return true;
  }
}
