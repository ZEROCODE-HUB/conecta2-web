import '/components/footer_professionals/footer_professionals_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modelos de tamizajes (profesional, móvil): plantillas publicadas en
/// solo lectura. Botón 4 del menú del profesional.
class ModelosTamizajesWidget extends StatefulWidget {
  const ModelosTamizajesWidget({super.key});

  static String routeName = 'modelosTamizajes';
  static String routePath = '/modelosTamizajes';

  @override
  State<ModelosTamizajesWidget> createState() => _ModelosTamizajesWidgetState();
}

class _ModelosTamizajesWidgetState extends State<ModelosTamizajesWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 100.0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80.0),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 4.0, 16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined,
                                  color: kNavy, size: 24.0),
                              const SizedBox(width: 8.0),
                              Text(
                                'Modelos de tamizajes',
                                style: theme.headlineSmall.override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700),
                                  color: kNavy,
                                  fontSize: 20.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Aquí verás las plantillas de los tamizajes publicados.',
                          style: GoogleFonts.inter(
                              fontSize: 14.0, color: const Color(0xFF6B6B6B)),
                        ),
                      ],
                    ),
                  ),
                ),
                const Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: FooterProfessionalsWidget(active: 4),
                ),
                const ProfesionalHeaderWidget(name: 'Modelos'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
