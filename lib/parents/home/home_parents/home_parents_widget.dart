import '/auth/firebase_auth/auth_util.dart';
import '/user/registration/sesion_app.dart';
import '/backend/backend.dart';
import '/components/footer_parents/footer_parents_widget.dart';
import '/components/list_card/list_card_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_parents_model.dart';
export 'home_parents_model.dart';

part 'home_parents_content.dart';
part 'home_parents_content2.dart';

class HomeParentsWidget extends StatefulWidget {
  const HomeParentsWidget({super.key});

  static String routeName = 'homeParents';
  static String routePath = '/homeParents';

  @override
  State<HomeParentsWidget> createState() => _HomeParentsWidgetState();
}

class _HomeParentsWidgetState extends State<HomeParentsWidget> {
  late HomeParentsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeParentsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                color: Color(0x7E1F2129),
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                buildMainContent(context),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.footerParentsModel,
                    updateCallback: () => safeSetState(() {}),
                    child: FooterParentsWidget(
                      active: 1,
                    ),
                  ),
                ),
                wrapWithModel(
                  model: _model.profesionalHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: ProfesionalHeaderWidget(
                    name: 'Bienvenido',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
