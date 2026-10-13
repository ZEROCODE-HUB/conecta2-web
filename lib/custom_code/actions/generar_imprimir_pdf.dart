// Legacy "Imprimir" PDF portado del proyecto viejo. Los defensive null
// checks del original se mantienen intencionalmente.
// ignore_for_file: unnecessary_null_comparison, unnecessary_non_null_assertion, invalid_null_aware_operator, dead_null_aware_expression

import '/tamizajes/shared/assist_utils.dart'
    show esEncuestaAssist, evaluarAssist, itemSustanciaNoAplica, ResultadoAssist;
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// "Imprimir" - informe individual PDF con datos detallados crudos: datos
/// del paciente y, por cada tamizaje realizado, su nombre, fecha, origen
/// (app o manual), resumen propio y sus preguntas y respuestas.
///
/// Para el informe branded ("Reporte") con cards por tamizaje y
/// factores de alerta, ver `generarInformeIndividualPDF` en
/// `informe_pdf/generar_informe_individual_p_d_f.dart`.
Future generarImprimirPDF(String userUid) async {
  // Variables para tracking del estado
  Map<String, dynamic>? datosPersonales;
  List<_TamizajeImprimir> tamizajes = [];
  String nombreCompleto = 'Usuario';
  bool tieneDatosPersonales = false;
  List<String> erroresEncontrados = [];

  try {
    print('=== INICIO: Generación de informe para usuario: $userUid ===');

    // Validar UID
    if (userUid.isEmpty) {
      print('ERROR: UID vacío');
      erroresEncontrados.add('UID de usuario no proporcionado');
      throw Exception('No se proporcionó un UID de usuario válido');
    }

    // PASO 1: Obtener datos del paciente (CON MANEJO DE ERRORES)
    try {
      print('PASO 1: Obteniendo datos personales del usuario...');
      datosPersonales = await _obtenerDatosPacienteFirestoreSeguro(userUid);

      if (datosPersonales != null && datosPersonales.isNotEmpty) {
        tieneDatosPersonales = true;
        nombreCompleto =
            '${datosPersonales['nombres']} ${datosPersonales['apellidos']}';
        print('✓ Datos personales obtenidos correctamente: $nombreCompleto');
      } else {
        print(
            '⚠ No se encontraron datos del usuario, usando valores por defecto');
        erroresEncontrados.add('Datos personales no encontrados');
        datosPersonales = _generarDatosPersonalesPorDefecto(userUid);
        nombreCompleto = 'Usuario No Encontrado';
      }
    } catch (e) {
      print('⚠ ERROR al obtener datos personales: $e');
      erroresEncontrados
          .add('Error al obtener datos personales: ${e.toString()}');
      datosPersonales = _generarDatosPersonalesPorDefecto(userUid);
      nombreCompleto = 'Usuario (Error en datos)';
    }

    // PASO 2: Obtener los tamizajes, cada uno con sus respuestas
    try {
      print('PASO 2: Obteniendo tamizajes...');
      tamizajes = await _obtenerTamizajesSeguro(userUid);
      if (tamizajes.isNotEmpty) {
        print('✓ Tamizajes obtenidos: ${tamizajes.length}');
      } else {
        print('⚠ No se encontraron tamizajes');
        erroresEncontrados.add('Sin respuestas de tamizaje disponibles');
      }
    } catch (e) {
      print('⚠ ERROR al obtener tamizajes: $e');
      erroresEncontrados.add('Error al obtener tamizaje: ${e.toString()}');
      tamizajes = [];
    }

    // PASO 3: Crear el PDF (SIEMPRE SE EJECUTA)
    Uint8List? pdfBytes;
    try {
      print('PASO 3: Creando PDF del informe...');
      pdfBytes = await _crearInformeIndividualPDFSeguro(
        nombreCompleto,
        datosPersonales!,
        tamizajes,
        tieneDatosPersonales,
        erroresEncontrados,
      );
      print('✓ PDF creado exitosamente');
    } catch (e) {
      print('⚠ ERROR al crear PDF: $e');
      erroresEncontrados.add('Error al crear PDF: ${e.toString()}');

      // ÚLTIMO RECURSO: Crear PDF mínimo con solo datos básicos
      try {
        print('ÚLTIMO RECURSO: Creando PDF mínimo de emergencia...');
        pdfBytes = await _crearPDFMinimo(
          nombreCompleto,
          datosPersonales!,
          erroresEncontrados,
        );
        print('✓ PDF mínimo creado');
      } catch (emergencyError) {
        print(
            '✗ ERROR CRÍTICO: No se pudo crear ni siquiera el PDF mínimo: $emergencyError');
        throw Exception(
            'Error crítico al generar cualquier tipo de PDF: $emergencyError');
      }
    }

    // PASO 4: Mostrar el PDF (CON MANEJO DE ERRORES)
    if (pdfBytes != null) {
      try {
        print('PASO 4: Mostrando PDF...');
        await _mostrarPDFIndividualSeguro(pdfBytes, nombreCompleto);
        print('✓ PDF mostrado exitosamente');
      } catch (e) {
        print('⚠ ERROR al mostrar PDF: $e');
        erroresEncontrados.add('Error al mostrar PDF: ${e.toString()}');

        // Intentar compartir como alternativa
        try {
          print('Intentando compartir PDF como alternativa...');
          await _compartirPDFIndividualSeguro(pdfBytes, nombreCompleto);
          print('✓ PDF compartido exitosamente');
        } catch (compartirError) {
          print('⚠ ERROR al compartir PDF: $compartirError');
          throw Exception('No se pudo mostrar ni compartir el PDF');
        }
      }
    }

    print('=== FIN: Informe generado exitosamente ===');

    if (erroresEncontrados.isNotEmpty) {
      print('⚠ ADVERTENCIAS durante el proceso:');
      for (var error in erroresEncontrados) {
        print('  - $error');
      }
    }

    return 'success';
  } catch (e, stackTrace) {
    print('✗ ERROR CRÍTICO en generación de informe: $e');
    print('StackTrace: $stackTrace');

    // ÚLTIMO INTENTO: Intentar generar PDF básico con lo que tengamos
    try {
      print(
          'INTENTO FINAL: Generando PDF de emergencia con datos disponibles...');

      if (datosPersonales == null) {
        datosPersonales = _generarDatosPersonalesPorDefecto(userUid);
      }

      final pdfEmergencia = await _crearPDFMinimo(
        nombreCompleto,
        datosPersonales,
        [...erroresEncontrados, 'Error crítico: ${e.toString()}'],
      );

      await _mostrarPDFIndividualSeguro(pdfEmergencia, nombreCompleto);
      print('✓ PDF de emergencia generado y mostrado');
      return 'success_with_errors';
    } catch (finalError) {
      print('✗ FALLO TOTAL: No se pudo generar ningún PDF: $finalError');
      throw Exception(
          'Error total al generar el informe: $e\nError final: $finalError');
    }
  }
}

