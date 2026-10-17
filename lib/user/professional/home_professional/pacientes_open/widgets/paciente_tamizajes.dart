import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import '/dashboard/web/encuestas/listado_encuestas/widgets/detalle_encuesta_view.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import '/tamizajes/shared/widgets/detalle_tamizaje_view.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Choice-chip selector between "Encuestas" and "Tamizajes" plus one card
/// per answer of the given patient.
class PacienteTamizajesSection extends StatelessWidget {
  const PacienteTamizajesSection({
    super.key,
    required this.user,
    required this.pacienteRef,
    required this.choiceChipsController,
    required this.onChipChanged,
  });

  final UsersRecord user;
  final DocumentReference pacienteRef;
  final FormFieldController<List<String>> choiceChipsController;
  final ValueChanged<String?> onChipChanged;

  String? get _currentChoice => choiceChipsController.value?.firstOrNull;

  @override
  Widget build(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 15.0),
          child: FlutterFlowChoiceChips(
            options: const [
              ChipData('Encuestas'),
              ChipData('Tamizajes'),
            ],
            onChanged: (val) => onChipChanged(val?.firstOrNull),
            selectedChipStyle: ChipStyle(
              backgroundColor: const Color(0xFF265294),
              textStyle: bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryBackground,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: bodyMedium.fontStyle,
              ),
              iconColor: FlutterFlowTheme.of(context).primaryText,
              iconSize: 18.0,
              elevation: 4.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            unselectedChipStyle: ChipStyle(
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              textStyle: bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: bodyMedium.fontWeight,
                  fontStyle: bodyMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight: bodyMedium.fontWeight,
                fontStyle: bodyMedium.fontStyle,
              ),
              iconColor: FlutterFlowTheme.of(context).secondaryText,
              iconSize: 18.0,
              elevation: 0.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            chipSpacing: 0.0,
            rowSpacing: 12.0,
            multiselect: false,
            initialized: _currentChoice != null,
            alignment: WrapAlignment.spaceEvenly,
            controller: choiceChipsController,
            wrapped: true,
          ),
        ),
        _RespuestasPaciente(
          user: user,
          pacienteRef: pacienteRef,
          choice: _currentChoice,
        ),
      ],
    );
  }
}

/// Una tarjeta por cada respuesta del paciente a los cuestionarios del tipo
/// [choice] (incluidos los tamizajes manuales), de la más reciente a la más
/// antigua.
class _RespuestasPaciente extends StatefulWidget {
  const _RespuestasPaciente({
    required this.user,
    required this.pacienteRef,
    required this.choice,
  });

  final UsersRecord user;
  final DocumentReference pacienteRef;
  final String? choice;

  @override
  State<_RespuestasPaciente> createState() => _RespuestasPacienteState();
}

class _RespuestasPacienteState extends State<_RespuestasPaciente> {
  late Future<List<(EncuestasRecord, RespuestasRecord)>> _respuestas;

  @override
  void initState() {
    super.initState();
    _respuestas = _cargar();
  }

  @override
  void didUpdateWidget(covariant _RespuestasPaciente oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pacienteRef != widget.pacienteRef ||
        oldWidget.choice != widget.choice) {
      _respuestas = _cargar();
    }
  }

  Future<List<(EncuestasRecord, RespuestasRecord)>> _cargar() async {
    final todas = await TamizajeService.respuestasDePaciente(widget.pacienteRef);
    return todas
        .where((p) => widget.choice == null || p.$1.tipo == widget.choice)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<(EncuestasRecord, RespuestasRecord)>>(
      future: _respuestas,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: TamizajeEmptyState(
              icon: Icons.error_outline,
              mensaje: 'No se pudieron cargar las respuestas',
            ),
          );
        }
        final respuestas = snapshot.data ?? const [];
        if (respuestas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: TamizajeEmptyState(
              icon: Icons.assignment_outlined,
              mensaje: 'Sin respuestas',
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: respuestas.length,
          itemBuilder: (context, index) => _RespuestaTile(
            encuesta: respuestas[index].$1,
            respuesta: respuestas[index].$2,
            user: widget.user,
            choice: widget.choice,
          ),
        );
      },
    );
  }
}

class _RespuestaTile extends StatelessWidget {
  const _RespuestaTile({
    required this.encuesta,
    required this.respuesta,
    required this.user,
    required this.choice,
  });

  final EncuestasRecord encuesta;
  final RespuestasRecord respuesta;
  final UsersRecord user;
  final String? choice;

  void _abrirDetalle(BuildContext context) {
    // Respuestas antiguas guardadas solo en `Respusta`: la pantalla anterior
    // sabe mostrarlas.
    if (respuesta.test.isEmpty && respuesta.respusta.isNotEmpty) {
      context.pushNamed(
        PacientRespuestaWidget.routeName,
        queryParameters: {
          'choice': serializeParam(choice, ParamType.String),
          'encuesta': serializeParam(respuesta, ParamType.Document),
        }.withoutNulls,
        extra: <String, dynamic>{'encuesta': respuesta},
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: choice == 'Tamizajes'
                ? DetalleTamizajeView(
                    respuesta: respuesta,
                    adolescente: user,
                    onVolver: () => Navigator.of(ctx).pop(),
                  )
                : DetalleEncuestaView(
                    respuesta: respuesta,
                    usuario: user,
                    onVolver: () => Navigator.of(ctx).pop(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _etiqueta(
    BuildContext context,
    String texto, {
    required Color fondo,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        texto,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w500),
              color: color,
              fontSize: 11.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bodyMedium = theme.bodyMedium;
    final titulo =
        encuesta.titulo.isNotEmpty ? encuesta.titulo : respuesta.titlo;
    final fecha = respuesta.fecha;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () => _abrirDetalle(context),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidFileLines,
                        color: Color(0xFF265294),
                        size: 24.0,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              15.0, 0.0, 15.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                overflow: TextOverflow.ellipsis,
                                style: bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: bodyMedium.fontStyle,
                                  ),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: bodyMedium.fontStyle,
                                ),
                              ),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 4.0,
                                children: [
                                  Text(
                                    fecha != null
                                        ? dateTimeFormat(
                                            "yMMMd",
                                            fecha,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )
                                        : 'Sin fecha',
                                    style: bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: bodyMedium.fontStyle,
                                      ),
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: bodyMedium.fontStyle,
                                    ),
                                  ),
                                  // Aplicado por un profesional (wizard
                                  // manual), no respondido por el adolescente.
                                  if (respuesta.realizadoPor != null) ...[
                                    const SizedBox(width: 8.0),
                                    _etiqueta(
                                      context,
                                      'Tamizaje manual',
                                      fondo: const Color(0xFF265294)
                                          .withValues(alpha: 0.1),
                                      color: const Color(0xFF265294),
                                    ),
                                  ],
                                  if (respuesta.invalidado) ...[
                                    const SizedBox(width: 8.0),
                                    _etiqueta(
                                      context,
                                      'Invalidada',
                                      fondo: theme.alternate,
                                      color: theme.secondaryText,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 20.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF265294),
                    size: 24.0,
                  ),
                  onPressed: () => _abrirDetalle(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
