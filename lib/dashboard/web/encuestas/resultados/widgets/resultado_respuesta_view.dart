import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders the list of answers for a selected question, filtered by [tipo].
///
/// The UI adapts to the question type (abiertas, selección, Verdadero o
/// falso, Selección única, Tamizaje, Condicionante). When [tipo] is null
/// (nothing selected), the raw list of responding users is rendered.
class ResultadoRespuestaView extends StatelessWidget {
  const ResultadoRespuestaView({
    super.key,
    required this.respuestas,
    required this.tipo,
    required this.itemIndex,
  });

  final List<RespuestasRecord> respuestas;
  final String? tipo;
  final int? itemIndex;

  @override
  Widget build(BuildContext context) {
    if (tipo == null || itemIndex == null) {
      return _buildUserList(
        context,
        respuestas,
        trailing: (_) => null,
      );
    }

    final filtered =
        respuestas.where((e) => e.test.elementAtOrNull(itemIndex!)?.tipo == tipo).toList();

    switch (tipo) {
      case 'abiertas':
        return _buildUserList(
          context,
          filtered,
          trailing: (item) => _trailingText(
            context,
            valueOrDefault<String>(
              item.test.elementAtOrNull(itemIndex!)?.respuesta,
              'Empty',
            ),
          ),
        );
      case 'selección':
        return _buildUserList(
          context,
          filtered,
          trailing: (item) => _trailingText(
            context,
            valueOrDefault<String>(
              item.test.elementAtOrNull(itemIndex!)?.select2,
              'null',
            ),
          ),
        );
      case 'Verdadero o falso':
        return _buildUserList(
          context,
          filtered,
          trailing: (item) {
            final r = item.test.elementAtOrNull(itemIndex!);
            return _trailingText(
              context,
              r == null || !r.hasTrueAndFalse()
                  ? 'Sin respuesta'
                  : (r.trueAndFalse == 1 ? 'Verdadero' : 'Falso'),
            );
          },
        );
      case 'Selección única':
        return _buildUserList(
          context,
          filtered,
          trailing: (item) {
            final t = valueOrDefault<String>(
                item.test.elementAtOrNull(itemIndex!)?.tipo, 'Nunca');
            if (t == 'Tamizaje') return null;
            return _trailingText(
              context,
              valueOrDefault<String>(
                item.test.elementAtOrNull(itemIndex!)?.respuestaSeleccionUnica,
                'Nunca',
              ),
            );
          },
        );
      case 'Tamizaje':
        return _buildUserList(
          context,
          filtered,
          trailing: (item) {
            final t = valueOrDefault<String>(
                item.test.elementAtOrNull(itemIndex!)?.tipo, 'Nunca');
            if (t != 'Tamizaje') return null;
            return _trailingText(
              context,
              valueOrDefault<String>(
                item.test.elementAtOrNull(itemIndex!)?.respuestaTamizaje.firstOrNull?.etiqueta,
                'Nunca',
              ),
            );
          },
        );
      case 'Condicionante':
        return _buildUserList(
          context,
          filtered,
          trailing: (item) {
            final selecciones =
                item.test.elementAtOrNull(itemIndex!)?.respuestasSeleccionadas.toList() ?? [];
            final t = valueOrDefault<String>(
                item.test.elementAtOrNull(itemIndex!)?.tipo, 'Nunca');
            if (t != 'Condicionante') return null;
            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selecciones
                  .map((s) => Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 10),
                        child: Text(
                          s,
                          textAlign: TextAlign.start,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight:
                                      FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle:
                                      FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                                letterSpacing: 0.0,
                              ),
                        ),
                      ))
                  .toList(),
            );
          },
        );
      default:
        return _buildUserList(
          context,
          respuestas,
          trailing: (_) => null,
        );
    }
  }

  Widget _buildUserList(
    BuildContext context,
    List<RespuestasRecord> items, {
    required Widget? Function(RespuestasRecord item) trailing,
  }) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final trailingWidget = trailing(item);
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _UserHeader(userRef: item.userRespuesta),
                ),
                if (trailingWidget != null) trailingWidget,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _trailingText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 10),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.userRef});

  final DocumentReference? userRef;

  @override
  Widget build(BuildContext context) {
    if (userRef == null) {
      return _userRow(context, photoUrl: null, displayName: 'Empty');
    }
    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(userRef!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final user = snapshot.data!;
        return _userRow(
          context,
          photoUrl: user.photoUrl,
          displayName: user.displayName,
        );
      },
    );
  }

  Widget _userRow(
    BuildContext context, {
    required String? photoUrl,
    required String displayName,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 33,
          height: 33,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: (photoUrl != null && photoUrl.isNotEmpty)
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Image.asset('assets/images/User.png', fit: BoxFit.cover),
                )
              : Image.asset('assets/images/User.png', fit: BoxFit.cover),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
          child: Text(
            valueOrDefault<String>(displayName, 'Empty'),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  fontSize: 18,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
