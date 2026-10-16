import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conecta2/app_state.dart';
import 'package:conecta2/backend/schema/structs/index.dart';
import 'package:conecta2/components/verdaderofalso_widget.dart';

Future<void> _montar(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: VerdaderofalsoWidget(parameter2: 0)),
    ),
  );
  await tester.pump();
}

RespuestaTestStruct get _respuesta => FFAppState().RespuestaEnc[0];

int _marcados(WidgetTester tester) =>
    find.byIcon(Icons.radio_button_checked).evaluate().length;

bool _marcada(WidgetTester tester, String etiqueta) => find
    .ancestor(
      of: find.byIcon(Icons.radio_button_checked),
      matching: find.ancestor(
          of: find.text(etiqueta), matching: find.byType(InkWell)),
    )
    .evaluate()
    .isNotEmpty;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().RespuestaEnc = [
      RespuestaTestStruct(tipo: 'Verdadero o falso', nPregunta: 1),
    ];
  });

  testWidgets('sin responder no hay ninguna opción marcada', (tester) async {
    await _montar(tester);
    expect(find.text('Verdadero'), findsOneWidget);
    expect(find.text('Falso'), findsOneWidget);
    expect(_marcados(tester), 0);
    expect(_respuesta.hasTrueAndFalse(), isFalse);
  });

  testWidgets('las opciones se excluyen y se pueden desmarcar',
      (tester) async {
    await _montar(tester);

    await tester.tap(find.text('Verdadero'));
    await tester.pump();
    expect(_respuesta.trueAndFalse, 1);
    expect(_marcados(tester), 1);
    expect(_marcada(tester, 'Verdadero'), isTrue);

    await tester.tap(find.text('Falso'));
    await tester.pump();
    expect(_respuesta.trueAndFalse, 0);
    expect(_respuesta.hasTrueAndFalse(), isTrue);
    expect(_marcados(tester), 1);
    expect(_marcada(tester, 'Falso'), isTrue);
    expect(_marcada(tester, 'Verdadero'), isFalse);

    // Tocar otra vez la opción marcada la desmarca: queda sin responder.
    await tester.tap(find.text('Falso'));
    await tester.pump();
    expect(_respuesta.hasTrueAndFalse(), isFalse);
    expect(_marcados(tester), 0);
  });

  testWidgets('muestra la respuesta ya guardada', (tester) async {
    FFAppState().updateRespuestaEncAtIndex(0, (e) => e..trueAndFalse = 0);
    await _montar(tester);
    expect(_marcados(tester), 1);
    expect(_marcada(tester, 'Falso'), isTrue);
  });
}
