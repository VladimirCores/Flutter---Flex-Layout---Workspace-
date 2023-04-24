import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/layout_cell.dart';

class LayoutRegions extends StatefulWidget {
  const LayoutRegions(
    this.cell, {
    super.key,
  });

  final LayoutCell cell;

  @override
  State<LayoutRegions> createState() => _LayoutRegionsState();
}

enum CellRegionSide { TOP, RIGHT, BOTTOM, LEFT, CENTER }

class _LayoutRegionsState extends State<LayoutRegions> {
  final ValueNotifier<CellRegionSide?> _side = ValueNotifier(null);
  Size? _size;

  final _FULL_HEIGHT_SIDES = [CellRegionSide.RIGHT, CellRegionSide.LEFT, CellRegionSide.CENTER];

  void onHover(Size? size, CellRegionSide? side) {
    _size = size;
    _side.value = side;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: _side,
          builder: (_, side, __) {
            if (side == null || _size == null) return Container();
            final currentSize = (context.findRenderObject() as RenderBox).size;
            double? top = CellRegionSide.BOTTOM != side ? 0 : currentSize.height - _size!.height;
            double? left = CellRegionSide.RIGHT != side ? 0 : currentSize.width - _size!.width;
            final isFullCellHeight = _FULL_HEIGHT_SIDES.contains(side);
            return Positioned(
              top: top,
              left: left,
              child: Container(
                width: CellRegionSide.CENTER == side ? currentSize.width : _size!.width,
                height: isFullCellHeight ? currentSize.height : _size!.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withAlpha(90), width: 2),
                  ),
                ),
              ),
            );
          },
        ),
        Column(
          children: [
            LayoutCellRegion(
              CellRegionSide.TOP,
              onHover: onHover,
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  LayoutCellRegion(
                    CellRegionSide.LEFT,
                    onHover: onHover,
                  ),
                  LayoutCellRegion(
                    flex: 3,
                    CellRegionSide.CENTER,
                    onHover: onHover,
                  ),
                  LayoutCellRegion(
                    CellRegionSide.RIGHT,
                    onHover: onHover,
                  ),
                ],
              ),
            ),
            LayoutCellRegion(
              CellRegionSide.BOTTOM,
              onHover: onHover,
            ),
          ],
        ),
      ],
    );
  }
}

class LayoutCellRegion extends StatefulWidget {
  const LayoutCellRegion(
    this.side, {
    super.key,
    this.flex = 1,
    this.baseColor,
    required this.onHover,
  });

  final int flex;
  final CellRegionSide side;
  final Color? baseColor;
  final Function(Size?, CellRegionSide?) onHover;

  @override
  State<LayoutCellRegion> createState() => _LayoutCellRegionState();
}

class _LayoutCellRegionState extends State<LayoutCellRegion> {
  Color? color;

  @override
  void initState() {
    super.initState();
    color = widget.baseColor;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            color = Colors.amber[100]!.withAlpha(80);
            final size = (context.findRenderObject() as RenderBox).size;
            widget.onHover(size, widget.side);
          });
        },
        onExit: (_) {
          setState(() {
            color = widget.baseColor;
            widget.onHover(null, null);
          });
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: color,
        ),
      ),
    );
  }
}
