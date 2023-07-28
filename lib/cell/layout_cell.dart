import 'package:flutter/material.dart';

class LayoutCell {
  LayoutCell({
    this.width = -1,
    this.height = -1,
    this.colorCode = -1,
    this.widget,
  });

  double absoluteWidth = -1;
  double absoluteHeight = -1;

  double parentWidth = -1;
  double parentHeight = -1;

  get hasRight => _right != null;
  get hasBottom => _bottom != null;

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

  LayoutCell findMostRight() {
    LayoutCell? cellRight = this;
    var result = cellRight;
    while (cellRight != null) {
      result = cellRight;
      cellRight = cellRight.right;
    }
    return result;
  }

  int findMostRightIndex() {
    LayoutCell? cellRight = _right;
    var result = 0;
    while (cellRight != null) {
      result++;
      cellRight = cellRight.right;
    }
    return result;
  }

  LayoutCell findMostBottom() {
    LayoutCell? cellBottom = this;
    var result = cellBottom;
    while (cellBottom != null) {
      result = cellBottom;
      cellBottom = cellBottom.bottom;
    }
    return result;
  }

  void clearConnection() {
    if (hasRight) order.remove(_right);
    if (hasBottom) order.remove(_bottom);
    _right = null;
    _bottom = null;
    previous = null;
  }

  void _appendInstead(LayoutCell? value, LayoutCell? current) {
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

  bool get isHorizontal => hasBottom && bottom == order.first;
  bool get hasConnections => previous != null;

  LayoutCell? _right;
  set right(LayoutCell? value) {
    final hadValue = hasRight;
    final hasValue = value != null;
    // print('> LayoutCell -> change right: had|has value = ${hadValue}|${hasValue}');
    _appendInstead(value, _right);
    _right = value;
    if (hasValue) _right!.previous = this;
  }

  LayoutCell? get right => _right;

  LayoutCell? _bottom;
  set bottom(LayoutCell? value) {
    final hasValue = value != null;
    _appendInstead(value, _bottom);
    _bottom = value;
    if (hasValue) _bottom!.previous = this;
  }

  LayoutCell? get bottom => _bottom;

  LayoutCell? previous;
}
