import '/components/admin_contenido/admin_contenido_widget.dart';
import '/components/admin_encuestas/admin_encuestas_widget.dart';
import '/components/admin_estadsticas/admin_estadsticas_widget.dart';
import '/components/admin_mapa_widget.dart';
import '/components/admin_notificaciones_widget.dart';
import '/components/admin_profile_widget.dart';
import '/dashboard/web/recordatorios/seguimientos_widget.dart';
import '/components/admin_usuarioss_widget.dart';
import '/components/barrios_widget.dart';
import '/dashboard/web/tamizajes_manuales/tamizajes_manuales_widget.dart';
import '/components/excel_page_widget.dart';
import '/components/instituciones_widget.dart';
import '/components/menu_pc_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'web_model.dart';
import 'web_section.dart';
export 'web_model.dart';
export 'web_section.dart';

class WebWidget extends StatefulWidget {
  const WebWidget({super.key, this.section, this.child});

  /// Section to render inside the shell. Comes from child routes under
  /// `/web/...`. When null (root `/web`) we fall back to the default
  /// section so the user never lands on a blank screen.
  final WebSection? section;

  /// When provided, the shell renders this widget instead of the
  /// default section content. Used by deeper routes (e.g. `crear`,
  /// `editar/:id`) that live under a section but show a custom page.
  final Widget? child;

  static String routeName = 'Web';
  static String routePath = '/web';

  /// Section used when the user lands on `/web` without a child path.
  static const WebSection defaultSection = WebSection.usuarios;

  @override
  State<WebWidget> createState() => _WebWidgetState();
}

class _WebWidgetState extends State<WebWidget> {
  late WebModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  WebSection get _activeSection => widget.section ?? WebWidget.defaultSection;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WebModel());
    _syncMenuSelect();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If the user landed on bare `/web`, push them into the default
      // section so the URL always reflects the visible content.
      if (widget.section == null && widget.child == null && mounted) {
        context.go(WebWidget.defaultSection.fullPath);
        return;
      }
      safeSetState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant WebWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) _syncMenuSelect();
  }

  /// Keep the legacy `_model.menuPcModel.select` in sync with the
  /// current route so `MenuselectWidget` highlights the active item.
  ///
  /// Also keeps the Estadísticas submenu open: each `/web/...` child route
  /// builds a new [WebWidget], so [MenuPcModel] is recreated and
  /// `subMenu` would default to false without this.
  void _syncMenuSelect() {
    final menu = _model.menuPcModel;
    final legacy = _activeSection.legacySelect;
    if (menu.select != legacy) {
      menu.select = legacy;
    }
    final enRamaEstadisticas = _activeSection == WebSection.estadisticas ||
        _activeSection == WebSection.mapa ||
        _activeSection == WebSection.excel;
    menu.subMenu = enRamaEstadisticas;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            wrapWithModel(
              model: _model.menuPcModel,
              updateCallback: () => safeSetState(() {}),
              updateOnChange: true,
              child: MenuPcWidget(),
            ),
            Flexible(child: widget.child ?? _buildSection()),
          ],
        ),
      ),
    );
  }

  /// Builds the main content for the current [_activeSection]. Each
  /// widget instantiates its own model internally, so the shell no
  /// longer needs to keep ~15 models alive simultaneously.
  Widget _buildSection() {
    switch (_activeSection) {
      case WebSection.usuarios:
      case WebSection.pacientes:
        return wrapWithModel(
          model: _model.adminUsuariossModel,
          updateCallback: () => safeSetState(() {}),
          updateOnChange: true,
          child: AdminUsuariossWidget(),
        );
      case WebSection.encuestas:
        return wrapWithModel(
          model: _model.adminEncuestasModel,
          updateCallback: () => safeSetState(() {}),
          updateOnChange: true,
          child: AdminEncuestasWidget(tipo: 'Encuestas'),
        );
      case WebSection.tamizajes:
        return wrapWithModel(
          model: _model.adminTamizajesModel,
          updateCallback: () => safeSetState(() {}),
          updateOnChange: true,
          child: AdminEncuestasWidget(tipo: 'Tamizajes'),
        );
      case WebSection.tamizajesManuales:
        return TamizajesManualesWidget();
      case WebSection.notificaciones:
        return wrapWithModel(
          model: _model.adminNotificacionesModel,
          updateCallback: () => safeSetState(() {}),
          updateOnChange: true,
          child: AdminNotificacionesWidget(),
        );
      case WebSection.contenido:
        return wrapWithModel(
          model: _model.adminContenido2Model,
          updateCallback: () => safeSetState(() {}),
          child: AdminContenido2Widget(),
        );
      case WebSection.estadisticas:
        return wrapWithModel(
          model: _model.adminEstadsticas2Model,
          updateCallback: () => safeSetState(() {}),
          child: AdminEstadsticas2Widget(),
        );
      case WebSection.mapa:
        return wrapWithModel(
          model: _model.adminMapaModel,
          updateCallback: () => safeSetState(() {}),
          child: AdminMapaWidget(),
        );
      case WebSection.excel:
        return wrapWithModel(
          model: _model.excelPageModel,
          updateCallback: () => safeSetState(() {}),
          child: ExcelPageWidget(),
        );
      case WebSection.instituciones:
        return wrapWithModel(
          model: _model.institucionesModel,
          updateCallback: () => safeSetState(() {}),
          child: InstitucionesWidget(),
        );
      case WebSection.barrios:
        return wrapWithModel(
          model: _model.barriosModel,
          updateCallback: () => safeSetState(() {}),
          child: BarriosWidget(),
        );
      case WebSection.recordatorios:
        // Seguimientos programados desde Tamizajes manuales (`reminders`).
        // La libreta anterior (`Recordator`) ya no se muestra en web.
        return const SeguimientosWidget();
      case WebSection.perfil:
        return wrapWithModel(
          model: _model.adminProfileModel,
          updateCallback: () => safeSetState(() {}),
          child: AdminProfileWidget(),
        );
    }
  }
}
