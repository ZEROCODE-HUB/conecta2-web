import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/shared/listas_fijas.dart';
import '/components/rich_text_notas/rich_text_notas_widget.dart';
import '/custom_code/actions/evaluar_alertas_especiales.dart';
import '/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/assist_utils.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import '/tamizajes/shared/widgets/riesgo_sustancias_card.dart';
import '/user/professional/tamizajes_manuales/wizard/state/respuesta_state.dart'
    show PreguntaTipo, RespuestaState, VisibilidadAssist;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'wizard_parts/stepper.dart';
part 'wizard_parts/paso_adolescente.dart';
part 'wizard_parts/paso_tamizaje.dart';
part 'wizard_parts/paso_formulario.dart';
part 'wizard_parts/paso_resultados.dart';

/// Color principal de la plataforma (navy).
const Color _kNavy = Color(0xFF265294);

/// Wizard de 4 pasos para crear un tamizaje manual.
///
/// Puede funcionar embebido dentro del layout del dashboard (sin Scaffold)
/// cuando se le pasa un [onClose], o como pantalla completa cuando no se
/// proporciona ese callback.
///
///   1) Elegir adolescente (existente o registrar nuevo).
///   2) Elegir tamizaje a aplicar.
///   3) Realizar el tamizaje (responder pregunta a pregunta).
///   4) Resultados + notas del profesional + (opcional) recordatorio.
class WizardTamizajeManualWidget extends StatefulWidget {
  const WizardTamizajeManualWidget({super.key, this.onClose});

  /// Callback opcional para cerrar el wizard cuando está embebido.
  /// Si es `null`, se usará `Navigator.of(context).pop()`.
  final VoidCallback? onClose;

  @override
  State<WizardTamizajeManualWidget> createState() =>
      _WizardTamizajeManualWidgetState();
}

class _WizardTamizajeManualWidgetState
    extends State<WizardTamizajeManualWidget> {
  int _paso = 0;

  // Estado compartido entre pasos.
  UsersRecord? _adolescenteSeleccionado;
  EncuestasRecord? _tamizajeSeleccionado;
  final List<RespuestaTestStruct> _respuestas = [];
  int _puntajeTotal = 0;
  bool _tieneIdeacion = false;
  String _notas = '';
  DocumentReference? _respuestaCreadaRef;
  bool _invalidadoDuranteDesarrollo = false;

  void _avanzar() => setState(() => _paso++);
  void _retroceder() => setState(() => _paso = (_paso - 1).clamp(0, 3));

  void _cerrar() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final content = Column(
      children: [
        _WizardHeader(theme: theme, onClose: _cerrar),
        _Stepper(paso: _paso, theme: theme),
        Divider(height: 1, color: theme.alternate),
        Expanded(
          child: IndexedStack(
            index: _paso,
            children: [
              _PasoSeleccionAdolescente(
                onSeleccionado: (u) {
                  setState(() => _adolescenteSeleccionado = u);
                  _avanzar();
                },
              ),
              _PasoSeleccionTamizaje(
                onSeleccionado: (e) {
                  setState(() => _tamizajeSeleccionado = e);
                  _avanzar();
                },
                onAtras: _retroceder,
              ),
              _tamizajeSeleccionado == null
                  ? const SizedBox()
                  : _PasoFormulario(
                      // Key basada en el id del tamizaje: al cambiar el
                      // tamizaje seleccionado, Flutter reconstruye el State
                      // y recarga las preguntas correctas.
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
                          _invalidadoDuranteDesarrollo = false;
                        });
                        return _guardarYAvanzar();
                      },
                      onAtras: _retroceder,
                      onInvalidar: () {
                        setState(
                            () => _invalidadoDuranteDesarrollo = true);
                        _guardarInvalidado();
                      },
                    ),
              _PasoResultados(
                encuesta: _tamizajeSeleccionado,
                adolescente: _adolescenteSeleccionado,
                respuestas: _respuestas,
                puntajeTotal: _puntajeTotal,
                tieneIdeacion: _tieneIdeacion,
                notas: _notas,
                respuestaRef: _respuestaCreadaRef,
                onNotasGuardadas: (n) => setState(() => _notas = n),
                onCerrar: _cerrar,
              ),
            ],
          ),
        ),
      ],
    );

    // Si hay onClose => está embebido: no usar Scaffold (mantenemos el layout
    // externo con el sidebar). Si no, usar Scaffold como pantalla completa.
    if (widget.onClose != null) {
      return Container(
        color: theme.primaryBackground,
        child: content,
      );
    }
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: content,
    );
  }

  Future<void> _guardarInvalidado() async {
    if (_adolescenteSeleccionado == null || _tamizajeSeleccionado == null) {
      return;
    }
    try {
      final docRef = RespuestasRecord.createDoc(
        _tamizajeSeleccionado!.reference,
      );
      final ahora = DateTime.now();
      final data = createRespuestasRecordData(
        userRespuesta: _adolescenteSeleccionado!.reference,
        fecha: ahora,
        titlo: _tamizajeSeleccionado!.titulo,
        desc: _tamizajeSeleccionado!.descripcion,
        notasProfesional: '',
        invalidado: true,
        fechaInvalidacion: ahora,
        bloqueadoHasta: ahora.add(const Duration(hours: 24)),
        invalidadoPor: currentUserReference,
        puntajeTotal: 0,
        alertasEspeciales: const [],
        realizadoPor: currentUserReference,
        tipoTamizaje: 'manual',
      );
      await docRef.set(data);
      _respuestaCreadaRef = docRef;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'No se pudo registrar la invalidación. Revisa tu conexión e inténtalo de nuevo.')),
        );
        setState(() => _invalidadoDuranteDesarrollo = false);
      }
      return;
    }
    if (mounted) setState(() => _paso = 3);
  }

  /// Guarda la respuesta y pasa a Resultados solo si se guardó.
  Future<bool> _guardarYAvanzar() async {
    if (_adolescenteSeleccionado == null || _tamizajeSeleccionado == null) {
      return false;
    }
    try {
      // Guardar bajo /Encuestas/{encuestaId}/Respuestas/{newId} (mismo
      // path que usa el adolescente, ya con permisos abiertos en las reglas).
      // El campo userRespuesta apunta al adolescente para filtrar después.
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
          const SnackBar(
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

// ─────────────────────────────────────────────────────────────────────────────
// Header embebido del wizard (reemplaza al AppBar)
// ─────────────────────────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.theme, required this.onClose});

  final FlutterFlowTheme theme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back,
                        color: _kNavy, size: 20.0),
                    const SizedBox(width: 6),
                    Text(
                      'Volver al listado',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: theme.alternate),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _kNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(Icons.note_add_outlined,
                color: _kNavy, size: 22.0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nuevo Tamizaje Manual',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kNavy,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
