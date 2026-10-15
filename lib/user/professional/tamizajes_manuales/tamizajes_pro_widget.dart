import '/auth/firebase_auth/auth_util.dart';
import '/components/footer_professionals/footer_professionals_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import 'widgets/tamizajes_pro_list_stream.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tamizajes_pro_model.dart';
export 'tamizajes_pro_model.dart';

class TamizajesProWidget extends StatefulWidget {
  const TamizajesProWidget({super.key});

  static String routeName = 'tamizajesPro';
  static String routePath = '/tamizajesPro';

  @override
  State<TamizajesProWidget> createState() => _TamizajesProWidgetState();
}

class _TamizajesProWidgetState extends State<TamizajesProWidget> {
  late TamizajesProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TamizajesProModel());
    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final profesionalRef = currentUserReference;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 65.0),
            child: FloatingActionButton.extended(
              onPressed: () => context.pushNamed('wizardTamizajePro'),
              backgroundColor: kNavy,
              icon: const Icon(Icons.add, color: Colors.white),
              elevation: 4.0,
              label: Text(
                'Nuevo',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                // Main content
                Container(
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 100.0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 80.0),

                          // Título
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                4.0, 0.0, 4.0, 16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.assignment_outlined,
                                    color: kNavy, size: 24.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Tamizajes Manuales',
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

                          // Barra de búsqueda
                          _SearchBar(
                            controller: _model.searchController!,
                            focusNode: _model.searchFocusNode!,
                            busqueda: _model.busqueda,
                            onChanged: (value) {
                              safeSetState(() {
                                _model.busqueda = value;
                                _model.paginaActual = 0;
                              });
                            },
                            onClear: () {
                              _model.searchController?.clear();
                              safeSetState(() {
                                _model.busqueda = '';
                                _model.paginaActual = 0;
                              });
                            },
                          ),

                          // Toggle orden
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Resultados',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF6B6B6B),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    safeSetState(() {
                                      _model.ordenDescendente =
                                          !_model.ordenDescendente;
                                      _model.paginaActual = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F3F3),
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                          color: const Color(0xFFE0E0E0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _model.ordenDescendente
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          size: 14.0,
                                          color: kNavy,
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          _model.ordenDescendente
                                              ? 'Recientes'
                                              : 'Antiguos',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                            color: kNavy,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Lista de tamizajes
                          if (profesionalRef != null)
                            TamizajesProListStream(
                              profesionalRef: profesionalRef,
                              busqueda: _model.busqueda,
                              ordenDescendente: _model.ordenDescendente,
                              paginaActual: _model.paginaActual,
                              onCambiarPagina: (p) =>
                                  safeSetState(() => _model.paginaActual = p),
                            ),

                          const SizedBox(height: 80.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.footerProfessionalsModel,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: const FooterProfessionalsWidget(active: 3),
                  ),
                ),

                // Header
                wrapWithModel(
                  model: _model.profesionalHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: const ProfesionalHeaderWidget(name: 'Tamizajes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de búsqueda mobile con botón de limpiar.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.busqueda,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String busqueda;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Container(
        width: double.infinity,
        height: 48.0,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 8.0, 0.0),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF959595), size: 22.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar paciente o tamizaje...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF959595),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (busqueda.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 16.0, color: Color(0xFF666666)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
