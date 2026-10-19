/// Identification shown in the patient PDFs (Imprimir and Reporte).
///
/// The profile only stores the number (`users.identidad`), not the document
/// type, so the label is generic.
const kTipoIdentificacionPdf = 'Documento';

/// Document number from a `users` document, or 'No registrado' when empty.
String numeroIdentificacionPdf(Map<String, dynamic>? data) {
  final identidad = data?['identidad']?.toString().trim() ?? '';
  return identidad.isEmpty ? 'No registrado' : identidad;
}
