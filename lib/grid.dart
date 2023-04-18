enum Side { right, bottom }

class GridCell {
  GridCell({this.right, this.bottom, this.width = -1, this.height = -1});

  double parentWidth = -1;
  double parentHeight = -1;

  double width;
  double height;

  GridCell? right;
  GridCell? bottom;
  GridCell? previous;
}

class Grid {
  Grid();

  int xCount = 0;
  int yCount = 0;

  final List<GridCell> _items = [];

  GridCell get chain => _items.first;
  List<GridCell> get cells => _items;

  _breakPrevious(GridCell gc) {
    if (gc.previous?.right == gc) gc.previous!.right = null;
    if (gc.previous?.bottom == gc) gc.previous!.bottom = null;
  }

  GridCell add(GridCell gc) {
    _items.add(gc);
    return gc;
  }

  GridCell addRight(GridCell to, GridCell gc) {
    _breakPrevious(gc);
    to.right = gc;
    gc.previous = to;
    return add(gc);
  }

  GridCell addBottom(GridCell to, GridCell gc) {
    _breakPrevious(gc);
    to.bottom = gc;
    gc.previous = to;
    return add(gc);
  }
}
