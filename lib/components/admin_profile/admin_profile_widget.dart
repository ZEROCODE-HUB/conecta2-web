import '/auth/firebase_auth/auth_util.dart';
import '/user/registration/sesion_app.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_profile_model.dart';
import 'widgets/profile_actions.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_form.dart';

export 'admin_profile_model.dart';

/// Admin profile / settings screen.
///
/// Split responsibilities:
///   * [ProfileAvatarPanel]  - photo column + photo picker with errorBuilder.
///   * [ProfileForm]         - six input fields laid out in 3 × 2 rows.
///   * [ProfileResetPasswordButton] / [ProfileSaveButton] - bottom actions.
class AdminProfileWidget extends StatefulWidget {
  const AdminProfileWidget({super.key});

  @override
  State<AdminProfileWidget> createState() => _AdminProfileWidgetState();
}

class _AdminProfileWidgetState extends State<AdminProfileWidget> {
  late AdminProfileModel _model;

  static const _fallbackPhoto =
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png';

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminProfileModel());

    _model.textController1 ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.rol, ''));
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??=
        TextEditingController(text: currentUserDisplayName);
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.emailTextController ??=
        TextEditingController(text: correoDeAcceso);
    _model.emailFocusNode ??= FocusNode();

    _model.textController3 ??= TextEditingController(text: currentPhoneNumber);
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.identidad, ''));
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController(
        text: valueOrDefault(currentUserDocument?.address, ''));
    _model.textFieldFocusNode5 ??= FocusNode();

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
        padding:
            const EdgeInsetsDirectional.fromSTEB(40.0, 20.0, 40.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 45.0),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            'Ajustes de perfil',
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  fontSize: 36.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 10.0, 0.0),
                  child: AuthUserStreamWidget(
                    builder: (context) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 500),
                        imageUrl: valueOrDefault<String>(
                          currentUserPhoto,
                          _fallbackPhoto,
                        ),
                        width: 30.0,
                        height: 30.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 30.0,
                          height: 30.0,
                          color: const Color(0xFFE0E0E0),
                          child: const Icon(Icons.person,
                              size: 18.0, color: Color(0xFF265294)),
                        ),
                      ),
                    ),
                  ),
                ),
                AuthUserStreamWidget(
                  builder: (context) => Text(
                    currentUserDisplayName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
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

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatarPanel(
            uploadedFileUrl: _model.uploadedFileUrl_uploadData8ag,
            onUploadStart: () => safeSetState(
                () => _model.isDataUploading_uploadData8ag = true),
            onUploadEnd: () =>
                _model.isDataUploading_uploadData8ag = false,
            onFileUploaded: (file, url) => safeSetState(() {
              _model.uploadedLocalFile_uploadData8ag = file;
              _model.uploadedFileUrl_uploadData8ag = url;
            }),
          ),
          const SizedBox(width: 30.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 50.0,
                    color: Color(0x26000000),
                    offset: Offset(20.0, 20.0),
                  )
                ],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileForm(
                    rolController: _model.textController1!,
                    rolFocusNode: _model.textFieldFocusNode1!,
                    rolValidator: _model.textController1Validator,
                    nameController: _model.textController2!,
                    nameFocusNode: _model.textFieldFocusNode2!,
                    nameValidator: _model.textController2Validator,
                    emailController: _model.emailTextController!,
                    emailFocusNode: _model.emailFocusNode!,
                    emailValidator: _model.emailTextControllerValidator,
                    phoneController: _model.textController3!,
                    phoneFocusNode: _model.textFieldFocusNode3!,
                    phoneValidator: _model.textController3Validator,
                    idController: _model.textController4!,
                    idFocusNode: _model.textFieldFocusNode4!,
                    idValidator: _model.textController4Validator,
                    addressController: _model.textController5!,
                    addressFocusNode: _model.textFieldFocusNode5!,
                    addressValidator: _model.textController5Validator,
                  ),
                  ProfileResetPasswordButton(
                    emailController: _model.emailTextController!,
                  ),
                  ProfileSaveButton(
                    uploadedFileUrl: _model.uploadedFileUrl_uploadData8ag,
                    emailController: _model.emailTextController!,
                    nameController: _model.textController2!,
                    phoneController: _model.textController3!,
                    addressController: _model.textController5!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
