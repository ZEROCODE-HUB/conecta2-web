import 'package:firebase_auth/firebase_auth.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/components/successpopup_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/backend/schema/shared/listas_fijas.dart';
import '../../../../../dashboard/web/usuarios/shared/user_form_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'editar_usuario_model.dart';
export 'editar_usuario_model.dart';

const List<String> kListaMunicipios = [
  'Cartagena',
  'Bucaramanga',
  'Montería',
  'Cúcuta',
  'Barrancabermeja',
];

const List<String> kListaGrados = [
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'
];

class EditarUsuarioWidget extends StatefulWidget {
  const EditarUsuarioWidget({
    super.key,
    required this.documentID,
    required this.userdoc,
  });

  final DocumentReference? documentID;
  final UsersRecord? userdoc;

  @override
  State<EditarUsuarioWidget> createState() => _EditarUsuarioWidgetState();
}

class _EditarUsuarioWidgetState extends State<EditarUsuarioWidget> {
  late EditarUsuarioModel _model;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _colegiosNombres = [];
  bool _isLoadingColegios = true;
  String? _unregisteredColegio;

  List<String> _barriosNombres = [];
  bool _isLoadingBarrios = true;

  Future<void> _loadBarrios() async {
    try {
      final barrios = await queryBarriosRecordOnce();
      final nombres = barrios
          .map((b) => b.nombre)
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
      nombres.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (mounted) {
        setState(() {
          _barriosNombres = nombres;
          _isLoadingBarrios = false;
          
          final existingBarrio = widget.userdoc?.barrio ?? '';
          if (_barriosNombres.contains(existingBarrio)) {
            _model.barrioDropDownController =
                FormFieldController<String>(existingBarrio);
          } else {
            _model.barrioDropDownController =
                FormFieldController<String>(null);
          }
        });
      }
    } catch (e) {
      print('Error cargando barrios: $e');
      if (mounted) {
        setState(() {
          _isLoadingBarrios = false;
        });
      }
    }
  }

