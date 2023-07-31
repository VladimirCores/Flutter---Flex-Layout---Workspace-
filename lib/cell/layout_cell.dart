import 'dart:math';

import 'package:flutter/material.dart';

class LayoutCell {
  LayoutCell({
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

  LayoutCell findMostBottom() {
    LayoutCell? cellBottom = this;
    var result = cellBottom;
    while (cellBottom != null) {
      result = cellBottom;
      cellBottom = cellBottom.bottom;
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

  bool get isRoot => previous == null;
  bool get isHorizontal => hasBottom && bottom == order.first;

  LayoutCell? _right;
  set right(LayoutCell? value) {
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

  void _reconnectWithSide(LayoutCell? cell, LayoutCell? side) {
    final hasValue = cell != null;
    if (hasValue) {
      cell.previous = this;
    } else {
      if (side != null) {
        side.previous = null;
      }
    }
  }

  LayoutCell? get right => _right;

  LayoutCell? _bottom;
  set bottom(LayoutCell? value) {
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

  LayoutCell? get bottom => _bottom;

  LayoutCell? previous;
}