/// Obtiene los datos del paciente desde Firestore CON MANEJO SEGURO DE ERRORES
Future<Map<String, dynamic>?> _obtenerDatosPacienteFirestoreSeguro(
    String userUid) async {
  try {
    print('  Consultando Firestore para usuario: $userUid');

    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .get()
        .timeout(Duration(seconds: 10)); // Timeout de 10 segundos

    if (!docSnapshot.exists) {
      print('  Usuario no existe en Firestore');
      return null;
    }

    final data = docSnapshot.data();
    if (data == null || data.isEmpty) {
      print('  Documento existe pero está vacío');
      return null;
    }

    print('  Documento encontrado, procesando datos...');

    // Extraer display_name de forma segura
    String displayName = 'Paciente';
    try {
      displayName = data['display_name']?.toString() ?? 'Paciente';
    } catch (e) {
      print('  Error al extraer display_name: $e');
    }

    List<String> nombreParts = displayName.split(' ');
    String nombres = nombreParts.isNotEmpty ? nombreParts[0] : 'Paciente';
    String apellidos = nombreParts.length > 1
        ? nombreParts.sublist(1).join(' ')
        : 'No registrado';

    // Calcular edad de forma segura
    String edad = 'No registrada';
    try {
      if (data['fecha_nacimiento'] != null) {
        Timestamp fechaNacimiento = data['fecha_nacimiento'];
        DateTime fechaNac = fechaNacimiento.toDate();
        DateTime ahora = DateTime.now();
        int edadCalculada = ahora.year - fechaNac.year;
        if (ahora.month < fechaNac.month ||
            (ahora.month == fechaNac.month && ahora.day < fechaNac.day)) {
          edadCalculada--;
        }
        edad = edadCalculada.toString();
      }
    } catch (e) {
      print('  Error calculando edad: $e');
    }

    // Extraer datos del acudiente de forma segura
    String acudienteNombre = 'No registrado';
    String acudienteTelefono = 'No registrado';
    String acudienteCorreo = 'No registrado';
    String acudienteParentesco = 'No especificado';

    try {
      if (data['Acudiente'] != null && data['Acudiente'] is Map) {
        final acudienteData = Map<String, dynamic>.from(data['Acudiente']);
        acudienteNombre =
            acudienteData['Nombre']?.toString() ?? 'No registrado';
        acudienteTelefono =
            acudienteData['telefono']?.toString() ?? 'No registrado';
        acudienteCorreo =
            acudienteData['correo']?.toString() ?? 'No registrado';
        acudienteParentesco =
            acudienteData['parentesco']?.toString() ?? 'No especificado';
      }
    } catch (e) {
      print('  Error al extraer datos del acudiente: $e');
    }

    // Retornar datos con valores seguros
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'tipoIdentificacion': 'CC',
      'numeroIdentificacion':
          userUid.length >= 10 ? userUid.substring(0, 10) : userUid,
      'edad': edad,
      'genero': data['genero']?.toString() ?? 'No especificado',
      'municipio': data['municipio']?.toString() ?? 'No registrado',
      'barrio': data['barrio']?.toString() ?? 'No registrado',
      'telefono': data['phone_number']?.toString() ?? 'No registrado',
      'email': data['email']?.toString() ?? 'No registrado',
      'eps': data['eps']?.toString() ?? 'No registrada',
      'ocupacion': data['rol']?.toString() ?? 'No registrada',
      'estadoCivil': 'No especificado',
      'colegio': data['colegio']?.toString() ?? 'No registrado',
      'grado': data['grado']?.toString() ?? 'No registrado',
      'rol': data['rol']?.toString() ?? 'Usuario',
      'acudienteNombre': acudienteNombre,
      'acudienteTelefono': acudienteTelefono ?? 'No registrado',
      'acudienteCorreo': acudienteCorreo ?? 'No registrado',
      'acudienteParentesco': acudienteParentesco ?? 'No especificado',
      'fechaCreacion': _extraerFechaSegura(data['created_time']),
      'ultimaConexion': _extraerFechaSegura(data['Lastconnectedday']),
    };
  } catch (e, stackTrace) {
    print('  ERROR en _obtenerDatosPacienteFirestoreSeguro: $e');
    print('  StackTrace: $stackTrace');
    return null;
  }
}

