import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/tamizaje_page_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Detalle de una respuesta a encuesta: cada pregunta con su respuesta según
/// el tipo (abiertas, selección, selección única, verdadero o falso).
/// Sin puntaje, alertas ni notas clínicas.
class DetalleEncuestaView extends StatelessWidget {
  const DetalleEncuestaView({
    super.key,
    required this.respuesta,
    required this.onVolver,
    this.usuario,
  });

  final RespuestasRecord respuesta;
  final UsersRecord? usuario;
  final VoidCallback onVolver;

  /// Texto de la respuesta para mostrar, según el tipo de pregunta.
  static String textoRespuesta(RespuestaTestStruct item) {
    const sinRespuesta = 'Sin respuesta';
    switch (item.tipo) {
      case 'abiertas':
        return item.respuesta.trim().isNotEmpty
            ? item.respuesta.trim()
            : sinRespuesta;
      case 'selección':
        return item.respuestasSeleccionadas.isNotEmpty
            ? item.respuestasSeleccionadas.join(', ')
            : sinRespuesta;
      case 'Selección única':
        return item.respuestaSeleccionUnica.isNotEmpty
            ? item.respuestaSeleccionUnica
            : sinRespuesta;
      case 'Verdadero o falso':
        if (!item.hasTrueAndFalse()) return sinRespuesta;
        return item.trueAndFalse == 1 ? 'Verdadero' : 'Falso';
      default:
        // Tipos antiguos: se muestra lo que haya guardado.
        if (item.respuesta.isNotEmpty) return item.respuesta;
        if (item.respuestasSeleccionadas.isNotEmpty) {
          return item.respuestasSeleccionadas.join(', ');
        }
        if (item.respuestaSeleccionUnica.isNotEmpty) {
          return item.respuestaSeleccionUnica;
        }
        return sinRespuesta;
    }
  }

  static String _etiquetaTipo(String tipo) {
    switch (tipo) {
      case 'abiertas':
        return 'Abierta';
      case 'selección':
        return 'Selección múltiple';
      case 'Selección única':
        return 'Selección única';
      case 'Verdadero o falso':
        return 'Verdadero o falso';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final items =
        respuesta.test.where((t) => t.tipo != 'Descriptiva').toList();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TamizajePageHeader(
            titulo: respuesta.titlo.isNotEmpty ? respuesta.titlo : 'Encuesta',
            breadcrumb: 'Volver al listado',
            onVolver: onVolver,
            icon: Icons.assignment_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Resumen(
                    nombre: usuario?.displayName ?? '—',
                    fecha: respuesta.fecha,
                    total: items.length,
                  ),
                  const SizedBox(height: 16.0),
                  if (items.isEmpty)
                    Text(
                      'Esta respuesta no tiene preguntas registradas.',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  for (var i = 0; i < items.length; i++)
                    _PreguntaRespuesta(
                      numero: i + 1,
                      pregunta: items[i].pregunta,
                      tipo: _etiquetaTipo(items[i].tipo),
                      respuesta: textoRespuesta(items[i]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({
    required this.nombre,
    required this.fecha,
    required this.total,
  });

  final String nombre;
  final DateTime? fecha;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget dato(String etiqueta, String valor) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              etiqueta,
              style: GoogleFonts.inter(
                fontSize: 12.0,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              valor,
              style: GoogleFonts.inter(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ],
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Wrap(
        spacing: 48.0,
        runSpacing: 12.0,
        children: [
          dato('Adolescente', nombre.isNotEmpty ? nombre : '—'),
          dato(
            'Fecha',
            fecha != null ? dateTimeFormat('dd/MM/yyyy HH:mm', fecha) : '—',
          ),
          dato('Preguntas', '$total'),
        ],
      ),
    );
  }
}

class _PreguntaRespuesta extends StatelessWidget {
  const _PreguntaRespuesta({
    required this.numero,
    required this.pregunta,
    required this.tipo,
    required this.respuesta,
  });

  final int numero;
  final String pregunta;
  final String tipo;
  final String respuesta;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$numero. ${pregunta.isNotEmpty ? pregunta : '(sin texto)'}',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: kNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  tipo,
                  style: GoogleFonts.inter(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: kNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            respuesta,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
