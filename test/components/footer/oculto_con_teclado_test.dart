import 'package:conecta2/components/oculto_con_teclado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const menu = Key('menu');
  double? insetEnBody;

  Widget pantalla() => MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            insetEnBody = MediaQuery.viewInsetsOf(context).bottom;
            return const Stack(children: [
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: OcultoConTeclado(
                  child: SizedBox(key: menu, height: 75.0),
                ),
              ),
            ]);
          }),
        ),
      );

  testWidgets('el menú se oculta con el teclado y vuelve al cerrarlo',
      (tester) async {
    addTearDown(tester.view.reset);
    await tester.pumpWidget(pantalla());
    expect(find.byKey(menu), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300.0);
    await tester.pump();
    expect(find.byKey(menu), findsNothing);

    tester.view.resetViewInsets();
    await tester.pump();
    expect(find.byKey(menu), findsOneWidget);
  });

  testWidgets('dentro del body del Scaffold MediaQuery no ve el teclado',
      (tester) async {
    addTearDown(tester.view.reset);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300.0);
    await tester.pumpWidget(pantalla());
    // Por esto la comprobación anterior con MediaQuery nunca ocultaba el menú.
    expect(insetEnBody, 0.0);
    expect(find.byKey(menu), findsNothing);
  });
}
