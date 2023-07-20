import 'package:flutter/material.dart';

class LayoutCell {
  LayoutCell({
    this.width = -1,
    this.height = -1,
    this.colorCode = -1,
    this.widget,
  });

  double parentWidth = -1;
  double parentHeight = -1;

  get contentWidth => width * parentWidth;
  get contentHeight => height * parentHeight;

  double width;
  double height;
  int colorCode;

  Widget? widget;
  final order = <LayoutCell>[];

  int findCellSideIndex(LayoutCell cell) {
    if (cell.bottom == this) return 0; // top
    if (cell == _right) return 1; // right
    if (cell == _bottom) return 2; // bottom
    if (cell.right == this) return 3; // left
    return -1;
  }

  void _appendOnTop(LayoutCell? value, LayoutCell? current) {
    if (current != null) order.remove(current);
    if (value != null) order.add(value);
  }

  bool get isBottomFirst => bottom != null && bottom == order.first;
  bool get hasConnections => order.isNotEmpty || previous != null;

  LayoutCell? _right;
  set right(LayoutCell? value) {
    _appendOnTop(value, _right);
    _right = value;
  }

  LayoutCell? get right => _right;

  LayoutCell? _bottom;
  set bottom(LayoutCell? value) {
    _appendOnTop(value, _bottom);
    _bottom = value;
  }

  LayoutCell? get bottom => _bottom;

  LayoutCell? previous;
}
