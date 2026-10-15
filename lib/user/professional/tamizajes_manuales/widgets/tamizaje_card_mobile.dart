import '/backend/backend.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/detalle_tamizaje_view.dart';
import '/tamizajes/shared/widgets/exportar_pdf_button.dart';
import 'tamizaje_actions_menu_mobile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card de tamizaje para la vista mobile del profesional.
class TamizajeCardMobile extends StatelessWidget {
  const TamizajeCardMobile({
    super.key,
    required this.respuesta,
    required this.adolescente,
  });

  final RespuestasRecord respuesta;
  final UsersRecord? adolescente;

  bool _esManual() => respuesta.tipoTamizaje == 'manual';

  @override
  Widget build(BuildContext context) {
    final nombre = adolescente?.displayName ?? 'Paciente';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      // Tocar la tarjeta abre el detalle completo (como "Ver" en la web).
      child: GestureDetector(
        onTap: () => _abrirDetalle(context),
        child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con acento
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFBE5A1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.0),
                  topRight: Radius.circular(14.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      respuesta.titlo.isNotEmpty
                          ? respuesta.titlo
                          : 'Sin titulo',
                      style: GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: kNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _TipoBadge(esManual: _esManual()),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paciente
                  Row(
                    children: [
                      Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: const BoxDecoration(
                          color: kNavy,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            inicial,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: GoogleFonts.inter(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              formatDate(respuesta.fecha),
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF959595),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F9F1),
                          borderRadius: BorderRadius.circular(20.0),
                          border:
                              Border.all(color: kSuccess, width: 0.8),
                        ),
                        child: Text(
                          'Completado',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: kSuccess,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  Container(height: 1.0, color: const Color(0xFFF0F0F0)),
                  const SizedBox(height: 12.0),

                  // Acciones
                  Row(
                    children: [
                      Expanded(
                        child: ExportarPdfButton(
                          respuesta: respuesta,
                          adolescente: adolescente,
                          style: ExportarPdfStyle.mobile,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      TamizajeActionsMenuMobile(
                        respuesta: respuesta,
                        adolescente: adolescente,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _abrirDetalle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: DetalleTamizajeView(
              respuesta: respuesta,
              adolescente: adolescente,
              onVolver: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  const _TipoBadge({required this.esManual});
  final bool esManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: esManual ? const Color(0xFFE3F2FD) : const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: esManual ? kManualBlue : kAppPurple,
          width: 0.8,
        ),
      ),
      child: Text(
        esManual ? 'Manual' : 'App',
        style: GoogleFonts.inter(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: esManual ? kManualBlue : kAppPurple,
        ),
      ),
    );
  }
}