/// Extrae fecha de forma segura desde Timestamp
DateTime _extraerFechaSegura(dynamic fecha) {
  try {
    if (fecha != null && fecha is Timestamp) {
      return fecha.toDate();
    }
  } catch (e) {
    print('  Error al extraer fecha: $e');
  }
  return DateTime.now();
}

/// Genera datos personales por defecto cuando no se encuentran en Firestore
Map<String, dynamic> _generarDatosPersonalesPorDefecto(String userUid) {
  return {
    'nombres': 'Usuario',
    'apellidos': 'No Encontrado',
    'tipoIdentificacion': 'N/A',
    'numeroIdentificacion':
        userUid.length >= 10 ? userUid.substring(0, 10) : userUid,
    'edad': 'N/A',
    'genero': 'No especificado',
    'municipio': 'No registrado',
    'barrio': 'No registrado',
    'telefono': 'No registrado',
    'email': 'No registrado',
    'eps': 'No registrada',
    'ocupacion': 'No registrada',
    'estadoCivil': 'No especificado',
    'colegio': 'No registrado',
    'grado': 'No registrado',
    'rol': 'Usuario',
    'acudienteNombre': 'No registrado',
    'acudienteTelefono': 'No registrado',
    'acudienteCorreo': 'No registrado',
    'acudienteParentesco': 'No especificado',
    'fechaCreacion': DateTime.now(),
    'ultimaConexion': DateTime.now(),
  };
}

/// Un tamizaje aplicado al usuario (un documento `Respuestas`) con sus
/// preguntas y respuestas.
class _TamizajeImprimir {
  _TamizajeImprimir({
    required this.titulo,
    required this.fecha,
    required this.esManual,
    required this.realizadoPorNombre,
    required this.invalidado,
    required this.motivoInvalidacion,
    required this.puntajeTotal,
    required this.alertasEspeciales,
    required this.assist,
    required this.items,
  });

  final String titulo;
  final DateTime? fecha;
  final bool esManual;
  final String realizadoPorNombre;
  final bool invalidado;
  final String motivoInvalidacion;
  final int? puntajeTotal;
  final List<String> alertasEspeciales;

  /// Resultado por sustancia; solo para el ASSIST (Consumo de SPA).
  final ResultadoAssist? assist;
  final List<RespustaTamizajeStruct> items;
}

