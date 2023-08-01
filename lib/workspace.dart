import 'package:flutter/material.dart';
import 'package:workspace/consts/enums.dart';
import 'package:workspace/handler.dart';
import 'package:workspace/panel.dart';
import 'package:workspace/panel/panel_header.dart';
import 'package:workspace/regions.dart';

class WorkspaceHandleParams {
  final ValueNotifier<double> resizer;
  final double parentSize;
  final double size;
  final bool isHorizontal;

  WorkspaceHandleParams(this.resizer, this.parentSize, this.size, this.isHorizontal);
}

class WorkspacePanelParams {
  final WorkspacePanel panel;
  final double parentWidth;
  final double parentHeight;

  final WorkspaceHandleParams handleParams;

  WorkspacePanelParams(
    this.panel,
    this.parentWidth,
    this.parentHeight,
    this.handleParams,
  );
}

class Workspace {
  Workspace();

  int xCount = 0;
  int yCount = 0;

  final ValueNotifier<List<WorkspacePanel>> _items = ValueNotifier([]);

  final ValueNotifier<WorkspacePanel?> selectedPanel = ValueNotifier(null);
  final ValueNotifier<({WorkspacePanel? panel, PanelRegionSide? side})?> selectedCellRegionSide = ValueNotifier(null);

  WorkspacePanel get root => _items.value.first;
  ValueNotifier<List<WorkspacePanel>> get panels => _items;

  _breakPrevious(WorkspacePanel panel) {
    if (panel.previous?.right == panel) panel.previous!.right = null;
    if (panel.previous?.bottom == panel) panel.previous!.bottom = null;
  }

  WorkspacePanel add(WorkspacePanel panel) {
    if (!_items.value.contains(panel)) {
      _items.value.add(panel);
    }
    return panel;
  }

  WorkspacePanel addRight(WorkspacePanel to, WorkspacePanel gc) {
    _breakPrevious(gc);
    to.right = gc;
    gc.previous = to;
    return add(gc);
  }

  WorkspacePanel addBottom(WorkspacePanel to, WorkspacePanel panel) {
    _breakPrevious(panel);
    if (to.hasBottom) {
      if (panel.hasBottom && !panel.isRoot) {
        panel.previous!.bottom = panel.bottom;
      }
      panel.bottom = to.bottom;
    }
    to.bottom = panel;
    panel.previous = to;
    return add(panel);
  }

  _connectRightToBottomMostRight(WorkspacePanel panel, WorkspacePanel panelBottom, double handleSize) {
    WorkspacePanel? right = panelBottom;
    double parentWidth = panel.parentWidth;
    print('parent width = ${parentWidth}');
    while (right != null) {
      final rightWidthRelative = right.absoluteWidth / parentWidth;
      print('right width = ${rightWidthRelative} | ${right.width} | ${right.absoluteWidth}');
      right.parentWidth = parentWidth;
      right.width = rightWidthRelative;
      parentWidth -= right.absoluteWidth + handleSize;
      right = right.right;
    }
    final bottomMostRight = panelBottom.findMostRight();
    bottomMostRight.right = panel.right;
  }

