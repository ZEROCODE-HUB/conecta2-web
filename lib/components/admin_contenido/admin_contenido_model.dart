import '/backend/backend.dart';
import '/dashboard/web/contenido/model/crearcontenido/crearcontenido_widget.dart';
import '/dashboard/web/contenido/model/editar_contenido/editar_contenido_widget.dart';
import '/dashboard/web/contenido/model/vistaprevia_contenido/vistaprevia_contenido_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'admin_contenido_widget.dart' show AdminContenido2Widget;
import 'package:flutter/material.dart';

class AdminContenido2Model extends FlutterFlowModel<AdminContenido2Widget> {
  ///  Local state fields for this component.
  DocumentReference? documentID;

  ///  State fields for stateful widgets in this component.
  // Model for Crearcontenido component.
  late CrearcontenidoModel crearcontenidoModel;
  // Model for VistapreviaContenido component.
  late VistapreviaContenidoModel vistapreviaContenidoModel;
  // Model for EditarContenido component.
  late EditarContenidoModel editarContenidoModel;
  // Stores action output result for [Backend Call - Create Document] action.
  ContenidoRecord? contenidoID;
  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;
  List<ContenidoRecord> simpleSearchResults = [];
  bool isShowFullList = true;
  // State field(s) for "Publicado/Borrador" DropDown.
  bool? dropDownValue1;
  // Opciones TODOS / PUBLICADO / BORRADOR; se traduce a dropDownValue1.
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for "Dirigido para" DropDown.
  List<String>? dropDownValue2;
  FormFieldController<List<String>>? dropDownValueController2;

  @override
  void initState(BuildContext context) {
    crearcontenidoModel = createModel(context, () => CrearcontenidoModel());
    vistapreviaContenidoModel =
        createModel(context, () => VistapreviaContenidoModel());
    editarContenidoModel = createModel(context, () => EditarContenidoModel());
  }

  @override
  void dispose() {
    crearcontenidoModel.dispose();
    vistapreviaContenidoModel.dispose();
    editarContenidoModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