/// Texto de la respuesta de un ítem, probando cada formato guardado.
String _textoRespuestaItem(RespuestaTestStruct item) {
  String texto = item.respuesta.trim();
  if (texto.isEmpty) texto = item.respuestaSeleccionUnica.trim();
  if (texto.isEmpty && item.respuestasSeleccionadas.isNotEmpty) {
    texto = item.respuestasSeleccionadas.join(', ');
  }
  if (texto.isEmpty && item.respuestaSelection.isNotEmpty) {
    texto = item.respuestaSelection.join(', ');
  }
  if (texto.isEmpty && item.respuestaTamizaje.isNotEmpty) {
    texto = item.respuestaTamizaje.map((e) => e.etiqueta).join(', ');
  }
  return texto;
}

Future<Map<String, dynamic>?> _leerDocCacheado(
  DocumentReference ref,
  Map<String, Map<String, dynamic>?> cache,
) async {
  if (cache.containsKey(ref.path)) return cache[ref.path];
  try {
    final snap = await ref.get().timeout(const Duration(seconds: 8));
    final data = snap.data();
    cache[ref.path] = data is Map<String, dynamic> ? data : null;
  } catch (_) {
    cache[ref.path] = null;
  }
  return cache[ref.path];
}

/// Arma un tamizaje a partir de un doc de `Respuestas` y su encuesta padre.
Future<_TamizajeImprimir?> _procesarDocTamizaje(
  DocumentSnapshot<Map<String, dynamic>> doc,
  Map<String, Map<String, dynamic>?> cache,
) async {
  try {
    final data = doc.data() ?? const <String, dynamic>{};

    // Encuesta padre: /Encuestas/{id}/Respuestas/{doc}
    Map<String, dynamic>? encuesta;
    final encuestaRef = doc.reference.parent.parent;
    if (encuestaRef != null && encuestaRef.parent.id == 'Encuestas') {
      encuesta = await _leerDocCacheado(encuestaRef, cache);
    }
    final preguntasRaw = (encuesta?['Preguntas'] as List?) ?? const [];
    final preguntas = [
      for (final p in preguntasRaw)
        if (p is Map) PreguntasEncuestaStruct.fromMap(Map<String, dynamic>.from(p)),
    ];

    final titulo = (data['Titlo'] ?? data['titlo'] ?? encuesta?['titulo'] ?? '')
        .toString()
        .trim();
    final esAssist = esEncuestaAssist(
        (encuesta?['categoria'] ?? '').toString(),
        titulo.isNotEmpty ? titulo : (encuesta?['titulo'] ?? '').toString());

    final rawItems = <dynamic>[
      if (data['test'] is List) ...(data['test'] as List),
      if (data['Respusta'] is List) ...(data['Respusta'] as List),
    ];
    final items = <RespustaTamizajeStruct>[];
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final item = RespuestaTestStruct.fromMap(m);
      // Las preguntas de sustancias no marcadas en el Condicionante no
      // aplicaron: no se listan (igual que en el resto de la app).
      if (esAssist && itemSustanciaNoAplica(item, preguntas)) continue;
      final texto = _textoRespuestaItem(item);
      items.add(RespustaTamizajeStruct(
        pregunta: m['Pregunta']?.toString() ??
            m['pregunta']?.toString() ??
            'Pregunta no disponible',
        respuesta: texto.isEmpty ? 'No respondida' : texto,
        tipo: (m['Tipo'] ?? m['tipo'] ?? titulo).toString(),
        trueAndFalse: (m['TrueAndFalse'] as num?)?.toInt(),
        nPregunta: (m['NPregunta'] as num?)?.toInt(),
      ));
    }

    final esManual = data['tipoTamizaje'] == 'manual';
    String realizadoPorNombre = '';
    final realizadoPor = data['realizadoPor'];
    if (esManual && realizadoPor is DocumentReference) {
      final prof = await _leerDocCacheado(realizadoPor, cache);
      realizadoPorNombre = (prof?['display_name'] ?? '').toString().trim();
    }

    final fechaRaw = data['Fecha'] ?? data['fecha'];
    final invalidado = data['invalidado'] == true;

    return _TamizajeImprimir(
      titulo: titulo.isEmpty ? 'Tamizaje sin nombre' : titulo,
      fecha: fechaRaw is Timestamp
          ? fechaRaw.toDate()
          : (fechaRaw is DateTime ? fechaRaw : null),
      esManual: esManual,
      realizadoPorNombre: realizadoPorNombre,
      invalidado: invalidado,
      motivoInvalidacion: (data['motivoInvalidacion'] ?? '').toString().trim(),
      puntajeTotal: (data['puntajeTotal'] as num?)?.toInt(),
      alertasEspeciales: [
        if (data['alertasEspeciales'] is List)
          for (final a in data['alertasEspeciales'] as List)
            if (a.toString().trim().isNotEmpty) a.toString().trim(),
      ],
      assist: esAssist && !invalidado
          ? evaluarAssist(
              preguntas: preguntasRaw,
              test: (data['test'] as List?) ?? const [],
              alertas: (encuesta?['alertas'] as List?) ?? const [],
            )
          : null,
      items: items,
    );
  } catch (e) {
    print('  Error procesando doc de tamizaje (Imprimir): $e');
    return null;
  }
}

