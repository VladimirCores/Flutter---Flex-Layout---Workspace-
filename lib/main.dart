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
    final c0 = generateCell('0');
    final c1 = generateCell('1');
    final c2 = generateCell('2');
    final c3 = generateCell("3");

    layout.add(c0);
    final c2_right = generateCell('2-r');
    layout.addRight(layout.chain, c1);
    layout.addBottom(layout.chain, c2);
    layout.addRight(c2, c2_right);
    // layout.addRight(c2_right, generateCell('2-r-r'));
    // layout.addBottom(c2, generateCell('2-b'));
    final c1_right = generateCell('1-r');
    layout.addRight(c1, c1_right);
    // layout.addRight(c1_right, generateCell('1-r-r'));
    // layout.addBottom(c1_right, c3);
    // layout.addBottom(c3, generateCell('3-b'));
    // final c1_bottom = generateCell('1-b');
    // final c1_bottom_bottom = generateCell('1-b-b');
    // final c1_bottom_right = generateCell('1-b-r');
    // layout.addBottom(c1, c1_bottom);
    // layout.addRight(c1_bottom, c1_bottom_right);
    // layout.addBottom(c1_bottom, c1_bottom_bottom);
    // layout.addRight(c1_bottom_bottom, generateCell('1-b-b-r'));
    // layout.addRight(c1_bottom_right, generateCell('1-b-r-r'));
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
