import 'dart:math';

import 'package:flutter/material.dart';

class WorkspacePanel {
  WorkspacePanel({
    this.width = -1,
    this.height = -1,
    this.widget,
    randomColor = true,
  }) {
    if (randomColor) {
      colorCode = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    }
  }

  double absoluteWidth = -1;
  double absoluteHeight = -1;

  double parentWidth = -1;
  double parentHeight = -1;

  get hasRight => _right != null;
  get hasBottom => _bottom != null;

  double width;
  double height;
  Color? colorCode;

  Widget? widget;
  final order = <WorkspacePanel>[];

  int findCellSideIndex(WorkspacePanel panel) {
    if (panel.bottom == this) return 0; // top
    if (panel == _right) return 1; // right
    if (panel == _bottom) return 2; // bottom
    if (panel.right == this) return 3; // left
    return -1;
  }

  WorkspacePanel findMostRight() {
    WorkspacePanel? panelRight = this;
    var result = panelRight;
    while (panelRight != null) {
      result = panelRight;
      panelRight = panelRight.right;
    }
    return result;
  }

  WorkspacePanel findMostBottom() {
    WorkspacePanel? panelBottom = this;
    var result = panelBottom;
    while (panelBottom != null) {
      result = panelBottom;
      panelBottom = panelBottom.bottom;
    }
    return result;
  }

  bool switchOrientation() {
    if (!hasBottom || !hasRight) {
      return false;
    } else {
      final last = order.removeLast();
      order.insert(0, last);
    }
    print('> LayoutCell -> switchOrientation');
    return true;
  }

  void clearConnection() {
    if (hasRight) order.remove(_right);
    if (hasBottom) order.remove(_bottom);
    _right = null;
    _bottom = null;
    previous = null;
  }

  void _appendInstead(WorkspacePanel? value, WorkspacePanel? current) {
    final hasCurrent = current != null;
    final isCurrentFirst = hasCurrent && current == order.first;
    // print('> LayoutCell -> appendInstead: isCurrentFirst = ${isCurrentFirst}');
    if (hasCurrent) order.remove(current);
    if (value != null) {
      if (isCurrentFirst) {
        order.insert(0, value);
      } else {
        order.add(value);
      }
    }
  }

  bool get isRoot => previous == null;
  bool get isHorizontal => hasBottom && bottom == order.first;

  WorkspacePanel? _right;
  set right(WorkspacePanel? value) {
    // print('> LayoutCell -> change right: had|has value = ${hadValue}|${hasValue}');
    _appendInstead(value, _right);
    // _reconnectWithSide(value, _right);
    final hasValue = value != null;
    if (hasValue) {
      value.previous = this;
    } else {
      if (_right != null) {
        _right!.previous = null;
      }
    }
    _right = value;
  }

  void _reconnectWithSide(WorkspacePanel? panel, WorkspacePanel? side) {
    final hasValue = panel != null;
    if (hasValue) {
      panel.previous = this;
    } else {
      if (side != null) {
        side.previous = null;
      }
    }
  }

  WorkspacePanel? get right => _right;

  WorkspacePanel? _bottom;
  set bottom(WorkspacePanel? value) {
    _appendInstead(value, _bottom);
    // _reconnectWithSide(value, _bottom);
    final hasValue = value != null;
    if (hasValue) {
      value.previous = this;
    } else {
      if (_bottom != null) {
        _bottom!.previous = null;
      }
    }
    _bottom = value;
  }

  WorkspacePanel? get bottom => _bottom;

  WorkspacePanel? previous;
}
