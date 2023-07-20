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
  CellRegionSide? _cellSide;
  Size? _size;

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
      _cellSide = CellRegionSide.values[cellSideIndex];
      print('> LayoutRegions -> initState - Cell position: ${cellSideIndex} | $_cellSide');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: _side,
          builder: (_, side, __) {
            final skipHighlight = side == null || _size == null || _cellSide == side;
            if (skipHighlight) return Container();
            final currentSize = (context.findRenderObject() as RenderBox).size;
            double? top = CellRegionSide.BOTTOM != side ? 0 : currentSize.height - _size!.height;
            double? left = CellRegionSide.RIGHT != side ? 0 : currentSize.width - _size!.width;
            final isFullCellHeight = FULL_HEIGHT_SIDES.contains(side);
            return Positioned(
              top: top,
              left: left,
              child: Container(
                width: CellRegionSide.CENTER == side ? currentSize.width : _size!.width,
                height: isFullCellHeight ? currentSize.height : _size!.height,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withAlpha(70), width: 1),
                    color: Colors.black.withAlpha(60),
                  ),
                ),
              ),
            );
          },
        ),
        CellRegions(onInside),
      ],
    );
  }
}

class CellRegions extends StatelessWidget {
  const CellRegions(this.onInside, {Key? key}) : super(key: key);

  final Function(Size, CellRegionSide?) onInside;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutCellRegion(
          CellRegionSide.TOP,
          onInside: onInside,
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              LayoutCellRegion(
                CellRegionSide.LEFT,
                onInside: onInside,
              ),
              LayoutCellRegion(
                flex: 2,
                CellRegionSide.CENTER,
                onInside: onInside,
              ),
              LayoutCellRegion(
                CellRegionSide.RIGHT,
                onInside: onInside,
              ),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: MouseRegion(
        onEnter: (_) => onInside((context.findRenderObject() as RenderBox).size, side),
        onExit: (_) => onInside((context.findRenderObject() as RenderBox).size, null),
        child: const SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
        ),
      ),
    );
  }
}
