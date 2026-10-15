import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/evaluar_alertas_especiales.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'steps/paso1_seleccion_adolescente.dart';
import 'steps/paso2_seleccion_tamizaje.dart';
import 'steps/paso3_formulario.dart';
import 'steps/paso4_resultados.dart';
import 'widgets/mobile_stepper.dart';

/// Mobile wizard (4 steps) for professionals to create manual tamizajes.
///
///   1) Select or register an adolescent.
///   2) Select which tamizaje to apply.
///   3) Answer every question (supports all question types).
///   4) View results, add notes, schedule follow-up reminder.
class WizardTamizajeProWidget extends StatefulWidget {
  const WizardTamizajeProWidget({super.key});

  static const String routeName = 'wizardTamizajePro';
  static const String routePath = '/wizardTamizajePro';

  @override
  State<WizardTamizajeProWidget> createState() =>
      _WizardTamizajeProWidgetState();
}

class _WizardTamizajeProWidgetState extends State<WizardTamizajeProWidget> {
  int _paso = 0;

  // Shared state across steps.
  UsersRecord? _adolescenteSeleccionado;
  EncuestasRecord? _tamizajeSeleccionado;
  final List<RespuestaTestStruct> _respuestas = [];
  int _puntajeTotal = 0;
  bool _tieneIdeacion = false;
  String _notas = '';
  DocumentReference? _respuestaCreadaRef;

  void _avanzar() => setState(() => _paso++);
  void _retroceder() => setState(() => _paso = (_paso - 1).clamp(0, 3));

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF265294),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // En Resultados el tamizaje ya está guardado: no se vuelve al
        // formulario (evita reenviarlo y duplicarlo).
        leading: _paso == 0 || _paso == 3
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _retroceder,
              ),
        title: Text(
          'Nuevo tamizaje',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MobileStepper(paso: _paso, theme: theme),
            Expanded(
              child: IndexedStack(
                index: _paso,
                children: [
                  PasoSeleccionAdolescente(
                    onSeleccionado: (u) {
                      setState(() => _adolescenteSeleccionado = u);
                      _avanzar();
                    },
                  ),
                  PasoSeleccionTamizaje(
                    onSeleccionado: (e) {
                      setState(() => _tamizajeSeleccionado = e);
                      _avanzar();
                    },
                  ),
                  _tamizajeSeleccionado == null
                      ? const SizedBox.shrink()
                      : PasoFormulario(
                          // Key por id del tamizaje: fuerza recrear el State
                          // cuando el profesional cambia de tamizaje.
                          key: ValueKey(
                              'formulario_${_tamizajeSeleccionado!.reference.id}'),
                          encuesta: _tamizajeSeleccionado!,
                          adolescente: _adolescenteSeleccionado,
                          onFinalizado: (resp, puntaje, ideacion) {
                            setState(() {
                              _respuestas
                                ..clear()
                                ..addAll(resp);
                              _puntajeTotal = puntaje;
                              _tieneIdeacion = ideacion;
                            });
                            return _guardarYAvanzar();
                          },
                        ),
                  PasoResultados(
                    encuesta: _tamizajeSeleccionado,
                    adolescente: _adolescenteSeleccionado,
                    respuestas: _respuestas,
                    puntajeTotal: _puntajeTotal,
                    tieneIdeacion: _tieneIdeacion,
                    notas: _notas,
                    respuestaRef: _respuestaCreadaRef,
                    onNotasGuardadas: (n) => setState(() => _notas = n),
                    onCerrar: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Guarda la respuesta y pasa a Resultados solo si se guardó.
  Future<bool> _guardarYAvanzar() async {
    if (_adolescenteSeleccionado == null || _tamizajeSeleccionado == null) {
      return false;
    }
    try {
      // Guardar bajo /Encuestas/{encuestaId}/Respuestas/{newId} para que
      // las reglas de Firestore (allow create) ya existentes apliquen.
      // userRespuesta apunta al adolescente para filtrar luego.
      final docRef = RespuestasRecord.createDoc(
        _tamizajeSeleccionado!.reference,
      );
      // Build special alerts list
      final List<String> specialAlerts = [];
      if (_tieneIdeacion) {
        specialAlerts.add('ALERTA: Ideación Suicida detectada');
      }
      // Evaluate alertas especiales defined on the encuesta
      if (_tamizajeSeleccionado!.alertasEspeciales.isNotEmpty) {
        final triggered = evaluarAlertasEspeciales(
          _tamizajeSeleccionado!.alertasEspeciales,
          _respuestas,
        );
        specialAlerts.addAll(triggered);
      }

      final data = createRespuestasRecordData(
        userRespuesta: _adolescenteSeleccionado!.reference,
        fecha: DateTime.now(),
        titlo: _tamizajeSeleccionado!.titulo,
        desc: _tamizajeSeleccionado!.descripcion,
        notasProfesional: '',
        invalidado: false,
        puntajeTotal: _puntajeTotal,
        alertasEspeciales: specialAlerts,
        realizadoPor: currentUserReference,
        tipoTamizaje: 'manual',
      );
      data['test'] = _respuestas.map((e) => e.toMap()).toList();
      await docRef.set(data);
      _respuestaCreadaRef = docRef;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No se pudo guardar el tamizaje. Revisa tu conexión e inténtalo de nuevo.')),
        );
      }
      return false;
    }
    if (mounted) _avanzar();
    return true;
  }
}