  _rearrangeConnectionWithPrevious(
    WorkspacePanel prev,
    WorkspacePanel panel,
    double handleSize, [
    isRemoveFromPreviousBottom = true,
  ]) {
    print('> \t -> rearrange: isRemoveFromPreviousBottom = ${isRemoveFromPreviousBottom}');
    final hasBottomOnCell = panel.bottom != null;
    final hasRightOnCell = panel.right != null;
    final isHorizontal = panel.isHorizontal;
    print('> \t\t -> isHorizontal: ${isHorizontal}');
    print('> \t\t -> hasBottomOnCell = ${hasBottomOnCell}');
    print('> \t\t -> hasRightOnCell: ${hasRightOnCell}');
    if (hasBottomOnCell) {
      final panelBottom = panel.bottom!;
      if (isRemoveFromPreviousBottom) {
        prev.bottom = panelBottom;
        final shouldConnectRightToBottomRight = hasRightOnCell && panelBottom.hasRight;
        print('> \t\t\t -> shouldConnectRightToBottomRight: ${shouldConnectRightToBottomRight}');
        if (shouldConnectRightToBottomRight) {
          _connectRightToBottomMostRight(panel, panelBottom, handleSize);
        } else {
          if (hasRightOnCell) {
            print('> \t\t\t -> but panel has');
            panelBottom.right = panel.right;
            panelBottom.absoluteWidth = panel.absoluteWidth;
            panelBottom.width = panel.width;
          }
        }
      } else {
        final shouldShiftRightToLeft = panel.isHorizontal && hasRightOnCell;
        print('> \t\t\t -> shouldShiftRightToLeft: ${shouldShiftRightToLeft}');
        if (shouldShiftRightToLeft) {
          final panelRight = panel.right!;
          prev.right = panelRight;
          final shouldConnectBottomToRightBottom = panelRight.bottom != null;
          print('> \t\t\t -> shouldConnectBottomToRightBottom: ${shouldConnectBottomToRightBottom}');
          if (shouldConnectBottomToRightBottom) {
            final rightMostBottom = panelRight.findMostBottom();
            rightMostBottom.bottom = panelBottom;
          } else {
            panelRight.bottom = panelBottom;
          }
          panelRight.height = -1;
        } else {
          final shouldConnectRightToBottomRight = hasRightOnCell && panelBottom.hasRight;
          print('> \t\t\t -> shouldConnectRightToBottomRight: ${shouldConnectRightToBottomRight}');
          print('> \t\t\t -> panel width: ${panel.width}');
          print('> \t\t\t -> panelBottom width: ${panelBottom.width}');
          prev.right = panelBottom;
          if (shouldConnectRightToBottomRight) {
            _connectRightToBottomMostRight(panel, panelBottom, handleSize);
          } else {
            print('> \t\t\t -> panel bottom has no right');
            if (hasRightOnCell) {
              print('> \t\t\t -> panelBottom.isHorizontal = ${panelBottom.isHorizontal}');
              if (panelBottom.isHorizontal) {
                final tempCellBottomBottom = panelBottom.bottom;
                panelBottom.bottom = null;
                panelBottom.right = panel.right;
                panelBottom.bottom = tempCellBottomBottom;
              } else {
                print('> \t\t\t -> but panel has');
                panelBottom.right = panel.right;
              }
              panelBottom.absoluteWidth = panel.absoluteWidth;
              panelBottom.width = panel.width;
            }
          }
        }
      }
    } else if (hasRightOnCell) {
      final panelRight = panel.right!;
      print('> \t\t -> remove - right only');
      if (isRemoveFromPreviousBottom) {
        // print('> \t\t\t -> isPreviousHorizontal (before): ${isPreviousHorizontal}');
        prev.bottom = panelRight;
        // print('> \t\t\t -> isPreviousHorizontal (after): ${prev.isHorizontal}');
      } else {
        prev.right = panelRight;
      }
      panelRight.parentWidth = panel.parentWidth;
      panelRight.width = panel.width + (panelRight.absoluteWidth + handleSize) / panel.parentWidth;
    } else {
      print('> \t\t -> remove - no further connections');
      if (isRemoveFromPreviousBottom) {
        prev.bottom = null;
        prev.height = -1;
      } else {
        prev.right = null;
        prev.width = -1;
      }
    }
  }

  void removeCell(WorkspacePanel deletePanel, double handleSize, {keep = false, willBecomeRoot = false}) {
    print('> Layout -> removeCell: keep = ${keep}');
    final previous = deletePanel.previous;
    final hasPrevious = previous != null;
    print('> \t -> hasPrevious = ${hasPrevious}');
    if (hasPrevious) {
      final isFromBottom = previous.bottom == deletePanel;
      _rearrangeConnectionWithPrevious(
        previous,
        deletePanel,
        handleSize,
        isFromBottom,
      );
      deletePanel.clearConnection();
    }
    if (keep) {
      if (willBecomeRoot) {
        _items.value.remove(deletePanel);
        _items.value.insert(0, deletePanel);
      }
      _items.notifyListeners();
    } else {
      _items.value = _items.value.where((el) => el != deletePanel).toList();
    }
  }

  List<Widget> createNextSideWithHandler(WorkspacePanelParams params) {
    return [
      Handler(params.handleParams),
      positionWidgetsFrom(
        params.panel,
        parentWidth: params.parentWidth,
        parentHeight: params.parentHeight,
      ),
    ];
  }

