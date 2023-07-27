import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/layout_cell.dart';
import 'package:workspace_layout/inherited.dart';
import 'package:workspace_layout/layout.dart';

void main() {
  runApp(WorkspaceLayout());
}

class WorkspaceLayout extends StatelessWidget {
  WorkspaceLayout({super.key}) {
    // generateCell() => LayoutCell(colorCode: rndColorCode());
    generateCell([String title = '']) => LayoutCell(widget: Text(title));
    final c1 = generateCell("1");
    final c2 = generateCell('2');
    final c3 = generateCell("3");
    final c4 = generateCell();
    final c5 = generateCell();
    final c6 = generateCell();

    layout.add(generateCell('0'));

    layout.addRight(layout.chain, c1);
    layout.addBottom(layout.chain, c2);
    layout.addRight(c2, generateCell('2-right'));
    layout.addBottom(c2, generateCell('2-bottom'));

    layout.addBottom(layout.addBottom(c1, generateCell('1-bottom')), generateCell('1-bottom-bottom'));
    //
    // layout.addRight(c3, c4);
    // layout.addRight(c4, generateCell());
    // //
    // layout.addRight(c1, c2);
    // layout.addBottom(c2, c5);
    //
    // layout.addRight(c5, c6);
    // layout.addBottom(c6, generateCell());
  }

  final Layout layout = Layout();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkspaceGrid',
      theme: ThemeData(scaffoldBackgroundColor: Colors.black12),
      home: Scaffold(
        body: LayoutInherited(
          layout: layout,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ValueListenableBuilder(
                valueListenable: layout.cells,
                builder: (_, List<LayoutCell> value, __) {
                  return layout.positionWidgetsFrom(
                    layout.chain,
                    parentWidth: constraints.maxWidth,
                    parentHeight: constraints.maxHeight,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