/// Obtiene los tamizajes del usuario, del más reciente al más antiguo.
/// Lee las dos rutas donde se guardan (`/Encuestas/{id}/Respuestas` por
/// `User_respuesta` y `/users/{uid}/Respuestas`) sin duplicar documentos.
Future<List<_TamizajeImprimir>> _obtenerTamizajesSeguro(String userUid) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userUid);
  final docs = <String, DocumentSnapshot<Map<String, dynamic>>>{};

  try {
    final snap = await FirebaseFirestore.instance
        .collectionGroup('Respuestas')
        .where('User_respuesta', isEqualTo: userRef)
        .get()
        .timeout(const Duration(seconds: 12));
    for (final doc in snap.docs) {
      docs[doc.reference.path] = doc;
    }
  } catch (e) {
    print('  Info: no se pudo leer collectionGroup Respuestas en Imprimir: $e');
  }

  try {
    final snap = await userRef
        .collection('Respuestas')
        .get()
        .timeout(const Duration(seconds: 10));
    for (final doc in snap.docs) {
      docs[doc.reference.path] = doc;
    }
  } catch (e) {
    print('  Info: no se pudo leer users/$userUid/Respuestas en Imprimir: $e');
  }

  final cache = <String, Map<String, dynamic>?>{};
  final tamizajes = <_TamizajeImprimir>[];
  for (final doc in docs.values) {
    final t = await _procesarDocTamizaje(doc, cache);
    if (t != null && (t.items.isNotEmpty || t.invalidado)) tamizajes.add(t);
  }

  tamizajes.sort((a, b) {
    if (a.fecha == null && b.fecha == null) return 0;
    if (a.fecha == null) return 1;
    if (b.fecha == null) return -1;
    return b.fecha!.compareTo(a.fecha!);
  });
  return tamizajes;
}

/// Crea el PDF del informe con manejo robusto de errores
Future<Uint8List> _crearInformeIndividualPDFSeguro(
  String nombrePaciente,
  Map<String, dynamic> datosPersonales,
  List<_TamizajeImprimir> tamizajes,
  bool tieneDatosPersonales,
  List<String> errores,
) async {
  try {
    final pdf = pw.Document();

    DateTime ahora = DateTime.now();
    String fecha =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';
    String hora =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    // Extraer datos con valores por defecto seguros
    String nombres = datosPersonales['nombres']?.toString() ?? 'Paciente';
    String apellidos =
        datosPersonales['apellidos']?.toString() ?? 'No registrado';
    String tipoIdentificacion =
        datosPersonales['tipoIdentificacion']?.toString() ?? 'CC';
    String numeroIdentificacion =
        datosPersonales['numeroIdentificacion']?.toString() ?? 'No registrado';
    String edad = datosPersonales['edad']?.toString() ?? 'No registrada';
    String genero = datosPersonales['genero']?.toString() ?? 'No especificado';
    String municipio =
        datosPersonales['municipio']?.toString() ?? 'No registrado';
    String barrio = datosPersonales['barrio']?.toString() ?? 'No registrado';
    String telefono =
        datosPersonales['telefono']?.toString() ?? 'No registrado';
    String email = datosPersonales['email']?.toString() ?? 'No registrado';
    String eps = datosPersonales['eps']?.toString() ?? 'No registrada';
    String rol = datosPersonales['rol']?.toString() ?? 'Usuario';
    String colegio = datosPersonales['colegio']?.toString() ?? 'No registrado';
    String grado = datosPersonales['grado']?.toString() ?? 'No registrado';

    // Construir páginas del PDF
    List<pw.Widget> contenidoPDF = [];

    // SIEMPRE incluir header y título
    contenidoPDF.add(_buildHeaderInformeIndividualSeguro(fecha, hora));
    contenidoPDF.add(pw.SizedBox(height: 20));
    contenidoPDF.add(_buildTituloInformeIndividualSeguro());
    contenidoPDF.add(pw.SizedBox(height: 20));

    // SIEMPRE incluir datos personales
    contenidoPDF.add(_buildDatosPacienteCompletosSeguro(
      nombres,
      apellidos,
      tipoIdentificacion,
      numeroIdentificacion,
      edad,
      genero,
      municipio,
      barrio,
      telefono,
      email,
      eps,
      rol,
      colegio,
      grado,
    ));
    contenidoPDF.add(pw.SizedBox(height: 20));

    // Incluir sección de tamizajes SOLO si hay datos
    if (tamizajes.isNotEmpty) {
      try {
        // Se agregan como widgets sueltos (no una sola Column) para que
        // MultiPage pueda partir los tamizajes largos entre páginas.
        contenidoPDF.addAll(_buildSeccionTamizajesSegura(tamizajes));
        contenidoPDF.add(pw.SizedBox(height: 20));
      } catch (e) {
        print('  Error al construir sección de tamizaje: $e');
        contenidoPDF.add(_buildMensajeError(
            'No se pudo generar la sección de resultados de tamizaje'));
      }
    } else {
      contenidoPDF.add(_buildMensajeSinDatosTamizaje());
      contenidoPDF.add(pw.SizedBox(height: 20));
    }

    // Incluir errores si los hay (para debugging)
    if (errores.isNotEmpty) {
      contenidoPDF.add(_buildSeccionAdvertencias(errores));
    }

    // SIEMPRE incluir footer
    contenidoPDF.add(pw.SizedBox(height: 20));
    contenidoPDF.add(_buildFooterInformeSeguro());

    // Agregar página al PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
        build: (pw.Context context) => contenidoPDF,
      ),
    );

    return pdf.save();
  } catch (e, stackTrace) {
    print('ERROR CRÍTICO en _crearInformeIndividualPDFSeguro: $e');
    print('StackTrace: $stackTrace');
    throw Exception('No se pudo crear el PDF: $e');
  }
}

