import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/backend/schema/colegios_record.dart';
import 'package:conecta2/backend/schema/shared/ubicacion_colegio.dart';
import 'package:conecta2/components/ubicacion_colegio/ubicacion_colegio_readonly.dart';

/// Referencia mínima para construir un [ColegiosRecord] sin Firebase.
class _FakeRef implements DocumentReference<Map<String, dynamic>> {
  _FakeRef(this.path);

  @override
  final String path;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ColegiosRecord _colegio(String nombre, String barrio, String municipio) =>
    ColegiosRecord.getDocumentFromData(
      {'nombre': nombre, 'barrio': barrio, 'municipio': municipio},
      _FakeRef('colegios/$nombre-$barrio'),
    );

void main() {
  // Datos tomados de la colección `colegios` (prueba, 2026-10-16).
  final colegios = [
    _colegio('COL. ANTARES DE CARTAGENA', 'MANGA', 'CARTAGENA'),
    _colegio('COL. ANTARES DE CARTAGENA', 'MANGA', 'CARTAGENA'),
    _colegio(' I.E. SOLEDAD ACOSTA ', ' PIEDRA DE BOLÍVAR', 'CARTAGENA '),
    _colegio('COL. SIN BARRIO', '', 'CARTAGENA'),
  ];

  group('ubicacionDeColegio', () {
    test('devuelve municipio y barrio del colegio', () {
      expect(ubicacionDeColegio(colegios, 'COL. ANTARES DE CARTAGENA'),
          (municipio: 'CARTAGENA', barrio: 'MANGA'));
    });

    test('ignora espacios extremos en el nombre y en los datos', () {
      expect(ubicacionDeColegio(colegios, 'I.E. SOLEDAD ACOSTA'),
          (municipio: 'CARTAGENA', barrio: 'PIEDRA DE BOLÍVAR'));
    });

    test('colegio sin barrio registrado → barrio vacío', () {
      expect(ubicacionDeColegio(colegios, 'COL. SIN BARRIO'),
          (municipio: 'CARTAGENA', barrio: ''));
    });

    test('vacío o fuera del catálogo → null', () {
      expect(ubicacionDeColegio(colegios, null), isNull);
      expect(ubicacionDeColegio(colegios, '  '), isNull);
      expect(ubicacionDeColegio(colegios, 'NO EXISTE'), isNull);
    });
  });

  test('nombresDeColegios: sin repetidos ni vacíos y en orden', () {
    expect(
      nombresDeColegios([...colegios, _colegio('', 'X', 'Y')]),
      [' I.E. SOLEDAD ACOSTA ', 'COL. ANTARES DE CARTAGENA', 'COL. SIN BARRIO'],
    );
  });

  group('UbicacionColegioReadonly', () {
    Future<void> pump(WidgetTester tester, Widget w) => tester.pumpWidget(
          MaterialApp(home: Scaffold(body: SizedBox(width: 600, child: w))),
        );

    testWidgets('sin colegio: pide elegir uno y no hay campos editables',
        (tester) async {
      await pump(
        tester,
        const UbicacionColegioReadonly(
            municipio: '', barrio: '', colegioElegido: false),
      );
      expect(find.text('Elige un colegio'), findsNWidgets(2));
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
      expect(find.textContaining('Se completan automáticamente'), findsOneWidget);
    });

    testWidgets('con colegio muestra su municipio y barrio', (tester) async {
      await pump(
        tester,
        const UbicacionColegioReadonly(
            municipio: 'CARTAGENA', barrio: 'MANGA', colegioElegido: true),
      );
      expect(find.text('CARTAGENA'), findsOneWidget);
      expect(find.text('MANGA'), findsOneWidget);
    });

    testWidgets('colegio sin barrio registrado avisa', (tester) async {
      await pump(
        tester,
        const UbicacionColegioReadonly(
            municipio: 'CARTAGENA',
            barrio: '',
            colegioElegido: true,
            compacto: true),
      );
      expect(find.text('—'), findsOneWidget);
      expect(find.textContaining('no tiene barrio o municipio registrado'),
          findsOneWidget);
    });
  });
}
