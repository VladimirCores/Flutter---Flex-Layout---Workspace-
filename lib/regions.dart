import 'package:flutter/material.dart';
import 'package:workspace/consts/enums.dart';
import 'package:workspace/panel.dart';

const FULL_HEIGHT_SIDES = [
  PanelRegionSide.RIGHT,
  PanelRegionSide.LEFT,
  PanelRegionSide.CENTER,
];

class WorkspaceRegions extends StatefulWidget {
  const WorkspaceRegions(
    this.panel,
    this.selectedPanel,
    this.selectedCellRegionSide, {
    super.key,
  });

  final WorkspacePanel panel;
  final WorkspacePanel selectedPanel;
  final ValueNotifier<({WorkspacePanel? panel, PanelRegionSide? side})?> selectedCellRegionSide;

  @override
  State<WorkspaceRegions> createState() => _WorkspaceRegionsState();
}

class _WorkspaceRegionsState extends State<WorkspaceRegions> {
  final ValueNotifier<PanelRegionSide?> _side = ValueNotifier(null);
  PanelRegionSide? _connectedCellSide;
  Size? _size;

  List<bool> allowedSides = [true, true, true, true];

  void onInside(Size size, PanelRegionSide? side) {
    print('> LayoutRegions -> onInside: ${side} | ${size}');
    _size = size;
    _side.value = side;
    widget.selectedCellRegionSide.value = (panel: widget.panel, side: side);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final currentPanel = widget.panel;
    final selectedPanel = widget.selectedPanel;
    final panelSideIndex = currentPanel.findCellSideIndex(selectedPanel);
    if (panelSideIndex > -1) {
      _connectedCellSide = PanelRegionSide.values[panelSideIndex];
      allowedSides[panelSideIndex] = false;
      print('> LayoutRegions -> initState - Cell position: ${panelSideIndex} | $_connectedCellSide');
    }
    if (widget.panel.isRoot) {
      allowedSides[PanelRegionSide.LEFT.index] = false;
      allowedSides[PanelRegionSide.TOP.index] = false;
      allowedSides[PanelRegionSide.RIGHT.index] = !widget.panel.hasRight;
      allowedSides[PanelRegionSide.BOTTOM.index] = !widget.panel.hasBottom;
    } else {
      final hasTwoRowsConnection = currentPanel.hasBottom && currentPanel.hasRight;
      allowedSides[PanelRegionSide.RIGHT.index] = !hasTwoRowsConnection && currentPanel.right != selectedPanel;
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
            double? top = PanelRegionSide.BOTTOM != side ? 0 : currentSize.height - _size!.height;
            double? left = PanelRegionSide.RIGHT != side ? 0 : currentSize.width - _size!.width;
            final isFullCellHeight = FULL_HEIGHT_SIDES.contains(side);
            final isSideCenter = PanelRegionSide.CENTER == side;
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
        PanelRegions(onInside, allowedSides),
      ],
    );
  }
}

class PanelRegions extends StatelessWidget {
  const PanelRegions(this.onInside, this.allowedSides, {Key? key}) : super(key: key);

  final Function(Size, PanelRegionSide?) onInside;
  final List<bool> allowedSides;

  @override
  Widget build(BuildContext context) {
    final hasTop = allowedSides[PanelRegionSide.TOP.index];
    final hasRight = allowedSides[PanelRegionSide.RIGHT.index];
    final hasBottom = allowedSides[PanelRegionSide.BOTTOM.index];
    final hasLeft = allowedSides[PanelRegionSide.LEFT.index];
    final verticalFlex = 2 + (hasTop ? 0 : 1) + (hasBottom ? 0 : 1);
    final horizontalFlex = 2 + (hasLeft ? 0 : 1) + (hasRight ? 0 : 1);
    return Column(
      children: [
        if (hasTop)
          WorkspacePanelRegion(
            PanelRegionSide.TOP,
            onInside: onInside,
          ),
        Expanded(
          flex: verticalFlex,
          child: Row(
            children: [
              if (hasLeft)
                WorkspacePanelRegion(
                  PanelRegionSide.LEFT,
                  onInside: onInside,
                ),
              WorkspacePanelRegion(
                flex: horizontalFlex,
                PanelRegionSide.CENTER,
                onInside: onInside,
              ),
              if (hasRight)
                WorkspacePanelRegion(
                  PanelRegionSide.RIGHT,
                  onInside: onInside,
                ),
            ],
          ),
        ),
        if (hasBottom)
          WorkspacePanelRegion(
            PanelRegionSide.BOTTOM,
            onInside: onInside,
          ),
      ],
    );
  }
}

class WorkspacePanelRegion extends StatelessWidget {
  const WorkspacePanelRegion(
    this.side, {
    super.key,
    this.flex = 1,
    required this.onInside,
  });

  final int flex;
  final PanelRegionSide side;
  final Function(Size, PanelRegionSide?) onInside;

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
