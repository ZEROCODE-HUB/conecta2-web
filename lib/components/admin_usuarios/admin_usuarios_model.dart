import '/backend/backend.dart';
import '/dashboard/web/usuarios/model/crear_usuario/crear_usuario_widget.dart';
import '/dashboard/web/usuarios/model/editar_usuario/editar_usuario_widget.dart';
import '/dashboard/web/usuarios/model/perfil_acudiente/perfil_acudiente_widget.dart';
import '/dashboard/web/usuarios/model/perfil_adolescente/perfil_adolescente_widget.dart';
import '/dashboard/web/usuarios/model/perfil_profesional/perfil_profesional_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'admin_usuarios_widget.dart' show AdminUsuariossWidget;
import 'package:flutter/material.dart';

class AdminUsuariossModel extends FlutterFlowModel<AdminUsuariossWidget> {
  ///  Local state fields for this component.

  DocumentReference? document;

  UsersRecord? usuariodoc;

  ///  State fields for stateful widgets in this component.

  // Model for CrearUsuario component.
  late CrearUsuarioModel crearUsuarioModel;
  // Model for PerfilAdolescente component.
  late PerfilAdolescenteModel perfilAdolescenteModel;
  // Model for PerfilAcudiente component.
  late PerfilAcudienteModel perfilAcudienteModel;
  // Model for PerfilProfesional component.
  late PerfilProfesionalModel perfilProfesionalModel;
  // Model for EditarUsuario component.
  late EditarUsuarioModel editarUsuarioModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  List<UsersRecord> simpleSearchResults = [];
  bool isShowFullList = true;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {
    crearUsuarioModel = createModel(context, () => CrearUsuarioModel());
    perfilAdolescenteModel =
        createModel(context, () => PerfilAdolescenteModel());
    perfilAcudienteModel = createModel(context, () => PerfilAcudienteModel());
    perfilProfesionalModel =
        createModel(context, () => PerfilProfesionalModel());
    editarUsuarioModel = createModel(context, () => EditarUsuarioModel());
  }

  @override
  void dispose() {
    crearUsuarioModel.dispose();
    perfilAdolescenteModel.dispose();
    perfilAcudienteModel.dispose();
    perfilProfesionalModel.dispose();
    editarUsuarioModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
