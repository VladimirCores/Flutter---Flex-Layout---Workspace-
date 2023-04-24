import 'package:flutter/material.dart';

class LayoutRegions extends StatefulWidget {
  const LayoutRegions({
    super.key,
  });

  @override
  State<LayoutRegions> createState() => _LayoutRegionsState();
}

class _LayoutRegionsState extends State<LayoutRegions> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LayoutCellRegion(),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              LayoutCellRegion(),
              LayoutCellRegion(flex: 3),
              LayoutCellRegion(),
            ],
          ),
        ),
        LayoutCellRegion(),
      ],
    );
  }
}

class LayoutCellRegion extends StatefulWidget {
  const LayoutCellRegion({
    super.key,
    this.baseColor,
    this.flex = 1,
  });

  final Color? baseColor;
  final int flex;

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
            color = Colors.amber[100];
          });
        },
        onExit: (_) {
          setState(() {
            color = widget.baseColor;
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
