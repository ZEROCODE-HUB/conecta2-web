// Legacy "Imprimir" PDF portado del proyecto viejo tal cual para
// preservar el comportamiento que el equipo clinico ya tenia validado.
// Los defensive null checks del original se mantienen intencionalmente.
// ignore_for_file: unnecessary_null_comparison, unnecessary_non_null_assertion, invalid_null_aware_operator, dead_null_aware_expression

import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// "Imprimir" - informe individual PDF con datos detallados crudos:
/// tabla plana de todas las respuestas del tamizaje, dimensiones, y
/// resumen con nivel de riesgo. Diseño sobrio, sin branding.
///
/// Para el informe branded ("Reporte") con cards por tamizaje y
/// factores de alerta, ver `generarInformeIndividualPDF` en
/// `informe_pdf/generar_informe_individual_p_d_f.dart`.
Future generarImprimirPDF(String userUid) async {
  // Variables para tracking del estado
  Map<String, dynamic>? datosPersonales;
  List<RespustaTamizajeStruct> respuestasTamizaje = [];
  String nombreCompleto = 'Usuario';
  bool tieneDatosPersonales = false;
  bool tieneDatosTamizaje = false;
  bool tamizajeCompletadoSinRespuestas = false;
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

    // PASO 2: Obtener respuestas de tamizaje (CON MANEJO DE ERRORES)
    try {
      print('PASO 2: Obteniendo respuestas de tamizaje...');
      var resultado = await _obtenerRespuestasTamizajeSeguro(userUid);
      respuestasTamizaje = List<RespustaTamizajeStruct>.from(resultado['respuestas'] ?? []);
      tamizajeCompletadoSinRespuestas = resultado['completadoSinRespuestas'];

      if (respuestasTamizaje.isNotEmpty) {
        tieneDatosTamizaje = true;
        print(
            '✓ Respuestas de tamizaje obtenidas: ${respuestasTamizaje.length} respuestas');

        // NUEVO: Verificar si son respuestas por defecto
        if (tamizajeCompletadoSinRespuestas) {
          print(
              '⚠ Mostrando respuestas por defecto (Nunca) para tamizaje vacío');
          erroresEncontrados.add(
              'Tamizaje completado sin respuestas registradas - mostrando valores por defecto (Nunca)');
        } else {
          // NUEVO: Completar sustancias faltantes con valor "Nunca"
          respuestasTamizaje =
              _completarSustanciasFaltantes(respuestasTamizaje);
          print('✓ Sustancias faltantes completadas con valor "Nunca"');
        }
      } else {
        print('⚠ No se encontraron respuestas de tamizaje');
        erroresEncontrados.add('Sin respuestas de tamizaje disponibles');
      }
    } catch (e) {
      print('⚠ ERROR al obtener tamizaje: $e');
      erroresEncontrados.add('Error al obtener tamizaje: ${e.toString()}');
      respuestasTamizaje = [];
      tieneDatosTamizaje = false;
    }

    // PASO 3: Generar interpretación (SOLO SI HAY DATOS DE TAMIZAJE)
    String interpretacionAutomatica = '';
    Map<String, dynamic> datosAnalisis = {};

    if (tieneDatosTamizaje && respuestasTamizaje.isNotEmpty) {
      try {
        print('PASO 3: Generando interpretación del tamizaje...');
        interpretacionAutomatica =
            _generarInterpretacionIndividualSegura(respuestasTamizaje);
        datosAnalisis =
            _procesarDatosParaAnalisisIndividualSeguro(respuestasTamizaje);
        print('✓ Interpretación generada correctamente');
      } catch (e) {
        print('⚠ ERROR al generar interpretación: $e');
        erroresEncontrados
            .add('Error al generar interpretación: ${e.toString()}');
        interpretacionAutomatica =
            'No se pudo generar la interpretación automática.';
        datosAnalisis = _generarDatosAnalisisPorDefecto();
      }
    } else {
      print('⚠ Sin datos de tamizaje, omitiendo interpretación');
      interpretacionAutomatica =
          'No hay datos de tamizaje disponibles para este usuario.';
      datosAnalisis = _generarDatosAnalisisPorDefecto();
    }

    // PASO 4: Crear el PDF (SIEMPRE SE EJECUTA)
    Uint8List? pdfBytes;
    try {
      print('PASO 4: Creando PDF del informe...');
      pdfBytes = await _crearInformeIndividualPDFSeguro(
        nombreCompleto,
        datosPersonales!,
        respuestasTamizaje,
        interpretacionAutomatica,
        datosAnalisis,
        tieneDatosPersonales,
        tieneDatosTamizaje,
        tamizajeCompletadoSinRespuestas,
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

    // PASO 5: Mostrar el PDF (CON MANEJO DE ERRORES)
    if (pdfBytes != null) {
      try {
        print('PASO 5: Mostrando PDF...');
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
      'acudienteTelefono': acudienteTelefono,
      'acudienteCorreo': acudienteCorreo,
      'acudienteParentesco': acudienteParentesco,
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

/// NUEVA FUNCIÓN: Completa las sustancias faltantes con valor "Nunca"
List<RespustaTamizajeStruct> _completarSustanciasFaltantes(
    List<RespustaTamizajeStruct> respuestasExistentes) {
  try {
    print('  Completando sustancias faltantes...');

    // Lista completa de todas las sustancias que deben aparecer
    List<String> todasLasSustancias = [
      'Tabaco/Cigarrillo',
      'Bebidas alcohólicas',
      'Cannabis/Marihuana',
      'Cocaína',
      'Estimulantes tipo anfetamina',
      'Inhalantes',
      'Tranquilizantes o pastillas para dormir',
      'Alucinógenos',
      'Opiáceos',
      'Otras drogas',
    ];

    // Crear un mapa de las sustancias que ya existen en las respuestas
    Map<String, bool> sustanciasExistentes = {};
    for (var respuesta in respuestasExistentes) {
      for (var sustancia in todasLasSustancias) {
        if (respuesta.pregunta?.contains(sustancia) == true) {
          sustanciasExistentes[sustancia] = true;
          break;
        }
      }
    }

    // Lista para resultados finales (comenzamos con las respuestas existentes)
    List<RespustaTamizajeStruct> respuestasCompletas = [
      ...respuestasExistentes
    ];

    // Agregar las sustancias faltantes
    for (var sustancia in todasLasSustancias) {
      if (!sustanciasExistentes.containsKey(sustancia)) {
        respuestasCompletas.add(
          RespustaTamizajeStruct(
            pregunta:
                '¿Con qué frecuencia ha consumido $sustancia en los últimos 3 meses?',
            respuesta: 'Nunca',
          ),
        );
        print('  ✓ Agregada sustancia faltante: $sustancia');
      }
    }

    print(
        '  ✓ Total respuestas después de completar: ${respuestasCompletas.length}');
    return respuestasCompletas;
  } catch (e) {
    print('  ERROR al completar sustancias faltantes: $e');
    return respuestasExistentes;
  }
}

/// Genera respuestas por defecto con "Nunca" para todas las sustancias
List<RespustaTamizajeStruct> _generarRespuestasPorDefecto() {
  List<RespustaTamizajeStruct> respuestasDefault = [];

  List<String> sustancias = [
    'Tabaco/Cigarrillo',
    'Bebidas alcohólicas',
    'Cannabis/Marihuana',
    'Cocaína',
    'Estimulantes tipo anfetamina',
    'Inhalantes',
    'Tranquilizantes o pastillas para dormir',
    'Alucinógenos',
    'Opiáceos',
    'Otras drogas',
  ];

  for (var sustancia in sustancias) {
    try {
      respuestasDefault.add(
        RespustaTamizajeStruct(
          pregunta:
              '¿Con qué frecuencia ha consumido $sustancia en los últimos 3 meses?',
          respuesta: 'Nunca',
        ),
      );
    } catch (e) {
      print('Error al crear respuesta por defecto para $sustancia: $e');
    }
  }

  print(
      '  ✓ Generadas ${respuestasDefault.length} respuestas por defecto (Nunca)');
  return respuestasDefault;
}

/// Obtiene respuestas de tamizaje de forma segura
/// Ahora retorna Map con respuestas y flag de completado sin respuestas
Future<Map<String, dynamic>> _obtenerRespuestasTamizajeSeguro(
    String userUid) async {
  try {
    print('  Buscando respuestas de tamizaje para usuario: $userUid');

    // Intentar obtener de Firestore
    try {
      final tamizajeSnapshot = await FirebaseFirestore.instance
          .collection('tamizajes')
          .where('user_uid', isEqualTo: userUid)
          .limit(1)
          .get()
          .timeout(Duration(seconds: 10));

      if (tamizajeSnapshot.docs.isNotEmpty) {
        final tamizajeDoc = tamizajeSnapshot.docs.first;
        final data = tamizajeDoc.data();

        print('  ✓ Encontrado documento de tamizaje');

        // Verificar si hay respuestas
        bool tieneRespuestas = false;
        List<RespustaTamizajeStruct> respuestas = [];

        // Adaptar según tu estructura de datos real
        if (data.containsKey('respuestas') && data['respuestas'] != null) {
          var respuestasData = data['respuestas'];
          if (respuestasData is List && respuestasData.isNotEmpty) {
            tieneRespuestas = true;
            // TODO: Convertir respuestasData a List<RespustaTamizajeStruct>
            // Por ahora, si hay respuestas, las procesamos
            try {
              // Simulamos que encontramos respuestas reales
              // En tu implementación real, aquí convertirías los datos de Firestore
              print(
                  '  ✓ Tamizaje con ${respuestasData.length} respuestas reales');

              // Iterar sobre la lista de forma segura sin forzar el tipo a List<Map<String, dynamic>>
              for (var respuestaData in respuestasData) {
                try {
                  if (respuestaData is Map) {
                    respuestas.add(RespustaTamizajeStruct(
                      pregunta: respuestaData['pregunta']?.toString() ??
                          'Pregunta no disponible',
                      respuesta: respuestaData['respuesta']?.toString() ??
                          'No respondida',
                    ));
                  }
                } catch (e) {
                  print('Error al convertir respuesta: $e');
                }
              }
            } catch (e) {
              print('Error al procesar respuestas: $e');
              tieneRespuestas = false;
            }
          }
        }

        // Si tiene documento pero NO tiene respuestas válidas -> caso especial
        if (!tieneRespuestas || respuestas.isEmpty) {
          print(
              '  ⚠ Usuario tiene tamizaje pero sin respuestas registradas o válidas');
          return {
            'respuestas': _generarRespuestasPorDefecto(),
            'completadoSinRespuestas': true,
          };
        }

        return {
          'respuestas': respuestas,
          'completadoSinRespuestas': false,
        };
      } else {
        print('  ⚠ No se encontraron documentos de tamizaje');
      }
    } catch (e) {
      print('  ⚠ Error al consultar tamizajes: $e');
    }

    // Por defecto retorna sin datos de tamizaje
    return {
      'respuestas': <RespustaTamizajeStruct>[],
      'completadoSinRespuestas': false,
    };
  } catch (e) {
    print('  ERROR al obtener respuestas de tamizaje: $e');
    return {
      'respuestas': <RespustaTamizajeStruct>[],
      'completadoSinRespuestas': false,
    };
  }
}

/// Crea el PDF del informe con manejo robusto de errores
Future<Uint8List> _crearInformeIndividualPDFSeguro(
  String nombrePaciente,
  Map<String, dynamic> datosPersonales,
  List<RespustaTamizajeStruct> respuestas,
  String interpretacion,
  Map<String, dynamic> datosAnalisis,
  bool tieneDatosPersonales,
  bool tieneDatosTamizaje,
  bool tamizajeCompletadoSinRespuestas,
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

    // Incluir sección de tamizaje SOLO si hay datos
    if (tieneDatosTamizaje && respuestas.isNotEmpty) {
      try {
        contenidoPDF.add(_buildSeccionTamizajeSegura(
          respuestas,
          interpretacion,
          datosAnalisis,
          tamizajeCompletadoSinRespuestas,
        ));
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

pw.Widget _buildSeccionTamizajeSegura(
  List<RespustaTamizajeStruct> respuestas,
  String interpretacion,
  Map<String, dynamic> datosAnalisis,
  bool tamizajeCompletadoSinRespuestas,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'RESULTADOS DEL TAMIZAJE',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      pw.Divider(),
      pw.SizedBox(height: 10),

      // Nota especial para tamizaje sin respuestas
      if (tamizajeCompletadoSinRespuestas) ...[
        pw.Container(
          padding: pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            border: pw.Border.all(color: PdfColors.orange700, width: 1),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '📝 INFORMACIÓN SOBRE LOS RESULTADOS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                  color: PdfColors.orange900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'El usuario completó el proceso de tamizaje pero no registró respuestas específicas. '
                'Se muestran valores por defecto "Nunca" para todas las sustancias, indicando '
                'que no se reportó consumo en ninguna de las categorías evaluadas.',
                style: pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Estos resultados representan la ausencia de datos reportados, no necesariamente '
                'la ausencia de consumo.',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.orange700,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],

      // Resumen de resultados (SIEMPRE mostrar, incluso con valores por defecto)
      if (datosAnalisis.isNotEmpty) ...[
        _buildResumenResultadosSeguro(
            datosAnalisis, tamizajeCompletadoSinRespuestas),
        pw.SizedBox(height: 15),
      ],

      // Interpretación
      pw.Container(
        padding: pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INTERPRETACIÓN:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              interpretacion,
              style: pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.justify,
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 15),

      // Lista de respuestas (SIEMPRE mostrar cuando hay respuestas, aunque sean por defecto)
      pw.Text(
        'DETALLE DE RESPUESTAS:',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
      pw.SizedBox(height: 5),

      ...respuestas.asMap().entries.map((entry) {
        int index = entry.key;
        var respuesta = entry.value;
        return _buildItemRespuestaSeguro(
            index + 1, respuesta, tamizajeCompletadoSinRespuestas);
      }).toList(),
    ],
  );
}

pw.Widget _buildResumenResultadosSeguro(
    Map<String, dynamic> datos, bool esPorDefecto) {
  String nivelRiesgo = datos['nivelRiesgo']?.toString() ?? 'DESCONOCIDO';
  double promedio = (datos['promedio'] as num?)?.toDouble() ?? 0.0;
  int totalRespuestas = datos['totalRespuestas'] as int? ?? 0;

  PdfColor colorRiesgo;
  String etiquetaRiesgo = nivelRiesgo;

  if (esPorDefecto) {
    colorRiesgo = PdfColors.grey;
    etiquetaRiesgo = 'SIN DATOS';
  } else {
    switch (nivelRiesgo) {
      case 'BAJO':
        colorRiesgo = PdfColors.green;
        break;
      case 'MODERADO':
        colorRiesgo = PdfColors.orange;
        break;
      case 'ALTO':
        colorRiesgo = PdfColors.red;
        break;
      default:
        colorRiesgo = PdfColors.grey;
    }
  }

  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: colorRiesgo.shade(0.1),
      border: pw.Border.all(color: colorRiesgo, width: 2),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      children: [
        if (esPorDefecto) ...[
          pw.Text(
            'RESULTADOS POR DEFECTO',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
        ],
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildMetricaSegura('Nivel de Riesgo', etiquetaRiesgo, colorRiesgo),
            _buildMetricaSegura(
                'Promedio', promedio.toStringAsFixed(2), PdfColors.blue),
            _buildMetricaSegura(
                'Respuestas', totalRespuestas.toString(), PdfColors.grey700),
          ],
        ),
        if (esPorDefecto) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            'Valores calculados basados en respuestas por defecto "Nunca"',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

pw.Widget _buildMetricaSegura(String etiqueta, String valor, PdfColor color) {
  return pw.Column(
    children: [
      pw.Text(
        etiqueta,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 3),
      pw.Text(
        valor,
        style: pw.TextStyle(
            fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
      ),
    ],
  );
}

pw.Widget _buildItemRespuestaSeguro(
    int numero, RespustaTamizajeStruct respuesta, bool esPorDefecto) {
  String pregunta = respuesta.pregunta ?? 'Pregunta no disponible';
  String respuestaTexto = respuesta.respuesta ?? 'Sin respuesta';

  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: 8),
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(
          color: esPorDefecto ? PdfColors.grey400 : PdfColors.grey300,
          width: esPorDefecto ? 1 : 0.5),
      borderRadius: pw.BorderRadius.circular(3),
      color: esPorDefecto ? PdfColors.grey50 : PdfColors.white,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (esPorDefecto)
              pw.Text('• ',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Expanded(
              child: pw.Text(
                '$numero. $pregunta',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: esPorDefecto ? PdfColors.grey700 : PdfColors.black,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Row(
          children: [
            pw.Text(
              'Respuesta: ',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: esPorDefecto ? PdfColors.grey600 : PdfColors.black,
              ),
            ),
            pw.Text(
              respuestaTexto,
              style: pw.TextStyle(
                fontSize: 9,
                color: esPorDefecto ? PdfColors.grey600 : PdfColors.black,
                fontStyle:
                    esPorDefecto ? pw.FontStyle.italic : pw.FontStyle.normal,
              ),
            ),
            if (esPorDefecto)
              pw.Text(
                ' (por defecto)',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                  fontStyle: pw.FontStyle.italic,
                ),
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
// FUNCIONES DE ANÁLISIS Y PROCESAMIENTO (VERSIONES SEGURAS)
// ============================================================================

String _generarInterpretacionIndividualSegura(
    List<RespustaTamizajeStruct> respuestas) {
  try {
    if (respuestas.isEmpty) {
      return 'No se encontraron respuestas para interpretar.';
    }

    double puntuacionTotal = 0;
    int totalRespuestas = respuestas.length;

    for (var respuesta in respuestas) {
      try {
        puntuacionTotal +=
            double.tryParse(_obtenerValorRespuestaSeguro(respuesta)) ?? 0;
      } catch (e) {
        print('Error al procesar respuesta: $e');
      }
    }

    double promedio =
        totalRespuestas > 0 ? puntuacionTotal / totalRespuestas : 0;
    String interpretacion = '';

    if (promedio >= 0 && promedio < 1.5) {
      interpretacion =
          'PERFIL DE BIENESTAR ÓPTIMO: El análisis revela un estado de salud general satisfactorio. '
          'Los indicadores se encuentran dentro de rangos esperados con adecuados recursos de afrontamiento. '
          'No se identifican áreas de preocupación inmediata.\n\n'
          'FORTALEZAS: Capacidad adaptativa, estabilidad emocional y prácticas de autocuidado consistentes.\n\n'
          'RECOMENDACIÓN: Mantener rutinas de cuidado preventivo y monitoreo regular.';
    } else if (promedio >= 1.5 && promedio < 2.5) {
      interpretacion =
          'PERFIL DE ATENCIÓN PREVENTIVA: Se identifican indicadores que sugieren intervención temprana. '
          'Se observan áreas donde el paciente podría beneficiarse de apoyo profesional para optimizar bienestar.\n\n'
          'ÁREAS DE OPORTUNIDAD: Dimensiones que requieren atención focalizada en manejo del estrés y regulación emocional.\n\n'
          'ENFOQUE: Implementación de plan personalizado con seguimiento activo.';
    } else if (promedio >= 2.5) {
      interpretacion =
          'PERFIL DE INTERVENCIÓN PRIORITARIA: Los resultados indican múltiples factores que requieren atención inmediata. '
          'Se detectan indicadores significativos que ameritan evaluación integral especializada.\n\n'
          'ÁREAS CRÍTICAS: Dimensiones que requieren intervención urgente con posible afectación en funcionamiento general.\n\n'
          'ACCIÓN INMEDIATA: Remisión especializada e implementación de plan integral con monitoreo estrecho.';
    }

    try {
      Map<String, Map<String, dynamic>> analisisDimensiones =
          _analizarDimensionesSeguro(respuestas);

      interpretacion += '\n\nANÁLISIS DIMENSIONAL:\n';
      analisisDimensiones.forEach((dimension, datos) {
        try {
          double promedioDim = (datos['promedio'] as num?)?.toDouble() ?? 0.0;
          String nivel = _obtenerNivelDimensionSeguro(promedioDim);
          interpretacion +=
              '• $dimension: ${promedioDim.toStringAsFixed(2)} - Nivel $nivel\n';
        } catch (e) {
          print('Error al procesar dimensión $dimension: $e');
        }
      });
    } catch (e) {
      print('Error al analizar dimensiones: $e');
    }

    interpretacion += '\nRESUMEN CUANTITATIVO:\n';
    interpretacion +=
        '• Puntuación: ${puntuacionTotal.toStringAsFixed(1)}/${totalRespuestas * 4}\n';
    interpretacion += '• Promedio: ${promedio.toStringAsFixed(2)}/4\n';
    interpretacion +=
        '• Porcentaje: ${((puntuacionTotal / (totalRespuestas * 4)) * 100).toStringAsFixed(1)}%\n';
    interpretacion += '• Ítems evaluados: $totalRespuestas';

    return interpretacion;
  } catch (e) {
    print('Error en _generarInterpretacionIndividualSegura: $e');
    return 'No se pudo generar la interpretación debido a un error en el procesamiento de datos.';
  }
}

Map<String, dynamic> _procesarDatosParaAnalisisIndividualSeguro(
    List<RespustaTamizajeStruct> respuestas) {
  try {
    double puntuacionTotal = 0;
    int totalRespuestas = respuestas.length;

    for (var respuesta in respuestas) {
      try {
        String valorStr = _obtenerValorRespuestaSeguro(respuesta);
        double valor = double.tryParse(valorStr) ?? 0;
        puntuacionTotal += valor;
      } catch (e) {
        print('Error al procesar respuesta individual: $e');
      }
    }

    double promedio =
        totalRespuestas > 0 ? puntuacionTotal / totalRespuestas : 0;
    String nivelRiesgo;

    if (promedio < 1.5) {
      nivelRiesgo = 'BAJO';
    } else if (promedio < 2.5) {
      nivelRiesgo = 'MODERADO';
    } else {
      nivelRiesgo = 'ALTO';
    }

    double porcentajeMaximo = totalRespuestas > 0
        ? (puntuacionTotal / (totalRespuestas * 4)) * 100
        : 0;

    return {
      'puntuacionTotal': puntuacionTotal,
      'promedio': promedio,
      'nivelRiesgo': nivelRiesgo,
      'totalRespuestas': totalRespuestas,
      'porcentajeMaximo': porcentajeMaximo,
    };
  } catch (e) {
    print('Error en _procesarDatosParaAnalisisIndividualSeguro: $e');
    return _generarDatosAnalisisPorDefecto();
  }
}

Map<String, dynamic> _generarDatosAnalisisPorDefecto() {
  return {
    'puntuacionTotal': 0.0,
    'promedio': 0.0,
    'nivelRiesgo': 'DESCONOCIDO',
    'totalRespuestas': 0,
    'porcentajeMaximo': 0.0,
  };
}

String _obtenerValorRespuestaSeguro(RespustaTamizajeStruct respuesta) {
  try {
    if (respuesta.respuesta == null || respuesta.respuesta!.isEmpty) {
      return '0';
    }

    String resp = respuesta.respuesta!.toLowerCase().trim();

    Map<String, String> mapeoRespuestas = {
      'nunca': '0',
      'no': '0',
      'pocas veces': '1',
      'rara vez': '1',
      'algunas veces': '2',
      'a veces': '2',
      'frecuentemente': '3',
      'a menudo': '3',
      'siempre': '4',
      'sí': '4',
      'mucho': '4',
    };

    for (String key in mapeoRespuestas.keys) {
      if (resp.contains(key)) {
        return mapeoRespuestas[key]!;
      }
    }

    if (RegExp(r'^\d+$').hasMatch(resp)) {
      int valor = int.tryParse(resp) ?? 1;
      return valor.clamp(0, 4).toString();
    }

    return '1';
  } catch (e) {
    print('Error en _obtenerValorRespuestaSeguro: $e');
    return '0';
  }
}

Map<String, Map<String, dynamic>> _analizarDimensionesSeguro(
    List<RespustaTamizajeStruct> respuestas) {
  try {
    // Implementación simplificada para evitar errores
    Map<String, Map<String, dynamic>> dimensiones = {};

    // Agrupar por dimensión basándonos en la pregunta
    // Como no existe el campo 'dimension', creamos categorías basadas en palabras clave
    for (var respuesta in respuestas) {
      try {
        String dimension =
            _extraerDimensionDePregunta(respuesta.pregunta ?? '');

        if (!dimensiones.containsKey(dimension)) {
          dimensiones[dimension] = {
            'respuestas': [],
            'promedio': 0.0,
          };
        }

        dimensiones[dimension]!['respuestas'].add(respuesta);
      } catch (e) {
        print('Error al procesar dimensión de respuesta: $e');
      }
    }

    // Si no se pudo categorizar, crear una dimensión general
    if (dimensiones.isEmpty) {
      dimensiones['General'] = {
        'respuestas': respuestas,
        'promedio': 0.0,
      };
    }

    // Calcular promedios
    dimensiones.forEach((key, value) {
      try {
        List<RespustaTamizajeStruct> respuestasDim = value['respuestas'];
        double suma = 0;
        for (var resp in respuestasDim) {
          suma += double.tryParse(_obtenerValorRespuestaSeguro(resp)) ?? 0;
        }
        value['promedio'] =
            respuestasDim.isNotEmpty ? suma / respuestasDim.length : 0.0;
      } catch (e) {
        print('Error al calcular promedio de dimensión $key: $e');
        value['promedio'] = 0.0;
      }
    });

    return dimensiones;
  } catch (e) {
    print('Error en _analizarDimensionesSeguro: $e');
    return {
      'General': {'respuestas': [], 'promedio': 0.0}
    };
  }
}

/// Extrae una dimensión aproximada basándose en palabras clave de la pregunta
String _extraerDimensionDePregunta(String pregunta) {
  try {
    String preguntaLower = pregunta.toLowerCase();

    // Categorías emocionales/psicológicas
    if (preguntaLower.contains('ansioso') ||
        preguntaLower.contains('nervioso') ||
        preguntaLower.contains('preocup')) {
      return 'Ansiedad';
    }

    if (preguntaLower.contains('triste') ||
        preguntaLower.contains('deprimido') ||
        preguntaLower.contains('desanim')) {
      return 'Estado de Ánimo';
    }

    if (preguntaLower.contains('dormir') ||
        preguntaLower.contains('sueño') ||
        preguntaLower.contains('descanso')) {
      return 'Sueño';
    }

    if (preguntaLower.contains('concentr') ||
        preguntaLower.contains('atención') ||
        preguntaLower.contains('memoria')) {
      return 'Cognición';
    }

    if (preguntaLower.contains('energía') ||
        preguntaLower.contains('cansancio') ||
        preguntaLower.contains('fatiga')) {
      return 'Energía';
    }

    if (preguntaLower.contains('dolor') ||
        preguntaLower.contains('cabeza') ||
        preguntaLower.contains('malestar')) {
      return 'Síntomas Físicos';
    }

    if (preguntaLower.contains('apetito') ||
        preguntaLower.contains('comer') ||
        preguntaLower.contains('alimenta')) {
      return 'Alimentación';
    }

    if (preguntaLower.contains('irritable') ||
        preguntaLower.contains('enojado') ||
        preguntaLower.contains('frustrado')) {
      return 'Irritabilidad';
    }

    if (preguntaLower.contains('interés') ||
        preguntaLower.contains('disfrutar') ||
        preguntaLower.contains('placer')) {
      return 'Motivación';
    }

    if (preguntaLower.contains('social') ||
        preguntaLower.contains('amigos') ||
        preguntaLower.contains('relacione')) {
      return 'Relaciones Sociales';
    }

    // Si no coincide con ninguna categoría
    return 'General';
  } catch (e) {
    print('Error en _extraerDimensionDePregunta: $e');
    return 'General';
  }
}

String _obtenerNivelDimensionSeguro(double promedio) {
  try {
    if (promedio < 1.5) {
      return 'BAJO';
    } else if (promedio < 2.5) {
      return 'MODERADO';
    } else {
      return 'ALTO';
    }
  } catch (e) {
    return 'DESCONOCIDO';
  }
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
