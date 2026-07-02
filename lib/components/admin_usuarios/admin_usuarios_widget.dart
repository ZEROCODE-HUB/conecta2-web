import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/dashboard/web/usuarios/model/crear_usuario/crear_usuario_widget.dart';
import '/dashboard/web/usuarios/model/editar_usuario/editar_usuario_widget.dart';
import '/dashboard/web/usuarios/model/perfil_acudiente/perfil_acudiente_widget.dart';
import '/dashboard/web/usuarios/model/perfil_adolescente/perfil_adolescente_widget.dart';
import '/dashboard/web/usuarios/model/perfil_profesional/perfil_profesional_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'admin_usuarios_model.dart';
import 'widgets/usuarios_filters.dart';
import 'widgets/usuarios_list.dart';

export 'admin_usuarios_model.dart';

/// Admin "Usuarios" component.
///
/// This widget was previously a ~3860 line FlutterFlow-generated widget
/// that rendered three duplicated code branches (full list, role-filtered
/// and search-result) inside a Column constrained to the screen height.
/// The fixed-height wrapper caused a ~4988px bottom overflow.
///
/// The refactor:
///  - Consolidates the three branches into a single filtered list.
///  - Moves the list inside a [SingleChildScrollView] so it can grow
///    arbitrarily tall without overflowing.
///  - Extracts filters, list, row and the action menu into dedicated files.
///  - Replaces the three edit/delete/print icons with a single 3-dot
///    [PopupMenuButton] (see `UsuarioActionsMenu`).
class AdminUsuariossWidget extends StatefulWidget {
  const AdminUsuariossWidget({super.key});

  @override
  State<AdminUsuariossWidget> createState() => _AdminUsuariossWidgetState();
}

class _AdminUsuariossWidgetState extends State<AdminUsuariossWidget> {
  late AdminUsuariossModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminUsuariossModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.isShowFullList = true;
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _openPerfil(UsersRecord user) {
    _model.document = user.reference;
    _model.usuariodoc = user;
    safeSetState(() {});
    switch (user.rol) {
      case 'Acudiente':
        FFAppState().selectUser = 'PerfilAcudiente';
        break;
      case 'Adolescente':
        FFAppState().selectUser = 'PerfilAdolescente';
        break;
      case 'Profesional':
        FFAppState().selectUser = 'PerfilProfesional';
        break;
      case 'Administrador':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No puede ver el perfil de un administrador',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryBackground,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: const Color(0xFF265294),
          ),
        );
        return;
    }
    FFAppState().encuesta = '';
    FFAppState().showEncuesta = false;
    safeSetState(() {});
  }

  void _openEditar(UsersRecord user) {
    _model.document = user.reference;
    _model.usuariodoc = user;
    FFAppState().selectUser = 'Editar';
    safeSetState(() {});
  }

  /// Applies the role dropdown + the search text to the full
  /// Firestore-streamed user list.
  List<UsersRecord> _filter(List<UsersRecord> all, String currentUserRol) {
    Iterable<UsersRecord> result = all;

    if (currentUserRol == 'Profesional') {
      result = result.where((u) => u.profesionales.ref == currentUserReference && u.rol == 'Adolescente');
    }

    final role = _model.dropDownValue;
    if (role != null && role.isNotEmpty) {
      result = result.where((u) => u.rol == role);
    }

    if (!_model.isShowFullList &&
        _model.simpleSearchResults.isNotEmpty) {
      final allowedIds =
          _model.simpleSearchResults.map((u) => u.reference.id).toSet();
      result = result.where((u) => allowedIds.contains(u.reference.id));
    } else if (!_model.isShowFullList &&
        _model.simpleSearchResults.isEmpty) {
      // Active search that found nothing.
      result = const [];
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Stack(
      children: [
        Builder(
          builder: (context) {
            final selected = FFAppState().selectUser;
            if (selected == 'CrearUsuario') {
              return wrapWithModel(
                model: _model.crearUsuarioModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: const CrearUsuarioWidget(),
              );
            } else if (selected == 'PerfilAdolescente') {
              if (_model.document == null) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  FFAppState().selectUser = '';
                  safeSetState(() {});
                });
                return const SizedBox();
              }
              return wrapWithModel(
                model: _model.perfilAdolescenteModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: PerfilAdolescenteWidget(
                  documentID: _model.document!,
                ),
              );
            } else if (selected == 'PerfilAcudiente') {
              if (_model.document == null) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  FFAppState().selectUser = '';
                  safeSetState(() {});
                });
                return const SizedBox();
              }
              return wrapWithModel(
                model: _model.perfilAcudienteModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: PerfilAcudienteWidget(
                  documentID: _model.document!,
                ),
              );
            } else if (selected == 'PerfilProfesional') {
              if (_model.document == null) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  FFAppState().selectUser = '';
                  safeSetState(() {});
                });
                return const SizedBox();
              }
              return wrapWithModel(
                model: _model.perfilProfesionalModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: PerfilProfesionalWidget(
                  documentID: _model.document!,
                ),
              );
            } else if (selected == 'Editar') {
              if (_model.document == null || _model.usuariodoc == null) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  FFAppState().selectUser = '';
                  safeSetState(() {});
                });
                return const SizedBox();
              }
              return wrapWithModel(
                model: _model.editarUsuarioModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: EditarUsuarioWidget(
                  documentID: _model.document!,
                  userdoc: _model.usuariodoc!,
                ),
              );
            }
            return _buildList(context);
          },
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (usersRecord) =>
            usersRecord.orderBy('created_time', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }

        final allUsers = snapshot.data!;
        final currentUserRol = valueOrDefault(currentUserDocument?.rol, '');
        final filtered = _filter(allUsers, currentUserRol);

        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 50.0, 0.0),
            // SingleChildScrollView hosts a Column that now grows to fit its
            // children instead of being trapped in a fixed-height SizedBox.
            // This is the fix for the 4988px bottom overflow.
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UsuariosTitleBar(
                    onCrearNuevo: () {
                      FFAppState().selectUser = 'CrearUsuario';
                      safeSetState(() {});
                    },
                  ),
                  UsuariosFilters(
                    currentUserRol: currentUserRol,
                    textController: _model.textController,
                    textFieldFocusNode: _model.textFieldFocusNode,
                    textControllerValidator: _model.textControllerValidator,
                    dropDownValue: _model.dropDownValue,
                    dropDownValueController:
                        _model.dropDownValueController ??=
                            FormFieldController<String>(null),
                    isShowFullList: _model.isShowFullList,
                    onSearchChanged: (results) {
                      _model.simpleSearchResults = results;
                      _model.isShowFullList = false;
                      safeSetState(() {});
                    },
                    onClearSearch: () {
                      _model.isShowFullList = true;
                      _model.textController?.clear();
                      _model.simpleSearchResults = [];
                      safeSetState(() {});
                    },
                    onDropDownChanged: (val) =>
                        safeSetState(() => _model.dropDownValue = val),
                  ),
                  UsuariosList(
                    users: filtered,
                    currentUserRol: currentUserRol,
                    onVerPerfil: _openPerfil,
                    onEditar: _openEditar,
                    emptyMessage: filtered.isEmpty
                        ? 'No se encontraron usuarios.'
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
