// Validación de un contenido antes de guardarlo o publicarlo (Crear y
// Editar). Lógica pura, sin Flutter ni Firestore, para poder probarla.

/// Título que pone el sistema a un contenido recién creado.
const String kTituloContenidoVacio = 'Vacío';

/// Texto visible del cuerpo: quita el comentario `<!-- quill-delta … -->`
/// que guarda el editor, las etiquetas HTML y los espacios.
String textoVisibleHtml(String? html) {
  if (html == null || html.isEmpty) return '';
  return html
      .replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _tituloValido(String? titulo) {
  final t = (titulo ?? '').trim();
  return t.isNotEmpty && t != kTituloContenidoVacio;
}

/// Lo que falta para publicar. Lista vacía = se puede publicar.
List<String> faltantesParaPublicar({
  required String? titulo,
  required String? html,
  required List<String>? roles,
}) =>
    [
      if (!_tituloValido(titulo)) 'el título',
      if (textoVisibleHtml(html).isEmpty) 'el texto del contenido',
      if (roles == null || roles.isEmpty) 'a quién va dirigido',
    ];

/// Lo que falta para guardar como borrador. Lista vacía = se puede guardar.
List<String> faltantesParaBorrador({required String? titulo}) =>
    [if (!_tituloValido(titulo)) 'el título'];

/// Mensaje para el aviso: "Falta el título y el texto del contenido."
String mensajeFaltantes(List<String> faltantes) {
  if (faltantes.isEmpty) return '';
  final lista = faltantes.length == 1
      ? faltantes.first
      : '${faltantes.sublist(0, faltantes.length - 1).join(', ')} y ${faltantes.last}';
  return 'Falta $lista.';
}
