import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workspace_layout/grid.dart';

class Layout extends InheritedWidget {
  Layout({
    super.key,
    required this.grid,
    required super.child,
  });

  final List<GridCell> grid;
  final StreamController<double> resizeController = StreamController<double>();

  static Layout? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Layout>();
  }

  static Layout of(BuildContext context) {
    final Layout? result = maybeOf(context);
    assert(result != null, 'No Layout found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Layout oldWidget) => true;
}
