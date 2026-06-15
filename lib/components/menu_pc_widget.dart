import '/auth/firebase_auth/auth_util.dart';
import '/components/menuselect_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_pc_model.dart';
export 'menu_pc_model.dart';

class MenuPcWidget extends StatefulWidget {
  const MenuPcWidget({super.key});

  @override
  State<MenuPcWidget> createState() => _MenuPcWidgetState();
}

class _MenuPcWidgetState extends State<MenuPcWidget> {
  late MenuPcModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuPcModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Keep `_model.select` aligned with the current URL so the
      // active menu item highlights correctly on first paint and
      // after deep links.
      final s = WebSection.fromPath(GoRouterState.of(context).uri.path);
      if (s != null) _model.select = s.legacySelect;
      safeSetState(() {});
    });
  }

  /// Navigates to the given section via the router and keeps the legacy
  /// `_model.select` value in sync so [MenuselectWidget] keeps rendering
  /// the right "active" state until that logic is also migrated.
  void _goToSection(WebSection section) {
    _model.select = section.legacySelect;
    _model.updatePage(() {});
    context.go(section.fullPath);
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.25,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: BoxDecoration(
        color: Color(0xFF265294),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(25.0),
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 40.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Group_1.png',
                      width: 220.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AuthUserStreamWidget(
                  builder: (context) => InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (valueOrDefault(currentUserDocument?.rol, '') ==
                          'Administrador') {
                        _goToSection(WebSection.usuarios);
                      } else {
                        _goToSection(WebSection.pacientes);
                      }
                    },
                    child: wrapWithModel(
                      model: _model.menuselectModel1,
                      updateCallback: () => safeSetState(() {}),
                      updateOnChange: true,
                      child: MenuselectWidget(
                        icon: FaIcon(
                          FontAwesomeIcons.users,
                          color: FlutterFlowTheme.of(context).accent1,
                          size: 18.0,
                        ),
                        text: valueOrDefault(currentUserDocument?.rol, '') ==
                                'Administrador'
                            ? 'Usuarios'
                            : 'Pacientes',
                        select: _model.select,
                        activeKey: 'Usuarios,Pacientes',
                      ),
                    ),
                  ),
                ),
                if (valueOrDefault(currentUserDocument?.rol, '') ==
                    'Profesional')
                  AuthUserStreamWidget(
                    builder: (context) => InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _goToSection(WebSection.recordatorios);
                      },
                      child: wrapWithModel(
                        model: _model.menuselectModel2,
                        updateCallback: () => safeSetState(() {}),
                        updateOnChange: true,
                        child: MenuselectWidget(
                          icon: Icon(
                            Icons.check_box,
                            color: FlutterFlowTheme.of(context).accent1,
                            size: 18.0,
                          ),
                          text: 'Recordatarios',
                          select: _model.select,
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _goToSection(WebSection.encuestas);
                  },
                  child: wrapWithModel(
                    model: _model.menuselectModel3,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: MenuselectWidget(
                      icon: Icon(
                        Icons.library_books,
                        color: FlutterFlowTheme.of(context).accent1,
                        size: 18.0,
                      ),
                      text: 'Encuestas',
                      select: _model.select,
                      activeKey: 'Encuestas,ProfesionalEncuestas',
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _goToSection(WebSection.tamizajes);
                  },
                  child: wrapWithModel(
                    model: _model.menuselectModel4,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: MenuselectWidget(
                      icon: Icon(
                        Icons.layers,
                        color: FlutterFlowTheme.of(context).accent1,
                        size: 18.0,
                      ),
                      text: 'Tamizajes',
                      select: _model.select,
                      activeKey: 'Tamizajes,ProfesionalTamizajes',
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _goToSection(WebSection.tamizajesManuales);
                  },
                  child: wrapWithModel(
                    model: _model.menuselectModel5,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: MenuselectWidget(
                      icon: Icon(
                        Icons.precision_manufacturing,
                        color: FlutterFlowTheme.of(context).accent1,
                        size: 18.0,
                      ),
                      text: 'Tamizajes manuales',
                      select: _model.select,
                      activeKey: 'ProfesionalTamizajesManuales',
                    ),
                  ),
                ),
                if (valueOrDefault(currentUserDocument?.rol, '') ==
                    'Administrador')
                  AuthUserStreamWidget(
                    builder: (context) => InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (valueOrDefault(currentUserDocument?.rol, '') ==
                            'Administrador') {
                          _goToSection(WebSection.instituciones);
                        }
                      },
                      child: wrapWithModel(
                        model: _model.menuselectModel6,
                        updateCallback: () => safeSetState(() {}),
                        updateOnChange: true,
                        child: MenuselectWidget(
                          icon: Icon(
                            Icons.business,
                            color: FlutterFlowTheme.of(context).accent1,
                            size: 18.0,
                          ),
                          text: 'Instituciones',
                          select: _model.select,
                        ),
                      ),
                    ),
                  ),
                if (valueOrDefault(currentUserDocument?.rol, '') ==
                    'Administrador')
                  AuthUserStreamWidget(
                    builder: (context) => InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (valueOrDefault(currentUserDocument?.rol, '') ==
                            'Administrador') {
                          _goToSection(WebSection.barrios);
                        }
                      },
                      child: wrapWithModel(
                        model: _model.menuselectModel7,
                        updateCallback: () => safeSetState(() {}),
                        updateOnChange: true,
                        child: MenuselectWidget(
                          icon: Icon(
                            Icons.map_sharp,
                            color: FlutterFlowTheme.of(context).accent1,
                            size: 18.0,
                          ),
                          text: 'Barrios',
                          select: _model.select,
                        ),
                      ),
                    ),
                  ),
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                  tabletLandscape: false,
                  desktop: false,
                ))
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      _goToSection(WebSection.notificaciones);
                    },
                    child: wrapWithModel(
                      model: _model.menuselectModel8,
                      updateCallback: () => safeSetState(() {}),
                      updateOnChange: true,
                      child: MenuselectWidget(
                        icon: Icon(
                          Icons.notifications,
                          color: FlutterFlowTheme.of(context).accent1,
                          size: 18.0,
                        ),
                        text: 'Notificaciones',
                        select: _model.select,
                      ),
                    ),
                  ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _goToSection(WebSection.contenido);
                  },
                  child: wrapWithModel(
                    model: _model.menuselectModel9,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: MenuselectWidget(
                      icon: Icon(
                        Icons.menu_book,
                        color: FlutterFlowTheme.of(context).accent1,
                        size: 18.0,
                      ),
                      text: 'Contenido',
                      select: _model.select,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Builder(
                      builder: (context) {
                        final enEstadisticas = _model.select ==
                                WebSection.estadisticas.legacySelect ||
                            _model.select == WebSection.mapa.legacySelect ||
                            _model.select == WebSection.excel.legacySelect;
                        final tema = FlutterFlowTheme.of(context);
                        return InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.subMenu = _model.subMenu ? false : true;
                            safeSetState(() {});
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: valueOrDefault<Color>(
                                enEstadisticas ? tema.alternate : tema.menuWeb,
                                tema.menuWeb,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 8.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.query_stats_sharp,
                                    color: tema.accent1,
                                    size: 24.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Estadisticas',
                                      style: tema.bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              tema.bodyMedium.fontWeight,
                                          fontStyle: tema.bodyMedium.fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          enEstadisticas
                                              ? const Color(0xFF265294)
                                              : tema.accent1,
                                          tema.accent1,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: tema.bodyMedium.fontWeight,
                                        fontStyle: tema.bodyMedium.fontStyle,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: tema.accent1,
                                    size: 24.0,
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_model.subMenu)
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF16407F),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _goToSection(WebSection.estadisticas);
                              },
                              child: wrapWithModel(
                                model: _model.menuselectModel10,
                                updateCallback: () => safeSetState(() {}),
                                updateOnChange: true,
                                child: MenuselectWidget(
                                  icon: Icon(
                                    Icons.insert_chart_rounded,
                                    color: FlutterFlowTheme.of(context).accent1,
                                    size: 18.0,
                                  ),
                                  text: 'Graficos',
                                  activeKey:
                                      WebSection.estadisticas.legacySelect,
                                  select: _model.select,
                                ),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _goToSection(WebSection.mapa);
                              },
                              child: wrapWithModel(
                                model: _model.menuselectModel11,
                                updateCallback: () => safeSetState(() {}),
                                updateOnChange: true,
                                child: MenuselectWidget(
                                  icon: Icon(
                                    Icons.map,
                                    color: FlutterFlowTheme.of(context).accent1,
                                    size: 18.0,
                                  ),
                                  text: 'Mapa',
                                  activeKey: WebSection.mapa.legacySelect,
                                  select: _model.select,
                                ),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _goToSection(WebSection.excel);
                              },
                              child: wrapWithModel(
                                model: _model.menuselectModel12,
                                updateCallback: () => safeSetState(() {}),
                                updateOnChange: true,
                                child: MenuselectWidget(
                                  icon: Icon(
                                    Icons.folder,
                                    color: FlutterFlowTheme.of(context).accent1,
                                    size: 18.0,
                                  ),
                                  text: 'Tabulación general',
                                  activeKey: WebSection.excel.legacySelect,
                                  select: _model.select,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _goToSection(WebSection.perfil);
                  },
                  child: wrapWithModel(
                    model: _model.menuselectModel13,
                    updateCallback: () => safeSetState(() {}),
                    updateOnChange: true,
                    child: MenuselectWidget(
                      icon: Icon(
                        Icons.settings_sharp,
                        color: FlutterFlowTheme.of(context).accent1,
                        size: 18.0,
                      ),
                      text: 'Ajustes de perfil',
                      select: _model.select,
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 10.0)),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 50.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();

                      FFAppState().EmailAdmin = '';
                      FFAppState().PasswordAdmin = '';
                      safeSetState(() {});

                      context.goNamedAuth(
                        LoginWidget.routeName,
                        context.mounted,
                        extra: <String, dynamic>{
                          '__transition_info__': TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    child: wrapWithModel(
                      model: _model.menuselectModel14,
                      updateCallback: () => safeSetState(() {}),
                      updateOnChange: true,
                      child: MenuselectWidget(
                        icon: FaIcon(
                          FontAwesomeIcons.rightFromBracket,
                          color: FlutterFlowTheme.of(context).accent1,
                          size: 18.0,
                        ),
                        text: 'Cerrar sesión',
                        select: _model.select,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 8.0, 16.0, 12.0),
                    child: Text(
                      'v.1.1.10',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 11.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
