import 'package:flutter/material.dart';

class LayoutCell {
  LayoutCell({
    this.right,
    this.bottom,
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
  int index = -1;

  Widget? widget;

  LayoutCell? right;
  LayoutCell? bottom;
  LayoutCell? previous;
}
