import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/layout_cell.dart';

class CellHeader extends StatefulWidget {
  const CellHeader({
    super.key,
    this.height = 32,
    required this.cell,
    required this.title,
    required this.onCellSelected,
  });

  final double height;
  final String title;
  final LayoutCell cell;
  final ValueNotifier<LayoutCell?> onCellSelected;

  @override
  State<CellHeader> createState() => _CellHeaderState();
}

class _CellHeaderState extends State<CellHeader> {
  bool isCloseButtonHover = false;

  @override
  Widget build(BuildContext context) {
    var color = Colors.transparent;
    return Material(
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: color,
          splashColor: color,
          hoverColor: color,
        ),
        child: Container(
          width: double.maxFinite,
          color: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Listener(
                  onPointerDown: (_) {
                    print('onDown');
                    widget.onCellSelected.value = widget.cell;
                  },
                  onPointerUp: (_) {
                    print('onUp');
                    widget.onCellSelected.value = null;
                  },
                  child: Row(children: [
                    Text(widget.title),
                    const SizedBox(width: 4),
                    StatefulBuilder(
                      builder: (_, setState) {
                        return InkWell(
                          onHover: (_) {
                            setState(() {
                              isCloseButtonHover = !isCloseButtonHover;
                            });
                          },
                          onTap: () {},
                          child: Icon(
                            Icons.close,
                            weight: 700,
                            size: 16.0,
                            color: isCloseButtonHover ? Colors.black87 : Colors.black26,
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
