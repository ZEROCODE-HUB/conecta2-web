import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/tamizaje_tabla_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabla del Listado de Encuestas: adolescente, encuesta, fecha y "Ver".
/// Las encuestas no puntúan, así que no hay columnas de puntaje ni alertas.
class TablaEncuestas extends StatelessWidget {
  const TablaEncuestas({
    super.key,
    required this.respuestas,
    required this.usuarios,
    this.onVerDetalle,
  });

  final List<RespuestasRecord> respuestas;
  final Map<DocumentReference, UsersRecord?> usuarios;
  final void Function(RespuestasRecord)? onVerDetalle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: TamizajeTablaWrapper(
        headerColumns: const [
          TamizajeColumna('Adolescente', flex: 3),
          TamizajeColumna('Encuesta', flex: 4),
          TamizajeColumna('Fecha', flex: 2),
          TamizajeColumna('Acciones', flex: 2),
        ],
        rowCount: respuestas.length,
        rowBuilder: (context, index) {
          final r = respuestas[index];
          return _FilaEncuesta(
            respuesta: r,
            nombre: usuarios[r.userRespuesta]?.displayName ?? '—',
            zebra: index.isOdd,
            onVerDetalle: onVerDetalle,
          );
        },
      ),
    );
  }
}

class _FilaEncuesta extends StatelessWidget {
  const _FilaEncuesta({
    required this.respuesta,
    required this.nombre,
    required this.zebra,
    this.onVerDetalle,
  });

  final RespuestasRecord respuesta;
  final String nombre;
  final bool zebra;
  final void Function(RespuestasRecord)? onVerDetalle;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final texto = theme.bodyMedium.override(
      font: GoogleFonts.inter(),
      letterSpacing: 0.0,
    );

    return Container(
      color: zebra ? const Color(0xFFFAFBFC) : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Text(
                nombre.isNotEmpty ? nombre : '—',
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                respuesta.titlo.isNotEmpty ? respuesta.titlo : '—',
                style: texto,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                respuesta.fecha != null
                    ? dateTimeFormat('dd/MM/yyyy', respuesta.fecha)
                    : '—',
                style: texto,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: onVerDetalle == null
                        ? null
                        : () => onVerDetalle!(respuesta),
                    icon: const Icon(Icons.visibility_outlined, size: 13.0),
                    label: const Text('Ver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      textStyle: GoogleFonts.inter(
                          fontSize: 11.0, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