/// Crea un PDF mínimo de emergencia con solo datos básicos
Future<Uint8List> _crearPDFMinimo(
  String nombrePaciente,
  Map<String, dynamic> datosPersonales,
  List<String> errores,
) async {
  try {
    final pdf = pw.Document();

    DateTime ahora = DateTime.now();
    String fecha =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';
    String hora =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header simple
              pw.Text(
                'INFORME INDIVIDUAL',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Fecha: $fecha - Hora: $hora',
                  style: pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Datos básicos
              pw.Text(
                'DATOS DEL PACIENTE',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Nombre: ${datosPersonales['nombres']} ${datosPersonales['apellidos']}'),
              pw.Text(
                  'Identificación: ${datosPersonales['numeroIdentificacion']}'),
              pw.Text('Edad: ${datosPersonales['edad']}'),
              pw.Text('Email: ${datosPersonales['email']}'),
              pw.Text('Teléfono: ${datosPersonales['telefono']}'),

              pw.SizedBox(height: 30),

              // Mensaje de estado
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.orange, width: 2),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NOTA IMPORTANTE',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Este informe contiene únicamente los datos personales del usuario. '
                      'Los datos de tamizaje no están disponibles o no se pudieron cargar.',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Errores si los hay
              if (errores.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Advertencias técnicas:',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                ...errores.map((error) => pw.Padding(
                      padding: pw.EdgeInsets.only(left: 10, bottom: 3),
                      child:
                          pw.Text('• $error', style: pw.TextStyle(fontSize: 9)),
                    )),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.Text(
                'Documento generado automáticamente',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  } catch (e) {
    print('ERROR CRÍTICO en _crearPDFMinimo: $e');
    throw Exception('No se pudo crear ni siquiera el PDF mínimo: $e');
  }
}

// ============================================================================
// FUNCIONES AUXILIARES PARA CONSTRUIR SECCIONES DEL PDF (VERSIONES SEGURAS)
// ============================================================================

pw.Widget _buildHeaderInformeIndividualSeguro(String fecha, String hora) {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      border: pw.Border.all(color: PdfColors.blue200, width: 1),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Fecha: $fecha',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Hora: $hora',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

pw.Widget _buildTituloInformeIndividualSeguro() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(
        'INFORME INDIVIDUAL DE TAMIZAJE',
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
        textAlign: pw.TextAlign.center,
      ),
      pw.SizedBox(height: 5),
      pw.Container(
        width: 200,
        height: 3,
        color: PdfColors.blue500,
      ),
    ],
  );
}