  Widget positionWidgetsFrom(
    WorkspacePanel panel, {
    required double parentWidth,
    required double parentHeight,
    double handlerSize = 4,
  }) {
    final hasRight = panel.right != null;
    final hasBottom = panel.bottom != null;

    final hasWidth = panel.width > 0;
    final hasHeight = panel.height > 0;

    final double handleSizeX = (hasRight ? handlerSize : 0);
    final double handleSizeY = (hasBottom ? handlerSize : 0);

    panel.parentWidth = parentWidth;
    panel.parentHeight = parentHeight;

    final initialWidth = hasWidth ? panel.width * parentWidth : (parentWidth / (hasRight ? 2 : 1) - handleSizeX);
    final initialHeight = hasHeight ? panel.height * parentHeight : (parentHeight / (hasBottom ? 2 : 1) - handleSizeY);

    // print(
    //     '(${hasHeight ? 'hasHeight(${panel.height})' : 'noHeight'}:${hasWidth ? 'hasWidth(${panel.width})' : 'noWidth'}) '
    //     // '(${hasBottom ? 'hasBottom' : 'noBottom'}:${hasRight ? 'hasRight' : 'noRight'}) ',
    //     );

    ValueNotifier<double> horizontalResizer = ValueNotifier(initialWidth);
    ValueNotifier<double> verticalResizer = ValueNotifier(initialHeight);

    final isHorizontal = panel.isHorizontal;

    return Container(
      width: parentWidth,
      height: parentHeight,
      color: panel.colorCode,
      child: ValueListenableBuilder(
        valueListenable: isHorizontal ? verticalResizer : horizontalResizer,
        builder: (_, double blockHeightWidth, __) {
          final outerSize = blockHeightWidth > handlerSize ? blockHeightWidth : handlerSize;

          // if (isHorizontal && hasBottom) panel.absoluteHeight = outerSize;
          // if (!isHorizontal && hasRight) panel.absoluteWidth = outerSize;

          return Flex(
            direction: isHorizontal ? Axis.vertical : Axis.horizontal,
            children: [
              ValueListenableBuilder(
                valueListenable: isHorizontal ? horizontalResizer : verticalResizer,
                builder: (_, double blockWidthHeight, __) {
                  final innerSize = blockWidthHeight > handlerSize ? blockWidthHeight : handlerSize;

                  // if (isHorizontal && hasRight) panel.absoluteWidth = innerSize;
                  // if (!isHorizontal && hasBottom) panel.absoluteHeight = innerSize;

                  panel.absoluteWidth = (isHorizontal ? innerSize : outerSize);
                  panel.absoluteHeight = (isHorizontal ? outerSize : innerSize);

                  panel.width = panel.absoluteWidth / parentWidth;
                  panel.height = panel.absoluteHeight / parentHeight;

                  return Flex(
                    direction: isHorizontal ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: panel.absoluteWidth,
                        height: panel.absoluteHeight,
                        child: _buildCellContent(panel, handlerSize),
                      ),
                      if (isHorizontal ? hasRight : hasBottom)
                        ...createNextSideWithHandler(isHorizontal
                            ? WorkspacePanelParams(
                                panel.right!,
                                parentWidth - (innerSize + handleSizeX),
                                outerSize,
                                WorkspaceHandleParams(horizontalResizer, outerSize, handleSizeX, false),
                              )
                            : WorkspacePanelParams(
                                panel.bottom!,
                                outerSize,
                                parentHeight - (innerSize + handleSizeY),
                                WorkspaceHandleParams(verticalResizer, outerSize, handleSizeY, true),
                              )),
                    ],
                  );
                },
              ),
              if (hasBottom || hasRight)
                ...createNextSideWithHandler(isHorizontal
                    ? WorkspacePanelParams(
                        panel.bottom!,
                        parentWidth,
                        parentHeight - (outerSize + handleSizeY),
                        WorkspaceHandleParams(verticalResizer, parentWidth, handleSizeY, true),
                      )
                    : WorkspacePanelParams(
                        panel.right!,
                        parentWidth - (outerSize + handleSizeX),
                        parentHeight,
                        WorkspaceHandleParams(horizontalResizer, parentHeight, handleSizeX, false),
                      ))
            ],
          );
        },
      ),
    );
  }

  final REMOVABLE_SIDES = [
    PanelRegionSide.TOP,
    PanelRegionSide.RIGHT,
    PanelRegionSide.BOTTOM,
    PanelRegionSide.LEFT,
  ];

  Widget _buildCellContent(WorkspacePanel panel, double handlerSize) {
    return Column(
      children: [
        PanelHeader(
          title: 'Cell',
          onPointerDown: () => selectedPanel.value = panel,
          onPointerUp: () {
            final canRearrange = selectedCellRegionSide.value?.side != null && selectedPanel.value != null;
            print('> Layout -> CellHeader - onPointerUp: canRearrange = ${canRearrange}');
            if (canRearrange) {
              final panelSide = selectedCellRegionSide.value?.side;
              final targetPanel = selectedCellRegionSide.value!.panel;
              final movingPanel = selectedPanel.value!;
              final panelSideIndex = targetPanel!.findCellSideIndex(selectedPanel.value!);
              final isMovingCellPrevious = movingPanel == targetPanel.previous;
              final isTargetRoot = targetPanel.previous == null;

              print('> \t panel side: ${panelSide}');
              print('> \t panel index: ${panelSideIndex}');

              final isMovingCellBecomeRoot = isTargetRoot && panelSide == PanelRegionSide.LEFT;

              if (REMOVABLE_SIDES.contains(panelSide)) {
                removeCell(movingPanel, handlerSize, keep: true, willBecomeRoot: isMovingCellBecomeRoot);
              }

              final isTargetHorizontal = targetPanel.isHorizontal;
              final isTargetWithSideConnections = targetPanel.hasRight || targetPanel.hasBottom;

              final isTargetOnBottom = !isTargetRoot && targetPanel.previous!.bottom == targetPanel;
              final isTargetOnRight = !isTargetRoot && targetPanel.previous!.right == targetPanel;

              switch (panelSide) {
                case PanelRegionSide.TOP:
                  if (isTargetRoot) {
                  } else {
                    if (isTargetOnBottom) {
                      targetPanel.previous!.bottom = movingPanel;
                    } else if (isTargetOnRight) {
                      targetPanel.previous!.right = movingPanel;
                    }
                    if (isTargetWithSideConnections) {
                      final right = targetPanel.right;
                      targetPanel.right = null;
                      if (isTargetHorizontal) {
                        movingPanel.bottom = targetPanel;
                        movingPanel.right = right;
                      } else {
                        movingPanel.right = right;
                        movingPanel.bottom = targetPanel;
                      }
                      movingPanel.right?.previous = movingPanel;
                    } else {
                      movingPanel.bottom = targetPanel;
                    }

                    movingPanel.width = targetPanel.width;
                    movingPanel.height = -1;
                    targetPanel.width = -1;
                  }
                  break;
                case PanelRegionSide.BOTTOM:
                  final targetAbsoluteHeight = targetPanel.absoluteHeight;
                  final bottomHeight = 1 / targetPanel.height - 1;
                  final bottomAbsoluteHeight = bottomHeight * targetAbsoluteHeight;
                  final targetAbsoluteHeightAfterMove = targetAbsoluteHeight * 0.5;
                  final bottomAbsoluteHeightAfterMove = bottomAbsoluteHeight + targetAbsoluteHeightAfterMove;

                  movingPanel.bottom = targetPanel.bottom;
                  targetPanel.bottom = movingPanel;

                  print('> \t bottomHeight: ${targetAbsoluteHeight}|${bottomAbsoluteHeight}');
                  targetPanel.absoluteHeight = targetAbsoluteHeightAfterMove;
                  movingPanel.absoluteHeight = targetAbsoluteHeightAfterMove;
                  targetPanel.height *= 0.5;
                  movingPanel.height = (targetPanel.absoluteHeight - handlerSize) / bottomAbsoluteHeightAfterMove;
                  movingPanel.width = -1;
                case PanelRegionSide.RIGHT:
                  print('> RIGHT');
                  final targetAbsoluteWidth = targetPanel.absoluteWidth;
                  final rightWidth = 1 / targetPanel.width - 1;
                  final rightAbsoluteWidth = rightWidth * targetAbsoluteWidth;
                  final targetAbsoluteWidthAfterMove = targetAbsoluteWidth * 0.5;
                  final rightAbsoluteWidthAfterMove = rightAbsoluteWidth + targetAbsoluteWidthAfterMove;

                  print('> \t targetCell.isHorizontal: ${targetPanel.isHorizontal}');
                  print('> \t targetCell.hasRight: ${targetPanel.hasRight}');

                  movingPanel.right = targetPanel.right;
                  targetPanel.right = movingPanel;

                  // if (targetCell.hasBottom) {
                  //   targetCell.switchOrientation();
                  //   if (movingCell.hasRight && movingCell.isHorizontal) {
                  //     movingCell.switchOrientation();
                  //   }
                  // }

                  targetPanel.absoluteWidth = targetAbsoluteWidthAfterMove;
                  movingPanel.absoluteWidth = targetAbsoluteWidthAfterMove;
                  targetPanel.width *= 0.5;
                  if (movingPanel.hasRight) {
                    movingPanel.width = (targetPanel.absoluteWidth - handlerSize) / rightAbsoluteWidthAfterMove;
                  } else {
                    movingPanel.width = -1;
                  }
                  movingPanel.height = -1;
                case PanelRegionSide.LEFT:
                  print('> LEFT: isTargetRoot = ${isTargetRoot}');
                  print('> \t\t isTargetHorizontal = ${isTargetHorizontal}');
                  print('> \t\t movingCell.previous = ${movingPanel.previous}');
                  if (isTargetRoot) {
                    final bottom = targetPanel.bottom;
                    targetPanel.bottom = null;
                    if (isTargetHorizontal) {
                      movingPanel.bottom = bottom;
                      movingPanel.right = targetPanel;
                    } else {
                      movingPanel.right = targetPanel;
                      movingPanel.bottom = bottom;
                    }
                    movingPanel.absoluteWidth = targetPanel.absoluteWidth;
                    movingPanel.width = targetPanel.width = targetPanel.width * 0.5;
                    movingPanel.height = targetPanel.height;
                  } else {
                    final targetAbsoluteWidth = targetPanel.absoluteWidth;
                    final rightWidth = 1 / targetPanel.width - 1;
                    final rightAbsoluteWidth = rightWidth * targetAbsoluteWidth;
                    final targetAbsoluteWidthAfterMove = targetAbsoluteWidth * 0.5;
                    final rightAbsoluteWidthAfterMove = rightAbsoluteWidth + targetAbsoluteWidthAfterMove;

                    targetPanel.absoluteWidth = movingPanel.absoluteWidth = targetAbsoluteWidthAfterMove;
                    movingPanel.width *= 0.5;

                    if (targetPanel.hasRight) {
                      targetPanel.width = (targetAbsoluteWidthAfterMove - handlerSize) / rightAbsoluteWidthAfterMove;
                    } else {
                      movingPanel.width = targetPanel.width = -1;
                    }
                    print('> \t isTargetOnBottom = ${isTargetOnBottom}');
                    print('> \t isTargetOnRight = ${isTargetOnRight}');
                    if (!isMovingCellPrevious) {
                      if (isTargetOnBottom) {
                        targetPanel.previous!.bottom = movingPanel;
                      } else if (isTargetOnRight) {
                        targetPanel.previous!.right = movingPanel;
                      }
                    } else {
                      if (targetPanel.previous!.right == targetPanel) {
                        targetPanel.previous!.right = movingPanel;
                      } else if (targetPanel.previous!.bottom == targetPanel) {
                        targetPanel.previous!.bottom = movingPanel;
                      }
                    }
                    movingPanel.right = targetPanel;
                  }
                  break;
                case PanelRegionSide.CENTER:
                case null:
              }
            }
            selectedPanel.value = null;
            selectedCellRegionSide.value = null;
          },
          onRemove: !panel.isRoot ? () => removeCell(panel, handlerSize) : null,
        ),
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              panel.widget ?? Container(),
              ValueListenableBuilder(
                valueListenable: selectedPanel,
                builder: (_, WorkspacePanel? selected, __) {
                  final hasSelected = selected != null;
                  final isDifferent = selected != panel;
                  // print('> panelContent -> hasSelected: ${hasSelected}');
                  return hasSelected && isDifferent
                      ? WorkspaceRegions(
                          panel,
                          selected,
                          selectedCellRegionSide,
                        )
                      : Container();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
