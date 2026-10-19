// Patient header block and contact info + Firestore data retrieval helpers.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../helpers/pdf_identificacion.dart';
import '../helpers/pdf_styles.dart';

DateTime _extraerFechaSegura(dynamic fecha) {
  try {
    if (fecha != null && fecha is Timestamp) {
      return fecha.toDate();
    }
  } catch (_) {}
  return DateTime.now();
}

Future<Map<String, dynamic>?> obtenerDatosPacienteFirestoreSeguro(
    String userUid) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .get()
        .timeout(const Duration(seconds: 10));

    if (!docSnapshot.exists) return null;

    final data = docSnapshot.data();
    if (data == null || data.isEmpty) return null;

    String displayName = 'Paciente';
    try {
      displayName = data['display_name']?.toString() ?? 'Paciente';
    } catch (_) {}

    final nombreParts = displayName.split(' ');
    final nombres = nombreParts.isNotEmpty ? nombreParts[0] : 'Paciente';
    final apellidos = nombreParts.length > 1
        ? nombreParts.sublist(1).join(' ')
        : 'No registrado';

    String edad = 'N/A';
    try {
      if (data['fecha_nacimiento'] != null) {
        final Timestamp fechaNacimiento = data['fecha_nacimiento'];
        final fechaNac = fechaNacimiento.toDate();
        final ahora = DateTime.now();
        int edadCalculada = ahora.year - fechaNac.year;
        if (ahora.month < fechaNac.month ||
            (ahora.month == fechaNac.month && ahora.day < fechaNac.day)) {
          edadCalculada--;
        }
        edad = edadCalculada.toString();
      }
    } catch (_) {}

    if (edad == 'N/A' && data['edad'] != null) {
      edad = data['edad'].toString();
    }

    String acudienteNombre = 'NO REGISTRADO';
    String acudienteTelefono = 'NO REGISTRADO';
    String acudienteCorreo = 'NO REGISTRADO';
    String acudienteParentesco = 'NO REGISTRADO';

    try {
      if (data['Acudiente'] != null && data['Acudiente'] is Map) {
        final acudienteData = Map<String, dynamic>.from(data['Acudiente']);
        acudienteNombre =
            acudienteData['Nombre']?.toString() ?? 'NO REGISTRADO';
        acudienteTelefono =
            acudienteData['telefono']?.toString() ?? 'NO REGISTRADO';
        acudienteCorreo =
            acudienteData['correo']?.toString() ?? 'NO REGISTRADO';
        acudienteParentesco =
            acudienteData['parentesco']?.toString() ?? 'NO REGISTRADO';
      }
    } catch (_) {}

    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'tipoIdentificacion': kTipoIdentificacionPdf,
      'numeroIdentificacion': numeroIdentificacionPdf(data),
      'edad': edad,
      'genero': data['genero']?.toString() ?? 'NO ESPECIFICADO',
      'municipio': data['municipio']?.toString() ?? 'NO REGISTRADO',
      'barrio': data['barrio']?.toString() ?? 'NO REGISTRADO',
      'telefono': data['phone_number']?.toString() ?? 'NO REGISTRADO',
      'email': data['email']?.toString() ?? 'NO REGISTRADO',
      'eps': data['eps']?.toString() ?? 'NO REGISTRADA',
      'ocupacion': data['rol']?.toString() ?? 'NO REGISTRADA',
      'estadoCivil': 'NO ESPECIFICADO',
      'colegio': data['colegio']?.toString() ?? 'NO REGISTRADO',
      'grado': data['grado']?.toString() ?? 'NO REGISTRADO',
      'rol': data['rol']?.toString() ?? 'Usuario',
      'acudienteNombre': acudienteNombre ?? 'NO REGISTRADO',
      'acudienteTelefono': acudienteTelefono ?? 'NO REGISTRADO',
      'acudienteCorreo': acudienteCorreo ?? 'NO REGISTRADO',
      'acudienteParentesco': acudienteParentesco ?? 'NO REGISTRADO',
      'fechaCreacion': _extraerFechaSegura(data['created_time']),
      'ultimaConexion': _extraerFechaSegura(data['Lastconnectedday']),
    };
  } catch (e) {
    print('  ERROR en obtenerDatosPacienteFirestoreSeguro: $e');
    return null;
  }
}