pw.Widget _buildDatosPacienteCompletosSeguro(
  String nombres,
  String apellidos,
  String tipoId,
  String numeroId,
  String edad,
  String genero,
  String municipio,
  String barrio,
  String telefono,
  String email,
  String eps,
  String rol,
  String colegio,
  String grado,
) {
  return pw.Container(
    padding: pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 1),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DATOS DEL PACIENTE',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(),
        pw.SizedBox(height: 10),

        // Información personal
        _buildCampoInfoSeguro('Nombres:', nombres),
        _buildCampoInfoSeguro('Apellidos:', apellidos),
        _buildCampoInfoSeguro('Identificación:', '$tipoId - $numeroId'),
        _buildCampoInfoSeguro('Edad:', edad),
        _buildCampoInfoSeguro('Género:', genero),

        pw.SizedBox(height: 10),

        // Información de contacto
        _buildCampoInfoSeguro('Municipio:', municipio),
        _buildCampoInfoSeguro('Barrio:', barrio),
        _buildCampoInfoSeguro('Teléfono:', telefono),
        _buildCampoInfoSeguro('Email:', email),

        pw.SizedBox(height: 10),

        // Información adicional
        _buildCampoInfoSeguro('EPS:', eps),
        _buildCampoInfoSeguro('Rol:', rol),
        if (colegio != 'No registrado')
          _buildCampoInfoSeguro('Colegio:', colegio),
        if (grado != 'No registrado') _buildCampoInfoSeguro('Grado:', grado),
      ],
    ),
  );
}

pw.Widget _buildCampoInfoSeguro(String etiqueta, String valor) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            etiqueta,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            valor,
            style: pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

/// Sección de tamizajes: un bloque por tamizaje (cabecera + preguntas),
/// numerando las preguntas desde 1 dentro de cada uno.
List<pw.Widget> _buildSeccionTamizajesSegura(
    List<_TamizajeImprimir> tamizajes) {
  final widgets = <pw.Widget>[
    pw.Text(
      'TAMIZAJES REALIZADOS (${tamizajes.length})',
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    ),
    pw.Divider(),
    pw.SizedBox(height: 10),
  ];

  for (var i = 0; i < tamizajes.length; i++) {
    final t = tamizajes[i];
    try {
      widgets.add(_buildCabeceraTamizaje(i + 1, t));
      widgets.add(pw.SizedBox(height: 8));
      if (!t.invalidado) {
        for (var n = 0; n < t.items.length; n++) {
          widgets.add(_buildItemRespuestaSeguro(n + 1, t.items[n]));
        }
      }
    } catch (e) {
      print('  Error al construir el tamizaje "${t.titulo}": $e');
      widgets.add(_buildMensajeError(
          'No se pudo mostrar el tamizaje "${t.titulo}"'));
    }
    widgets.add(pw.SizedBox(height: 16));
  }
  return widgets;
}

String _formatearFechaHora(DateTime? fecha) {
  if (fecha == null) return 'Sin fecha';
  String dos(int v) => v.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
      '${dos(fecha.hour)}:${dos(fecha.minute)}';
}

PdfColor _colorNivel(String nivel) {
  switch (nivel.toLowerCase()) {
    case 'alto':
      return PdfColors.red700;
    case 'moderado':
      return PdfColors.orange700;
    case 'bajo':
      return PdfColors.green700;
    default:
      return PdfColors.grey700;
  }
}