  Future<void> _loadColegios() async {
    try {
      final colegios = await queryColegiosRecordOnce();
      final nombres = colegios
          .map((c) => c.nombre)
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();
      nombres.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      final existingColegio = widget.userdoc?.colegio ?? '';
      if (existingColegio.isNotEmpty && !nombres.contains(existingColegio)) {
        _unregisteredColegio = existingColegio;
      }

      if (mounted) {
        setState(() {
          _colegiosNombres = nombres;
          _isLoadingColegios = false;

          if (_colegiosNombres.contains(existingColegio)) {
            _model.colegioDropDownController =
                FormFieldController<String>(existingColegio);
          } else {
            _model.colegioDropDownController =
                FormFieldController<String>(null);
          }
        });
      }
    } catch (e) {
      print('Error cargando colegios: $e');
      if (mounted) {
        setState(() {
          _isLoadingColegios = false;
        });
      }
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditarUsuarioModel());
    _loadColegios();
    _loadBarrios();

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.userdoc != null) {
        safeSetState(() {
          _model.ddTipoValueController?.value = widget.userdoc!.rol;
          _model.ddTipoValue = widget.userdoc!.rol;
          _model.textFieldNombresTextController?.text =
              widget.userdoc!.displayName;
          _model.emailTextController?.text = widget.userdoc!.email;
          _model.textFieldphoneTextController?.text =
              widget.userdoc!.phoneNumber;
          _model.textFielddniTextController?.text = widget.userdoc!.identidad;
          _model.textFieldaddressTextController?.text = widget.userdoc!.address;
          _model.textFieldcolegioTextController?.text = widget.userdoc!.colegio;
          _model.textFieldepsTextController?.text = widget.userdoc!.eps;
          _model.textFieldgradoTextController?.text = widget.userdoc!.grado;
          _model.textFieldmunicipioTextController?.text =
              widget.userdoc!.municipio;
          _model.textFieldbarrioTextController?.text = widget.userdoc!.barrio;
          _model.textFieldedadTextController?.text = widget.userdoc!.edad;
          _model.dropDownGeneroValueController?.value = widget.userdoc!.genero;
          _model.dropDownGeneroValue = widget.userdoc!.genero;
          _model.textFieldfechaNacimientoTextController?.text =
              widget.userdoc!.fechaNacimiento != null
                  ? DateFormat('dd/MM/yyyy')
                      .format(widget.userdoc!.fechaNacimiento!)
                  : '';
          // El desplegable de profesional trabaja con el id del perfil.
          _model.dropDownProfesionalValueController?.value =
              widget.userdoc!.profesionales.ref?.id ?? '';
          _model.dropDownProfesionalValue =
              widget.userdoc!.profesionales.ref?.id ?? '';

          final existingEps = widget.userdoc?.eps ?? '';
          _model.epsDropDownController = FormFieldController<String>(
            kListaEPS.contains(existingEps) ? existingEps : null,
          );

          final existingMunicipio = widget.userdoc?.municipio ?? '';
          _model.municipioDropDownController = FormFieldController<String>(
            kListaMunicipios.contains(existingMunicipio) ? existingMunicipio : null,
          );

          final existingGrado = widget.userdoc?.grado ?? '';
          _model.gradoDropDownController = FormFieldController<String>(
            kListaGrados.contains(existingGrado) ? existingGrado : null,
          );
        });
      }
    });

    _model.textFieldNombresFocusNode ??= FocusNode();
    _model.emailFocusNode ??= FocusNode();
    _model.textFieldphoneFocusNode ??= FocusNode();
    _model.textFielddniFocusNode ??= FocusNode();
    _model.textFieldaddressFocusNode ??= FocusNode();
    _model.textFieldcolegioFocusNode ??= FocusNode();
    _model.textFieldepsFocusNode ??= FocusNode();
    _model.textFieldgradoFocusNode ??= FocusNode();
    _model.textFieldmunicipioFocusNode ??= FocusNode();
    _model.textFieldbarrioFocusNode ??= FocusNode();
    _model.textFieldedadFocusNode ??= FocusNode();
    _model.textFieldfechaNacimientoFocusNode ??= FocusNode();

    _model.textFieldfechaNacimientoTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return null;
      }
      final parts = val.split('/');
      if (parts.length != 3) {
        return 'Formato inválido (DD/MM/YYYY)';
      }
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) {
        return 'Formato inválido (DD/MM/YYYY)';
      }
      if (month < 1 || month > 12) {
        return 'Mes inválido (1-12)';
      }
      if (day < 1 || day > 31) {
        return 'Día inválido (1-31)';
      }
      final daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      if (day > daysInMonth[month - 1]) {
        return 'Día inválido para el mes';
      }
      if (month == 2 && day == 29) {
        final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        if (!isLeap) {
          return 'No es año bisiesto';
        }
      }
      if (year < 1900 || year > DateTime.now().year) {
        return 'Año inválido';
      }
      return null;
    };

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(40.0, 20.0, 40.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(context),
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 45.0, 0.0, 0.0),
                child: StreamBuilder<UsersRecord>(
                  stream: UsersRecord.getDocument(widget.documentID!),
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
                    final rowUsersRecord = snapshot.data!;
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebarCard(context, rowUsersRecord),
                        Expanded(
                            child: _buildFormCard(context, rowUsersRecord)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Header --------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            FFAppState().selectUser = '';
            safeSetState(() {});
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: safeAssetImage(
              'assets/images/Down.png',
              width: 26.0,
              height: 26.0,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
            child: Text(
              'Editar usuario',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 36.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                  child: AuthUserStreamWidget(
                    builder: (context) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 500),
                        imageUrl: valueOrDefault<String>(
                          currentUserPhoto,
                          kDefaultAvatarUrl,
                        ),
                        width: 30.0,
                        height: 30.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, size: 20),
                      ),
                    ),
                  ),
                ),
                AuthUserStreamWidget(
                  builder: (context) => Text(
                    currentUserDisplayName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------- Sidebar (avatar + name/rol + role-specific searchable dropdowns) --------
  Widget _buildSidebarCard(BuildContext context, UsersRecord rowUsersRecord) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.2,
      height: MediaQuery.sizeOf(context).height * 1.0,
      decoration: sharedCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarStack(context, rowUsersRecord),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 10.0),
                    child: Text(
                      rowUsersRecord.displayName,
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontStyle,
                            ),
                            fontSize: 28.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    rowUsersRecord.rol,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            if (rowUsersRecord.rol != 'Profesional')
              _buildSidebarRoleDropdowns(context, rowUsersRecord),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(BuildContext context, UsersRecord rowUsersRecord) {
    return Stack(
      alignment: const AlignmentDirectional(1.0, 1.0),
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
          child: Container(
            width: 106.0,
            height: 106.0,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  _model.uploadedFileUrl_uploadImage2 != ''
                      ? _model.uploadedFileUrl_uploadImage2
                      : valueOrDefault<String>(
                          rowUsersRecord.photoUrl,
                          kDefaultAvatarUrl,
                        ),
                ),
                onError: (exception, stackTrace) {},
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: _pickAndUploadAvatar,
          child: Container(
            width: 35.0,
            height: 35.0,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: safeAssetImage('assets/images/Group_273.png'),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarRoleDropdowns(
      BuildContext context, UsersRecord rowUsersRecord) {
    final isEditingAcudiente =
        _model.ddTipoValue == 'Acudiente' || _model.ddTipoValue == 'Padre';
    final otherRoleLabel = isEditingAcudiente ? 'Adolescente' : 'Acudiente';
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFieldLabel(
                  context,
                  isEditingAcudiente
                      ? 'Adolescentes vinculados'
                      : otherRoleLabel),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                child: isEditingAcudiente
                    ? _buildAdolescentesVinculadosReadonly(
                        context, rowUsersRecord)
                    : StreamBuilder<List<UsersRecord>>(
                        stream: queryUsersRecord(
                          queryBuilder: (usersRecord) => usersRecord
                              .where('rol', isEqualTo: otherRoleLabel),
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return _buildLoader(context);
                          }
                          final users = snapshot.data!;
                          final currentAcudienteName =
                              rowUsersRecord.acudiente.nombre;
                          final hintText = currentAcudienteName.isNotEmpty
                              ? currentAcudienteName
                              : 'Nombres y Apellidos *';
                          return buildSearchableDropDown(
                            context: context,
                            controller: _model
                                    .dropDownAcudienteoAdolescenteValueController ??=
                                FormFieldController<String>(
                              _model.dropDownAcudienteoAdolescenteValue ??=
                                  rowUsersRecord.acudiente.nombre,
                            ),
                            options: users.map((e) => e.displayName).toList(),
                            onChanged: (val) => safeSetState(() => _model
                                .dropDownAcudienteoAdolescenteValue = val),
                            hintText: hintText,
                            searchHintText: 'Busca un usuario',
                            width: double.infinity,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFieldLabel(context, 'Profesional'),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                child: StreamBuilder<List<UsersRecord>>(
                  stream: queryUsersRecord(
                    queryBuilder: (usersRecord) =>
                        usersRecord.where('rol', isEqualTo: 'Profesional'),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildLoader(context);
                    }
                    final users = [...snapshot.data!]..sort((a, b) => a
                        .displayName
                        .toLowerCase()
                        .compareTo(b.displayName.toLowerCase()));
                    final currentProfesionalName =
                        rowUsersRecord.profesionales.nombre;
                    final hintText = currentProfesionalName.isNotEmpty
                        ? currentProfesionalName
                        : 'Sin profesional';
                    return buildSearchableDropDown(
                      context: context,
                      controller: _model.dropDownProfesionalValueController ??=
                          FormFieldController<String>(
                        _model.dropDownProfesionalValue ??=
                            rowUsersRecord.profesionales.ref?.id ?? '',
                      ),
                      // Valor = id del perfil (los nombres pueden repetirse
                      // o cambiar); vacío = sin profesional.
                      options: ['', ...users.map((e) => e.reference.id)],
                      optionLabels: [
                        'Sin profesional',
                        ...users.map((e) => e.email.isEmpty
                            ? e.displayName
                            : '${e.displayName} (${e.email})'),
                      ],
                      onChanged: (val) => safeSetState(
                          () => _model.dropDownProfesionalValue = val),
                      hintText: hintText,
                      searchHintText: 'Buscar un profesional',
                      width: double.infinity,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdolescentesVinculadosReadonly(
      BuildContext context, UsersRecord acudiente) {
    final theme = FlutterFlowTheme.of(context);
    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (q) =>
            q.where('Acudiente.correo', isEqualTo: acudiente.email),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildLoader(context);
        final adolescentes = snapshot.data!;
        if (adolescentes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: theme.alternate),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Sin adolescentes vinculados. La relación se establece desde el perfil del adolescente.',
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: adolescentes
              .map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.alternate),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 18.0, color: theme.primary),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.displayName.isEmpty
                                    ? '(sin nombre)'
                                    : a.displayName,
                                style: theme.bodyMedium
                                    .override(fontWeight: FontWeight.w600),
                              ),
                              if (a.email.isNotEmpty)
                                Text(
                                  a.email,
                                  style: theme.bodySmall
                                      .override(color: theme.secondaryText),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildLoader(BuildContext context) => Center(
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

  Future<void> _pickAndUploadAvatar() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia == null ||
        !selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }
    safeSetState(() => _model.isDataUploading_uploadImage2 = true);
    var selectedUploadedFiles = <FFUploadedFile>[];
    var downloadUrls = <String>[];
    try {
      selectedUploadedFiles = selectedMedia
          .map((m) => FFUploadedFile(
                name: m.storagePath.split('/').last,
                bytes: m.bytes,
                height: m.dimensions?.height,
                width: m.dimensions?.width,
                blurHash: m.blurHash,
                originalFilename: m.originalFilename,
              ))
          .toList();
      downloadUrls = (await Future.wait(
        selectedMedia
            .map((m) async => await uploadData(m.storagePath, m.bytes)),
      ))
          .where((u) => u != null)
          .map((u) => u!)
          .toList();
    } finally {
      _model.isDataUploading_uploadImage2 = false;
    }
    if (selectedUploadedFiles.length == selectedMedia.length &&
        downloadUrls.length == selectedMedia.length) {
      safeSetState(() {
        _model.uploadedLocalFile_uploadImage2 = selectedUploadedFiles.first;
        _model.uploadedFileUrl_uploadImage2 = downloadUrls.first;
      });
    } else {
      safeSetState(() {});
    }
  }

  // -------- Main form card --------
  Widget _buildFormCard(BuildContext context, UsersRecord rowUsersRecord) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 1.0,
        decoration: sharedCardDecoration(),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: buildSectionTitle(context, 'Datos personales'),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child:
                              _buildTipoAndNombreRow(context, rowUsersRecord),
                        ),
                        _buildEmailPhoneRow(context, rowUsersRecord),
                        _buildDniAddressRow(context, rowUsersRecord),
                        _buildEdadGeneroRow(context, rowUsersRecord),
                        if (_model.ddTipoValue == 'Adolescente') ...[
                          _buildNacimientoRow(context, rowUsersRecord),
                          _buildColegioEpsRow(context, rowUsersRecord),
                          _buildMunicipioBarrioRow(context, rowUsersRecord),
                          _buildGradoRow(context, rowUsersRecord),
                        ],
                        _buildResetPasswordButton(context),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActionButtons(context, rowUsersRecord),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoAndNombreRow(
      BuildContext context, UsersRecord rowUsersRecord) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFieldLabel(context, 'Tipo de usuario'),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: buildStyledDropDown(
                  context: context,
                  controller: _model.ddTipoValueController ??=
                      FormFieldController<String>(
                          _model.ddTipoValue ??= rowUsersRecord.rol),
                  options: kUserRoles,
                  onChanged: (val) =>
                      safeSetState(() => _model.ddTipoValue = val),
                  width: double.infinity,
                  height: 47.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LabeledTextField(
            label: 'Nombres y Apellidos',
            controller: _model.textFieldNombresTextController ??=
                TextEditingController(text: rowUsersRecord.displayName),
            focusNode: _model.textFieldNombresFocusNode,
            validator: _model.textFieldNombresTextControllerValidator
                .asValidator(context),
          ),
        ),
      ].divide(const SizedBox(width: 25.0)),
    );
  }

  Widget _buildEmailPhoneRow(BuildContext context, UsersRecord rowUsersRecord) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Correo electrónico *',
              controller: _model.emailTextController ??=
                  TextEditingController(text: rowUsersRecord.email),
              focusNode: _model.emailFocusNode,
              autofocus: true,
              useErrorColor: false,
              fontWeight: FontWeight.w500,
              validator:
                  _model.emailTextControllerValidator.asValidator(context),
            ),
          ),
          Expanded(
            child: LabeledTextField(
              label: 'Celular',
              controller: _model.textFieldphoneTextController ??=
                  TextEditingController(text: rowUsersRecord.phoneNumber),
              focusNode: _model.textFieldphoneFocusNode,
              autofocus: true,
              fontWeight: FontWeight.w500,
              validator: _model.textFieldphoneTextControllerValidator
                  .asValidator(context),
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildDniAddressRow(BuildContext context, UsersRecord rowUsersRecord) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Documento de identidad *',
              controller: _model.textFielddniTextController ??=
                  TextEditingController(text: rowUsersRecord.identidad),
              focusNode: _model.textFielddniFocusNode,
              useErrorColor: false,
              validator: _model.textFielddniTextControllerValidator
                  .asValidator(context),
            ),
          ),
          Expanded(
            child: LabeledTextField(
              label: 'Dirección *',
              controller: _model.textFieldaddressTextController ??=
                  TextEditingController(text: rowUsersRecord.address),
              focusNode: _model.textFieldaddressFocusNode,
              autofocus: true,
              validator: _model.textFieldaddressTextControllerValidator
                  .asValidator(context),
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildColegioEpsRow(BuildContext context, UsersRecord rowUsersRecord) {
    _model.textFieldcolegioTextController ??=
        TextEditingController(text: rowUsersRecord.colegio);
    _model.textFieldepsTextController ??=
        TextEditingController(text: rowUsersRecord.eps);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Colegio *'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: _isLoadingColegios
                      ? Container(
                          height: 47.0,
                          decoration: BoxDecoration(
                            color: kFormFieldFillColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        )
                      : buildSearchableDropDown(
                          context: context,
                          controller: _model.colegioDropDownController ??=
                              FormFieldController<String>(
                            _colegiosNombres.contains(
                                    _model.textFieldcolegioTextController?.text)
                                ? _model.textFieldcolegioTextController?.text
                                : null,
                          ),
                          options: _colegiosNombres,
                          onChanged: (val) {
                            safeSetState(() {
                              _model.textFieldcolegioTextController?.text =
                                  val ?? '';
                              _unregisteredColegio = null;
                            });
                          },
                          hintText: _colegiosNombres.contains(
                                  _model.textFieldcolegioTextController?.text)
                              ? _model.textFieldcolegioTextController?.text ??
                                  'Seleccionar colegio'
                              : 'Seleccionar colegio',
                          searchHintText: 'Buscar colegio',
                          width: double.infinity,
                          height: 47.0,
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'EPS'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: buildSearchableDropDown(
                    context: context,
                    controller: _model.epsDropDownController ??=
                        FormFieldController<String>(
                      kListaEPS.contains(_model.textFieldepsTextController?.text)
                          ? _model.textFieldepsTextController?.text
                          : null,
                    ),
                    options: kListaEPS,
                    onChanged: (val) {
                      safeSetState(() {
                        _model.textFieldepsTextController?.text = val ?? '';
                      });
                    },
                    hintText: 'Seleccionar EPS',
                    searchHintText: 'Buscar EPS',
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildMunicipioBarrioRow(
      BuildContext context, UsersRecord rowUsersRecord) {
    _model.textFieldmunicipioTextController ??=
        TextEditingController(text: rowUsersRecord.municipio);
    _model.textFieldbarrioTextController ??=
        TextEditingController(text: rowUsersRecord.barrio);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Municipio'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: buildSearchableDropDown(
                    context: context,
                    controller: _model.municipioDropDownController ??=
                        FormFieldController<String>(
                      kListaMunicipios.contains(_model.textFieldmunicipioTextController?.text)
                          ? _model.textFieldmunicipioTextController?.text
                          : null,
                    ),
                    options: kListaMunicipios,
                    onChanged: (val) {
                      safeSetState(() {
                        _model.textFieldmunicipioTextController?.text = val ?? '';
                      });
                    },
                    hintText: 'Seleccionar municipio',
                    searchHintText: 'Buscar municipio',
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Barrio'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: _isLoadingBarrios
                      ? Container(
                          height: 47.0,
                          decoration: BoxDecoration(
                            color: kFormFieldFillColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: const SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                        )
                      : buildSearchableDropDown(
                          context: context,
                          controller: _model.barrioDropDownController ??=
                              FormFieldController<String>(
                            _barriosNombres.contains(_model.textFieldbarrioTextController?.text)
                                ? _model.textFieldbarrioTextController?.text
                                : null,
                          ),
                          options: _barriosNombres,
                          onChanged: (val) {
                            safeSetState(() {
                              _model.textFieldbarrioTextController?.text = val ?? '';
                            });
                          },
                          hintText: 'Seleccionar barrio',
                          searchHintText: 'Buscar barrio',
                          width: double.infinity,
                          height: 47.0,
                        ),
                ),
              ],
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildGradoRow(BuildContext context, UsersRecord rowUsersRecord) {
    _model.textFieldgradoTextController ??=
        TextEditingController(text: rowUsersRecord.grado);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Grado Escolar'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: buildSearchableDropDown(
                    context: context,
                    controller: _model.gradoDropDownController ??=
                        FormFieldController<String>(
                      kListaGrados.contains(_model.textFieldgradoTextController?.text)
                          ? _model.textFieldgradoTextController?.text
                          : null,
                    ),
                    options: kListaGrados,
                    onChanged: (val) {
                      safeSetState(() {
                        _model.textFieldgradoTextController?.text = val ?? '';
                      });
                    },
                    hintText: 'Seleccionar grado',
                    searchHintText: 'Buscar grado',
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: const SizedBox()),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildEdadGeneroRow(BuildContext context, UsersRecord rowUsersRecord) {
    final isAdolescente = _model.ddTipoValue == 'Adolescente';
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (isAdolescente)
            Expanded(
              child: LabeledTextField(
                label: 'Edad',
                controller: _model.textFieldedadTextController ??=
                    TextEditingController(text: rowUsersRecord.edad),
                focusNode: _model.textFieldedadFocusNode,
                useErrorColor: false,
                validator: _model.textFieldedadTextControllerValidator
                    .asValidator(context),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel(context, 'Género'),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: buildStyledDropDown(
                    context: context,
                    controller: _model.dropDownGeneroValueController ??=
                        FormFieldController<String>(_model
                            .dropDownGeneroValue ??= rowUsersRecord.genero),
                    options: ['Masculino', 'Femenino', 'Otro'],
                    onChanged: (val) =>
                        safeSetState(() => _model.dropDownGeneroValue = val),
                    width: double.infinity,
                    height: 47.0,
                  ),
                ),
              ],
            ),
          ),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildNacimientoRow(BuildContext context, UsersRecord rowUsersRecord) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: LabeledTextField(
              label: 'Fecha de nacimiento',
              hintText: '(DD/MM/YYYY)',
              controller: _model.textFieldfechaNacimientoTextController ??=
                  TextEditingController(
                      text: rowUsersRecord.fechaNacimiento != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(rowUsersRecord.fechaNacimiento!)
                          : ''),
              focusNode: _model.textFieldfechaNacimientoFocusNode,
              useErrorColor: false,
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                DateInputFormatter(),
              ],
              validator: _model.textFieldfechaNacimientoTextControllerValidator
                  .asValidator(context),
            ),
          ),
          Expanded(child: const SizedBox()),
        ].divide(const SizedBox(width: 25.0)),
      ),
    );
  }

  Widget _buildResetPasswordButton(BuildContext context) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
        child: buildPrimaryButton(
          context: context,
          text: 'Restablecer contraseña',
          width: 245.0,
          height: 45.0,
          borderRadius: 40.0,
          onPressed: () => _restablecerContrasena(context),
        ),
      ),
    );
  }

  /// Envía el correo de Firebase con el enlace para restablecer la
  /// contraseña, al correo guardado del usuario (no al campo editable),
  /// previa confirmación.
  Future<void> _restablecerContrasena(BuildContext context) async {
    final email = (widget.userdoc?.email ?? '').trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Este usuario no tiene correo registrado.')),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded,
                color: Color(0xFF265294), size: 24.0),
            const SizedBox(width: 8.0),
            Text(
              'Restablecer contraseña',
              style: GoogleFonts.inter(
                  fontSize: 17.0, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text.rich(
          TextSpan(
            style: GoogleFonts.inter(fontSize: 14.0),
            children: [
              const TextSpan(
                  text: 'Se enviará un enlace para restablecer la contraseña '
                      'al correo del usuario:\n\n'),
              TextSpan(
                text: email,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                  text: '\n\nEl usuario podrá crear una nueva contraseña '
                      'desde ese enlace.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: const Color(0xFF959595)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF265294),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Enviar enlace',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enlace enviado a $email')),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar el enlace: ${e.message ?? e.code}'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, UsersRecord rowUsersRecord) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildSecondaryButton(
            context: context,
            text: 'Cancelar',
            width: 245.0,
            height: 45.0,
            borderRadius: 40.0,
            onPressed: () async {
              FFAppState().selectUser = '';
              safeSetState(() {});
            },
          ),
          Builder(
            builder: (context) => buildPrimaryButton(
              context: context,
              text: 'Editar usuario',
              width: 245.0,
              height: 45.0,
              borderRadius: 40.0,
              onPressed: () => _onEditPressed(rowUsersRecord),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onEditPressed(UsersRecord rowUsersRecord) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    final email = _model.emailTextController?.text.trim() ?? '';
    final nombre = _model.textFieldNombresTextController?.text.trim() ?? '';
    final dni = _model.textFielddniTextController?.text.trim() ?? '';
    final address = _model.textFieldaddressTextController?.text.trim() ?? '';
    final colegio = _model.textFieldcolegioTextController?.text.trim() ?? '';
    final rol = _model.ddTipoValue;

    if (email.isEmpty || nombre.isEmpty || dni.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor complete los datos obligatorios.',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (rol == 'Adolescente' &&
        (colegio.isEmpty || _unregisteredColegio != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecciona una institución de la lista.',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final isEditingAcudiente =
        _model.ddTipoValue == 'Acudiente' || _model.ddTipoValue == 'Padre';
    final isAdolescente = _model.ddTipoValue == 'Adolescente';

    if (!isEditingAcudiente &&
        _model.dropDownAcudienteoAdolescenteValue != null &&
        _model.dropDownAcudienteoAdolescenteValue!.isNotEmpty) {
      _model.getRefAcud = await queryUsersRecordOnce(
        queryBuilder: (usersRecord) => usersRecord.where(
          'display_name',
          isEqualTo: _model.dropDownAcudienteoAdolescenteValue,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
    }

    // Profesional asignado (el desplegable guarda el id del perfil):
    // - mismo id que antes → no se toca el campo;
    // - vacío → se quita la asignación;
    // - otro id → se asigna ese perfil con su nombre actual.
    final profIdAnterior = rowUsersRecord.profesionales.ref?.id ?? '';
    final profIdNuevo = _model.dropDownProfesionalValue ?? profIdAnterior;
    ProfesionalesStruct? profesionalesNuevo;
    if (profIdNuevo != profIdAnterior) {
      if (profIdNuevo.isEmpty) {
        profesionalesNuevo = createProfesionalesStruct(delete: true);
      } else {
        _model.getRefProf = await UsersRecord.getDocumentOnce(
            UsersRecord.collection.doc(profIdNuevo));
        profesionalesNuevo = createProfesionalesStruct(
          nombre: _model.getRefProf!.displayName,
          ref: _model.getRefProf!.reference,
        );
      }
    }

    await widget.documentID!.update(createUsersRecordData(
      email: _model.emailTextController.text,
      displayName: _model.textFieldNombresTextController.text,
      photoUrl: _model.uploadedFileUrl_uploadImage2 != ''
          ? _model.uploadedFileUrl_uploadImage2
          : rowUsersRecord.photoUrl,
      uid: _model.textFielddniTextController.text,
      phoneNumber: _model.textFieldphoneTextController.text,
      acudiente: (isEditingAcudiente ||
              _model.dropDownAcudienteoAdolescenteValue == null ||
              _model.dropDownAcudienteoAdolescenteValue!.isEmpty)
          ? null
          : updateAcudienteStruct(
              AcudienteStruct(
                nombre: _model.dropDownAcudienteoAdolescenteValue,
                ref: _model.getRefAcud?.reference,
                correo: _model.getRefAcud?.email,
              ),
              clearUnsetFields: false,
            ),
      rol: _model.ddTipoValue,
      profesionales: profesionalesNuevo,
      address: _model.textFieldaddressTextController.text,
      identidad: _model.textFielddniTextController.text,
      edad: isAdolescente ? _model.textFieldedadTextController.text : null,
      genero: _model.dropDownGeneroValue,
      fechaNacimiento: isAdolescente ? () {
        try {
          return DateFormat('dd/MM/yyyy').parseStrict(_model.textFieldfechaNacimientoTextController?.text ?? '');
        } catch (_) {
          return null;
        }
      }() : null,
      colegio: isAdolescente ? (_model.textFieldcolegioTextController?.text ?? '') : null,
      eps: isAdolescente ? (_model.textFieldepsTextController?.text ?? '') : null,
      grado: isAdolescente ? (_model.textFieldgradoTextController?.text ?? '') : null,
      municipio: isAdolescente ? (_model.textFieldmunicipioTextController?.text ?? '') : null,
      barrio: isAdolescente ? (_model.textFieldbarrioTextController?.text ?? '') : null,
    ));
    FFAppState().selectUser = '';
    safeSetState(() {});
    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0.0, 0.0)
            .resolve(Directionality.of(context)),
        child: WebViewAware(child: SuccesspopupWidget()),
      ),
    );
    safeSetState(() {});
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) return oldValue;

    // Auto-pad day if first digit > 3
    if (text.length == 1) {
      if (int.parse(text) > 3) {
        text = '0$text';
      }
    }
    
    // Auto-pad month if first digit of month > 1
    if (text.length == 3) {
      if (int.parse(text[2]) > 1) {
        text = '${text.substring(0, 2)}0${text[2]}';
      }
    }

    if (text.length >= 2) {
      final day = int.tryParse(text.substring(0, 2));
      if (day != null && (day < 1 || day > 31)) {
        return oldValue;
      }
    }
    if (text.length >= 4) {
      final month = int.tryParse(text.substring(2, 4));
      if (month != null && (month < 1 || month > 12)) {
        return oldValue;
      }
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
