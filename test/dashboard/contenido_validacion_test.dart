import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/dashboard/web/contenido/contenido_validacion.dart';

const _htmlConTexto =
    '<!-- quill-delta: [{"insert":"Hola\n"}] -->\n<p>Hola</p>';

void main() {
  group('faltantesParaPublicar', () {
    test('contenido completo se puede publicar', () {
      expect(
        faltantesParaPublicar(
            titulo: 'Ansiedad', html: _htmlConTexto, roles: ['Adolescente']),
        isEmpty,
      );
    });

    test('título vacío o "Vacío" no se puede publicar', () {
      for (final t in [null, '', '   ', 'Vacío']) {
        expect(
          faltantesParaPublicar(
              titulo: t, html: _htmlConTexto, roles: ['Adolescente']),
          ['el título'],
        );
      }
    });

    test('cuerpo sin texto visible no se puede publicar', () {
      for (final h in [
        null,
        '',
        '<p><br></p>',
        '<!-- quill-delta: [{"insert":"\n"}] -->\n<p><br/></p>',
        '<p>&nbsp;</p>',
      ]) {
        expect(
          faltantesParaPublicar(
              titulo: 'Ansiedad', html: h, roles: ['Adolescente']),
          ['el texto del contenido'],
          reason: 'html: $h',
        );
      }
    });

    test('sin roles no se puede publicar', () {
      expect(
        faltantesParaPublicar(titulo: 'Ansiedad', html: _htmlConTexto, roles: []),
        ['a quién va dirigido'],
      );
    });

    test('todo vacío lista los tres faltantes', () {
      final f = faltantesParaPublicar(titulo: 'Vacío', html: '', roles: null);
      expect(f.length, 3);
      expect(mensajeFaltantes(f),
          'Falta el título, el texto del contenido y a quién va dirigido.');
    });
  });

  group('faltantesParaBorrador', () {
    test('solo exige el título', () {
      expect(faltantesParaBorrador(titulo: 'Borrador'), isEmpty);
      expect(faltantesParaBorrador(titulo: 'Vacío'), ['el título']);
      expect(mensajeFaltantes(faltantesParaBorrador(titulo: '')),
          'Falta el título.');
    });
  });

  test('textoVisibleHtml quita el comentario del editor y las etiquetas', () {
    expect(textoVisibleHtml(_htmlConTexto), 'Hola');
  });
}
