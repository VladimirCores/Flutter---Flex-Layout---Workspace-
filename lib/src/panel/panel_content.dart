part of workspace;

class PanelContent extends StatelessWidget {
  const PanelContent(
    this.panel,
    this.onHeaderPointerUp,
    this.onHeaderPointerDown,
    this.onHeaderRemove, {
    required this.selectedPanel,
    required this.selectedCellRegionSide,
    Key? key,
  }) : super(key: key);

  final WorkspacePanel panel;
  final Function() onHeaderPointerUp;
  final Function() onHeaderPointerDown;
  final Function(WorkspacePanel) onHeaderRemove;
  final ValueNotifier<WorkspacePanel?> selectedPanel;
  final ValueNotifier<({WorkspacePanel? panel, PanelRegionSide? side})?> selectedCellRegionSide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        panel.widgetHeader ??
            PanelHeader(
              title: 'Panel',
              onPointerDown: onHeaderPointerDown,
              onPointerUp: onHeaderPointerUp,
              onRemove: !panel.isRoot ? () => onHeaderRemove(panel) : null,
            ),
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              panel.widgetContent ?? Container(),
              ValueListenableBuilder(
                valueListenable: selectedPanel,
                builder: (_, WorkspacePanel? selected, __) {
                  final hasSelected = selected != null;
                  final isDifferent = selected != panel;
                  // // print('> panelContent -> hasSelected: ${hasSelected}');
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
