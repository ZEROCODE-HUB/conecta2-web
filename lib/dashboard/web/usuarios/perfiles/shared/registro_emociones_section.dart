import 'package:flutter/material.dart';
import '/user/calendar/emociones_service.dart' show cuandoEmocion;
import 'package:google_fonts/google_fonts.dart';

import '/backend/backend.dart';
import '/components/calendario_read/calendario_read_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'network_avatar.dart';

/// Emotion registry tab used in the adolescent profile view.
class RegistroEmocionesSection extends StatefulWidget {
  const RegistroEmocionesSection({
    super.key,
    required this.userRef,
    required this.calendarioModel,
    required this.onStateChanged,
  });

  final DocumentReference userRef;
  final CalendarioReadModel calendarioModel;
  final VoidCallback onStateChanged;

  @override
  State<RegistroEmocionesSection> createState() => _RegistroEmocionesSectionState();
}

class _RegistroEmocionesSectionState extends State<RegistroEmocionesSection> {
  /// Día elegido en el calendario (null = hoy).
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    // Clear global state when loading a user's emotion profile for the first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FFAppState().emocion = 0;
        FFAppState().description = '';
        widget.onStateChanged();
      }
    });
  }

  @override
  void didUpdateWidget(RegistroEmocionesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear global state if the user changes
    if (oldWidget.userRef != widget.userRef) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FFAppState().emocion = 0;
          FFAppState().description = '';
          _fechaSeleccionada = null;
          widget.onStateChanged();
        }
      });
    }
  }

  String _emotionLabel(int value) {
    switch (value) {
      case 1:
        return 'Enojo';
      case 2:
        return 'Miedo';
      case 3:
        return 'Tristeza';
      case 4:
        return 'Indiferencia';
      case 5:
        return 'Alegría';
      default:
        return 'No registrado';
    }
  }

  String _emotionImage(int value) {
    switch (value) {
      case 1:
        return FFAppConstants.emocion1;
      case 2:
        return FFAppConstants.emocion2;
      case 3:
        return FFAppConstants.emocion3;
      case 4:
        return FFAppConstants.emocion4;
      case 5:
        return FFAppConstants.emocion5;
      default:
        return FFAppConstants.emocionvacia;
    }
  }

  String _emotionRecommendation(int value) {
    switch (value) {
      case 1:
        return FFAppConstants.Enojo;
      case 2:
        return FFAppConstants.Miedo;
      case 3:
        return FFAppConstants.Tristeza;
      case 4:
        return FFAppConstants.Indiferencia;
      case 5:
        return FFAppConstants.Alegra;
      default:
        return 'No registrado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final emocion = FFAppState().emocion;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registro de emociones',
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              fontSize: 24.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40.0),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 780.0;
              final calendar = SizedBox(
                width: 400.0,
                child: wrapWithModel(
                  model: widget.calendarioModel,
                  updateCallback: widget.onStateChanged,
                  updateOnChange: true,
                  child: CalendarioReadWidget(
                    inputDate: getCurrentTimestamp,
                    initialSelectedDate: getCurrentTimestamp,
                    userRef: widget.userRef,
                    onSelectDateAction: (selectedDate) async {
                      if (mounted) {
                        setState(() => _fechaSeleccionada = selectedDate);
                      }
                    },
                  ),
                ),
              );
              final panel = _EmotionPanel(
                titulo: emocion == 0
                    ? '${cuandoEmocion(_fechaSeleccionada)}: sin registro'
                    : '${cuandoEmocion(_fechaSeleccionada)} me sentí',
                emocion: emocion,
                image: _emotionImage(emocion),
                label: _emotionLabel(emocion),
                description: FFAppState().description,
                recommendation: _emotionRecommendation(emocion),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [calendar, const SizedBox(height: 20.0), panel],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  calendar,
                  const SizedBox(width: 20.0),
                  Expanded(child: panel),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmotionPanel extends StatelessWidget {
  const _EmotionPanel({
    required this.titulo,
    required this.emocion,
    required this.image,
    required this.label,
    required this.description,
    required this.recommendation,
  });

  final String titulo;
  final int emocion;
  final String image;
  final String label;
  final String description;
  final String recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 350.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              color: const Color(0xFF1F2129),
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
                child: NetworkAvatar(url: image, size: 31.0),
              ),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (description.isNotEmpty)
            Text(
              description,
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 20.0),
          Text(
            recommendation,
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              fontSize: 14.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
