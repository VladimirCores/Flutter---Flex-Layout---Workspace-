import 'package:flutter/material.dart';
import 'package:workspace_layout/layout.dart';

void main() {
  runApp(WorkspaceLayout());
}

class WorkspaceLayout extends StatelessWidget {
  WorkspaceLayout({super.key}) {
    // generateCell() => LayoutCell(colorCode: rndColorCode());
    generateCell() => LayoutCell();
    final c1 = generateCell();
    final c2 = generateCell();
    final c3 = generateCell();
    final c4 = generateCell();
    final c5 = generateCell();
    final c6 = generateCell();

    layout.add(generateCell());

    layout.addRight(layout.chain, c1);
    layout.addBottom(layout.chain, c3);
    layout.addBottom(c3, generateCell());

    layout.addBottom(layout.addBottom(c1, generateCell()), generateCell());

    layout.addRight(c3, c4);
    layout.addRight(c4, generateCell());
    //
    layout.addRight(c1, c2);
    layout.addBottom(c2, c5);

    layout.addRight(c5, c6);
    layout.addBottom(c6, generateCell());
  }

  final Layout layout = Layout();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkspaceGrid',
      home: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return layout.positionWidgetsFrom(
            layout.chain,
            parentWidth: constraints.maxWidth,
            parentHeight: constraints.maxHeight,
          );
        },
      ),
    );
  }
}
