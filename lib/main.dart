import 'package:flutter/material.dart';
import 'package:workspace_layout/cell/layout_cell.dart';
import 'package:workspace_layout/inherited.dart';
import 'package:workspace_layout/layout.dart';

void main() {
  runApp(WorkspaceLayout());
  // runApp(LinesApp());
}

class LinesApp extends StatelessWidget {
  createLine(double width, color) => Container(width: width, height: 2, color: color);

  @override
  Widget build(BuildContext context) {
    double l = 300;
    double l1 = 500;
    double delta = l / l1;

    double a = l / 3;
    double b = l / 5;
    double c = l - a - b;

    double a1 = a / delta;
    double b1 = b / delta;
    double c1 = l1 - a1 - b1;

    double diff = (l1 / l - 1);
    double a2 = a1 - a * diff;
    double b2 = b1 - b * diff;
    double c2 = l1 - a2 - b2;

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              createLine(a, Colors.red),
              createLine(b, Colors.green),
              createLine(c, Colors.blue),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              createLine(a1, Colors.red),
              createLine(b1, Colors.green),
              createLine(c1, Colors.blue),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              createLine(a2, Colors.red),
              createLine(b2, Colors.green),
              createLine(c2, Colors.blue),
            ]),
          ],
        ),
      ),
    );
  }
}

class WorkspaceLayout extends StatelessWidget {
  WorkspaceLayout({super.key}) {
    // generateCell() => LayoutCell(colorCode: rndColorCode());
    generateCell([String title = '']) => LayoutCell(widget: Text(title));
    final c0 = generateCell('0');
    final c1 = generateCell('1');
    final c2 = generateCell('2');
    final c3 = generateCell("3");
    // final c4 = generateCell("4");
    // final c5 = generateCell("5");
    // final c6 = generateCell("6");

    layout.add(c0);

    layout.addRight(layout.chain, c1);
    layout.addBottom(layout.chain, c2);
    layout.addRight(c2, generateCell('2-r'));
    layout.addBottom(c2, generateCell('2-b'));
    final c1_right = generateCell('1-r');
    layout.addRight(c1, c1_right);
    layout.addRight(c1_right, generateCell('1-r-r'));
    layout.addBottom(c1_right, c3);
    layout.addBottom(c3, generateCell('3-b'));
    final c1_bottom = generateCell('1-b');
    final c1_bottom_bottom = generateCell('1-b-b');
    final c1_bottom_right = generateCell('1-b-r');
    layout.addBottom(c1, c1_bottom);
    layout.addRight(c1_bottom, c1_bottom_right);
    layout.addBottom(c1_bottom, c1_bottom_bottom);
    layout.addRight(c1_bottom_bottom, generateCell('1-b-b-r'));
    layout.addRight(c1_bottom_right, generateCell('1-b-r-r'));
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