Map<String, dynamic> generarDatosPersonalesPorDefecto(String userUid) {
  return {
    'nombres': 'Usuario',
    'apellidos': 'No Encontrado',
    'tipoIdentificacion': kTipoIdentificacionPdf,
    'numeroIdentificacion': numeroIdentificacionPdf(null),
    'edad': 'N/A',
    'genero': 'NO ESPECIFICADO',
    'municipio': 'NO REGISTRADO',
    'barrio': 'NO REGISTRADO',
    'telefono': 'NO REGISTRADO',
    'email': 'NO REGISTRADO',
    'eps': 'NO REGISTRADA',
    'ocupacion': 'NO REGISTRADA',
    'estadoCivil': 'NO ESPECIFICADO',
    'colegio': 'NO REGISTRADO',
    'grado': 'NO REGISTRADO',
    'rol': 'Usuario',
    'acudienteNombre': 'NO REGISTRADO',
    'acudienteTelefono': 'NO REGISTRADO',
    'acudienteCorreo': 'NO REGISTRADO',
    'acudienteParentesco': 'NO REGISTRADO',
    'fechaCreacion': DateTime.now(),
    'ultimaConexion': DateTime.now(),
  };
}

/// Builds the patient header block: big uppercase name + ID/EPS/género on
/// the left, and a big navy age number on the right.
pw.Widget buildPatientHeaderBlock(Map<String, dynamic> datos) {
  final nombres = (datos['nombres']?.toString() ?? '').toUpperCase();
  final apellidos = (datos['apellidos']?.toString() ?? '').toUpperCase();
  final nombreCompleto = '$nombres $apellidos'.trim();
  final numeroId = datos['numeroIdentificacion']?.toString() ?? '';
  final eps = (datos['eps']?.toString() ?? '').toUpperCase();
  final genero = (datos['genero']?.toString() ?? '').toUpperCase();
  final edad = datos['edad']?.toString() ?? 'N/A';

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              nombreCompleto,
              style: pw.TextStyle(
                fontSize: 17.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'DOCUMENTO: $numeroId',
              style: pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'EPS: $eps  |  GÉNERO: $genero',
              style: pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            edad,
            style: pw.TextStyle(
              fontSize: 27,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.Text(
            'AÑOS',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _labeledField(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfBrand.cardGrey,
            ),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              fontSize: 8.5,
              color: PdfBrand.darkGrey,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Two-column contact info block separated by a vertical divider.
pw.Widget buildContactoBlock(Map<String, dynamic> datos) {
  final correo = (datos['email']?.toString() ?? '').toUpperCase();
  final direccion =
      (datos['barrio']?.toString() ?? datos['municipio']?.toString() ?? '')
          .toUpperCase();
  final telefono = datos['telefono']?.toString() ?? '';
  final acudiente = (datos['acudienteNombre']?.toString() ?? '').toUpperCase();
  final parentesco =
      (datos['acudienteParentesco']?.toString() ?? '').toUpperCase();
  final telefonoAcudiente = datos['acudienteTelefono']?.toString() ?? '';
  final acudienteCorreo = datos['acudienteCorreo']?.toString() ?? '';

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _labeledField('CORREO:', correo),
                _labeledField('DIRECCIÓN:', direccion),
                _labeledField('TELÉFONO:', telefono),
              ],
            ),
          ),
        ),
        pw.Container(
          width: 1,
          height: 50,
          color: PdfColors.grey300,
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _labeledField('ACUDIENTE:', acudiente),
                _labeledField('PARENTESCO:', parentesco),
                _labeledField('TELÉFONO:', telefonoAcudiente),
                _labeledField('CORREO:', acudienteCorreo),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
