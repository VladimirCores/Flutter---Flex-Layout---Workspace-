import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/layout_cell.dart';
import 'package:workspace_layout/consts/enums.dart';

const FULL_HEIGHT_SIDES = [
  CellRegionSide.RIGHT,
  CellRegionSide.LEFT,
  CellRegionSide.CENTER,
];

class LayoutRegions extends StatefulWidget {
  const LayoutRegions(
    this.cell,
    this.selectedCell,
    this.selectedCellRegionSide, {
    super.key,
  });

  final LayoutCell cell;
  final LayoutCell selectedCell;
  final ValueNotifier<({LayoutCell? cell, CellRegionSide? side})?> selectedCellRegionSide;

  @override
  State<LayoutRegions> createState() => _LayoutRegionsState();
}

class _LayoutRegionsState extends State<LayoutRegions> {
  final ValueNotifier<CellRegionSide?> _side = ValueNotifier(null);
  CellRegionSide? _connectedCellSide;
  Size? _size;

  List<bool> allowedSides = [true, true, true, true];

  void onInside(Size size, CellRegionSide? side) {
    print('> LayoutRegions -> onInside: ${side} | ${size}');
    _size = size;
    _side.value = side;
    widget.selectedCellRegionSide.value = (cell: widget.cell, side: side);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final cellSideIndex = widget.cell.findCellSideIndex(widget.selectedCell);
    if (cellSideIndex > -1) {
      _connectedCellSide = CellRegionSide.values[cellSideIndex];
      allowedSides[cellSideIndex] = false;
      print('> LayoutRegions -> initState - Cell position: ${cellSideIndex} | $_connectedCellSide');
    }
    if (widget.cell.isRoot) {
      allowedSides[CellRegionSide.LEFT.index] = false;
      allowedSides[CellRegionSide.TOP.index] = false;
      allowedSides[CellRegionSide.RIGHT.index] = !widget.cell.hasRight;
      allowedSides[CellRegionSide.BOTTOM.index] = !widget.cell.hasBottom;
    }
    print('> LayoutRegions -> initState - allowedSides: ${allowedSides}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: _side,
          builder: (_, side, __) {
            final skipHighlight = side == null;
            if (skipHighlight) return Container();
            final currentSize = (context.findRenderObject() as RenderBox).size;
            double? top = CellRegionSide.BOTTOM != side ? 0 : currentSize.height - _size!.height;
            double? left = CellRegionSide.RIGHT != side ? 0 : currentSize.width - _size!.width;
            final isFullCellHeight = FULL_HEIGHT_SIDES.contains(side);
            final isSideCenter = CellRegionSide.CENTER == side;
            return Positioned(
              top: top,
              left: left,
              child: Container(
                width: isSideCenter ? currentSize.width : _size!.width,
                height: isFullCellHeight ? currentSize.height : _size!.height,
                alignment: Alignment.center,
                color: Colors.black.withAlpha(60),
              ),
            );
          },
        ),
        CellRegions(onInside, allowedSides),
      ],
    );
  }
}

class CellRegions extends StatelessWidget {
  const CellRegions(this.onInside, this.allowedSides, {Key? key}) : super(key: key);

  final Function(Size, CellRegionSide?) onInside;
  final List<bool> allowedSides;

  @override
  Widget build(BuildContext context) {
    final hasTop = allowedSides[CellRegionSide.TOP.index];
    final hasRight = allowedSides[CellRegionSide.RIGHT.index];
    final hasBottom = allowedSides[CellRegionSide.BOTTOM.index];
    final hasLeft = allowedSides[CellRegionSide.LEFT.index];
    final verticalFlex = 2 + (hasTop ? 0 : 1) + (hasBottom ? 0 : 1);
    final horizontalFlex = 2 + (hasLeft ? 0 : 1) + (hasRight ? 0 : 1);
    return Column(
      children: [
        if (hasTop)
          LayoutCellRegion(
            CellRegionSide.TOP,
            onInside: onInside,
          ),
        Expanded(
          flex: verticalFlex,
          child: Row(
            children: [
              if (hasLeft)
                LayoutCellRegion(
                  CellRegionSide.LEFT,
                  onInside: onInside,
                ),
              LayoutCellRegion(
                flex: horizontalFlex,
                CellRegionSide.CENTER,
                onInside: onInside,
              ),
              if (hasRight)
                LayoutCellRegion(
                  CellRegionSide.RIGHT,
                  onInside: onInside,
                ),
            ],
          ),
        ),
        if (hasBottom)
          LayoutCellRegion(
            CellRegionSide.BOTTOM,
            onInside: onInside,
          ),
      ],
    );
  }
}

class LayoutCellRegion extends StatelessWidget {
  const LayoutCellRegion(
    this.side, {
    super.key,
    this.flex = 1,
    required this.onInside,
  });

  final int flex;
  final CellRegionSide side;
  final Function(Size, CellRegionSide?) onInside;

  void _onInside(BuildContext context, bool isEnter) {
    onInside((context.findRenderObject() as RenderBox).size, isEnter ? side : null);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: MouseRegion(
        onEnter: (_) => _onInside(context, true),
        onExit: (_) => _onInside(context, false),
        child: const SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
        ),
      ),
    );
  }
}
