import '/backend/backend.dart';
import '/components/footer_professionals/footer_professionals_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'pacientes_widget.dart' show PacientesWidget;
import 'package:flutter/material.dart';

class PacientesModel extends FlutterFlowModel<PacientesWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  List<UsersRecord> simpleSearchResults = [];
  // Texto de la última búsqueda enviada ('' = sin búsqueda: lista completa).
  String busquedaHecha = '';
  // Model for footerProfessionals component.
  late FooterProfessionalsModel footerProfessionalsModel;
  // Model for ProfesionalHeader component.
  late ProfesionalHeaderModel profesionalHeaderModel;

  @override
  void initState(BuildContext context) {
    footerProfessionalsModel =
        createModel(context, () => FooterProfessionalsModel());
    profesionalHeaderModel =
        createModel(context, () => ProfesionalHeaderModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    footerProfessionalsModel.dispose();
    profesionalHeaderModel.dispose();
  }
}
