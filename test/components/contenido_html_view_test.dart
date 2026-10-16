import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/components/contenido_html_view.dart';

void main() {
  const word = '<p class="MsoNormal"><b>Título</b></p>\n<ol><li>Uno</li></ol>';

  test('fragmento (Word): conserva el HTML y agrega viewport y script', () {
    final doc = documentoConAltura(word, agregarViewport: true);
    expect(doc, contains(word));
    expect(doc, contains('name="viewport"'));
    expect(doc, contains('alturaContenido'));
    expect(doc.indexOf(word), lessThan(doc.indexOf('fin-contenido-c2')));
  });

  test('documento completo: script antes de </body>, estilo antes de </head>',
      () {
    const plantilla = '<!DOCTYPE html><html><head><style>body{margin:0}</style>'
        '</head><body><div class="ql-editor">$word</div></body></html>';
    final doc = documentoConAltura(plantilla, agregarViewport: false);
    expect(doc, contains('<div class="ql-editor">$word</div>'));
    expect(doc, isNot(contains('name="viewport"')));
    expect(doc.indexOf('overflow:hidden'), lessThan(doc.indexOf('</head>')));
    expect(doc.indexOf('fin-contenido-c2'),
        greaterThan(doc.indexOf('</div>')));
    expect(doc.indexOf('fin-contenido-c2'), lessThan(doc.indexOf('</body>')));
    expect(doc.trim().endsWith('</html>'), isTrue);
  });
}
