import 'package:flutter/material.dart';

class PanelHeader extends StatefulWidget {
  const PanelHeader({
    super.key,
    this.height = 32,
    required this.title,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.onRemove,
  });

  final double height;
  final String title;
  final Function() onPointerDown;
  final Function() onPointerUp;
  final Function()? onRemove;

  @override
  State<PanelHeader> createState() => _PanelHeaderState();
}

class _PanelHeaderState extends State<PanelHeader> {
  bool isCloseButtonHover = false;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    var color = Colors.transparent;
    final canInteract = widget.onRemove != null;
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
          color: isSelected ? Colors.lightGreen : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!canInteract)
                  Text(widget.title)
                else
                  Listener(
                    onPointerDown: (_) => setState(() {
                      isSelected = true;
                      widget.onPointerDown();
                    }),
                    onPointerUp: (_) => setState(() {
                      isSelected = false;
                      widget.onPointerUp();
                    }),
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
                            onTap: widget.onRemove,
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