pw.Widget _buildCabeceraTamizaje(int numero, _TamizajeImprimir t) {
  final origen = t.esManual
      ? 'Manual' +
          (t.realizadoPorNombre.isNotEmpty
              ? ' — aplicado por ${t.realizadoPorNombre}'
              : '')
      : 'Llenado por el adolescente (app)';

  final resumen = <pw.Widget>[];
  if (t.invalidado) {
    resumen.add(pw.Text(
      'INVALIDADO' +
          (t.motivoInvalidacion.isNotEmpty
              ? ' — ${t.motivoInvalidacion}'
              : ' — aplicación marcada como no válida; sin respuestas'),
      style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.red800),
    ));
  } else if (t.assist != null) {
    final a = t.assist!;
    if (!a.tieneEvaluaciones) {
      resumen.add(pw.Text('No se marcó consumo de sustancias.',
          style: pw.TextStyle(fontSize: 10)));
    } else {
      final global = a.nivelGlobal;
      resumen.add(pw.Text(
        'Nivel de riesgo: ${global.isEmpty ? 'N/A' : global.toUpperCase()}',
        style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _colorNivel(global)),
      ));
      for (final s in a.porSustancia.values) {
        resumen.add(pw.Text(
          '• ${s.sustancia}: ${s.puntaje} puntos'
          '${s.nivel.isNotEmpty ? ' — riesgo ${s.nivel}' : ''}',
          style: pw.TextStyle(fontSize: 9, color: _colorNivel(s.nivel)),
        ));
      }
    }
  } else {
    if (t.puntajeTotal != null) {
      resumen.add(pw.Text('Puntaje total: ${t.puntajeTotal}',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)));
    }
    for (final alerta in t.alertasEspeciales) {
      resumen.add(pw.Text('⚠ $alerta',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.red800)));
    }
  }

  return pw.Container(
    width: double.infinity,
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: t.invalidado ? PdfColors.red50 : PdfColors.blue50,
      border: pw.Border.all(
          color: t.invalidado ? PdfColors.red200 : PdfColors.blue200,
          width: 1),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TAMIZAJE $numero: ${t.titulo}',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Fecha: ${_formatearFechaHora(t.fecha)}',
            style: pw.TextStyle(fontSize: 10)),
        pw.Text('Origen: $origen', style: pw.TextStyle(fontSize: 10)),
        if (!t.invalidado)
          pw.Text('Preguntas: ${t.items.length}',
              style: pw.TextStyle(fontSize: 10)),
        if (resumen.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          ...resumen,
        ],
      ],
    ),
  );
}

pw.Widget _buildItemRespuestaSeguro(
    int numero, RespustaTamizajeStruct respuesta) {
  String pregunta = respuesta.pregunta ?? 'Pregunta no disponible';
  String respuestaTexto = respuesta.respuesta ?? 'Sin respuesta';

  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: 8),
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      borderRadius: pw.BorderRadius.circular(3),
      color: PdfColors.white,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$numero. $pregunta',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Respuesta: ',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            // Expanded para que las respuestas largas hagan salto de línea
            // en vez de salirse del recuadro.
            pw.Expanded(
              child: pw.Text(respuestaTexto, style: pw.TextStyle(fontSize: 9)),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildMensajeSinDatosTamizaje() {
  return pw.Container(
    padding: pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      color: PdfColors.yellow50,
      border: pw.Border.all(color: PdfColors.yellow700, width: 2),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          '⚠ SIN DATOS DE TAMIZAJE',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.yellow900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'No se encontraron respuestas de tamizaje para este usuario.\n'
          'Este informe contiene únicamente los datos personales.',
          style: pw.TextStyle(fontSize: 11),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

pw.Widget _buildMensajeError(String mensaje) {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.red50,
      border: pw.Border.all(color: PdfColors.red300, width: 1),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Text(
      '⚠ $mensaje',
      style: pw.TextStyle(fontSize: 10, color: PdfColors.red900),
    ),
  );
}

pw.Widget _buildSeccionAdvertencias(List<String> errores) {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.orange50,
      border: pw.Border.all(color: PdfColors.orange200, width: 1),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ADVERTENCIAS TÉCNICAS',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        ...errores.map((error) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 2),
              child: pw.Text('• $error', style: pw.TextStyle(fontSize: 8)),
            )),
      ],
    ),
  );
}

pw.Widget _buildFooterInformeSeguro() {
  return pw.Column(
    children: [
      pw.Divider(),
      pw.SizedBox(height: 10),
      pw.Text(
        'Este informe fue generado automáticamente por el sistema.',
        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
      pw.Text(
        'Para más información, consulte con su profesional de salud.',
        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
    ],
  );
}

// ============================================================================
// FUNCIONES DE PRESENTACIÓN DEL PDF (VERSIONES SEGURAS)
// ============================================================================

Future<void> _mostrarPDFIndividualSeguro(
    Uint8List pdfBytes, String paciente) async {
  try {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
    print('Informe individual mostrado exitosamente para: $paciente');
  } catch (e) {
    print('Error al mostrar informe: $e');
    // Intentar compartir como alternativa
    await _compartirPDFIndividualSeguro(pdfBytes, paciente);
  }
}

Future<void> _compartirPDFIndividualSeguro(
    Uint8List pdfBytes, String paciente) async {
  try {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'informe_${_sanitizarNombreArchivoSeguro(paciente)}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    print('Informe compartido exitosamente');
  } catch (e) {
    print('Error al compartir informe: $e');
    throw Exception('No se pudo mostrar ni compartir el informe: $e');
  }
}

String _sanitizarNombreArchivoSeguro(String nombre) {
  try {
    return nombre
        .replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  } catch (e) {
    return 'informe_${DateTime.now().millisecondsSinceEpoch}';
  }
}
