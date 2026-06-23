import '/backend/backend.dart';
import '/dashboard/web/encuestas/crearencuesta/crearencuesta_widget.dart';
import '/dashboard/web/encuestas/model/editarencuesta2/editarencuesta2_widget.dart';
import '/dashboard/web/encuestas/resultados/resultados_widget.dart';
import '/dashboard/web/encuestas/model/vista_previa_copy/vista_previa_copy_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'admin_encuestas_widget.dart' show AdminEncuestasWidget;
import 'package:flutter/material.dart';

class AdminEncuestasModel extends FlutterFlowModel<AdminEncuestasWidget> {
  /// Local state fields for this component.

  DocumentReference? documentID;

  EncuestasRecord? doc;

  /// State fields for stateful widgets in this component.

  // Model for Crearencuesta component.
  late CrearencuestaModel crearencuestaModel;
  // Model for Resultados component.
  late ResultadosModel resultadosModel;
  // Model for VistaPreviaCopy component.
  late VistaPreviaCopyModel vistaPreviaCopyModel;
  // Model for Editarencuesta2 component.
  late Editarencuesta2Model editarencuesta2Model;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  EncuestasRecord? encuestaID;
  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;
  List<EncuestasRecord> simpleSearchResults = [];
  bool isShowFullList = true;
  // State field(s) for DropDown widget (publicado/borrador).
  bool? dropDownValue1;
  FormFieldController<bool>? dropDownValueController1;
  // State field(s) for DropDown widget (dirigido para).
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  RespuestasRecord? check1;
  RespuestasRecord? check2;
  RespuestasRecord? check3;
  RespuestasRecord? check;

  @override
  void initState(BuildContext context) {
    crearencuestaModel = createModel(context, () => CrearencuestaModel());
    resultadosModel = createModel(context, () => ResultadosModel());
    vistaPreviaCopyModel = createModel(context, () => VistaPreviaCopyModel());
    editarencuesta2Model = createModel(context, () => Editarencuesta2Model());
  }

  @override
  void dispose() {
    crearencuestaModel.dispose();
    resultadosModel.dispose();
    vistaPreviaCopyModel.dispose();
    editarencuesta2Model.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
