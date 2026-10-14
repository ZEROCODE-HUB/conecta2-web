import '/tamizajes/shared/assist_utils.dart'
    show limpiarAlertasAssist, validarAlertasAssist;
import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import 'package:google_fonts/google_fonts.dart';
import '../crearencuesta_model.dart';
import '../../encuesta_form_helpers.dart' show kCategoriaEncuesta;
import '/components/successpopup_widget.dart';
import '/components/text_field_alerta_widget.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class SidebarAccionesWidget extends StatelessWidget {
  final CrearencuestaModel model;
  final String? tipo;
  final VoidCallback onUpdate;

  const SidebarAccionesWidget({
    super.key,
    required this.model,
    required this.tipo,
    required this.onUpdate,
  });

  String _normalizeTitulo(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<bool> _tituloYaExiste({
    required String titulo,
    DocumentReference? excludeRef,
  }) async {
    final normalizado = _normalizeTitulo(titulo);
    final encuestas = await queryEncuestasRecordOnce();
    for (final e in encuestas) {
      if (excludeRef != null && e.reference == excludeRef) continue;
      if (_normalizeTitulo(e.titulo) == normalizado) return true;
    }
    return false;
  }

  // Crea o actualiza el doc de Firestore con el estado completo del _model.
  // Devuelve la ref persistida, o null si la validación falla. La primera
  // invocación hace .set() y guarda la ref en model.encuestaPersistedRef;
  // las siguientes hacen .update().
  Future<DocumentReference?> _persistirEncuesta({
    required bool publicado,
    required BuildContext context,
  }) async {
    final _model = model;
    final titulo = _model.textController1?.text.trim() ?? '';
    final esTamizaje = tipo == 'Tamizajes';
    // Las encuestas siempre se guardan con la categoría fija "Encuesta".
    if (!esTamizaje) {
      _model.categoriaValue = kCategoriaEncuesta;
      _model.categoria = kCategoriaEncuesta;
    }
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esTamizaje
              ? 'Ingresa un título para el tamizaje antes de continuar.'
              : 'Ingresa un título para la encuesta antes de continuar.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
    // La categoría queda fija al guardar, así que debe elegirse antes.
    if (tipo == 'Tamizajes' && (_model.categoriaValue ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Selecciona la categoría del tamizaje antes de guardar.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
    final existing = _model.encuestaPersistedRef;
    final duplicado =
        await _tituloYaExiste(titulo: titulo, excludeRef: existing);
    if (duplicado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ya existe un tamizaje con ese nombre. Usa un nombre diferente.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }

    final preguntasFS = _model.preguntasBuffer
        .map((p) => getPreguntasEncuestaFirestoreData(p, true))
        .toList();
    final alertasEspecialesFS = _model.alertasEspeciales
        .map((a) => getAlertaEspecialFirestoreData(a, true))
        .toList();

    // Mapeo de niveles clínicos a los campos del doc, dependiendo de la
    // categoría. Sustancias usa FFAppState().listaAlertasEnvio; Autoestima y
    // CDI usan los 3 campos bajo/moderado/alto; Beck usa el array `alertas`.
    final cat = _model.categoriaValue;
    if (cat == 'Escala autoestima' ||
        cat == 'CDI' ||
        cat == 'RQC' ||
        cat == 'SRQ' ||
        cat == 'CRQ' ||
        cat == 'RQC / SRQ' ||
        cat == 'CRQ / SRQ') {
      if (_model.nivelesAlerta.length < 3) {
        _model.seedNivelesAlerta(cat);
      }
    }
    List<Map<String, dynamic>> alertasFS;
    AlertaStruct? bajo;
    AlertaStruct? moderado;
    AlertaStruct? alto;
    if (cat == kCategoriaEncuesta) {
      // Encuesta: sin niveles ni alertas (sus preguntas no puntúan).
      alertasFS = [];
    } else if (cat == 'Consumo de SPA') {
      final errores = validarAlertasAssist(FFAppState().listaAlertasEnvio);
      if (errores.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errores.length == 1
                ? 'Revise las alertas: ${errores.first}'
                : 'Revise las alertas: ${errores.first} '
                    '(y ${errores.length - 1} más)'),
            backgroundColor: FlutterFlowTheme.of(context).error,
            duration: const Duration(seconds: 5),
          ),
        );
        return null;
      }
      alertasFS = getAlertaListFirestoreData(
          limpiarAlertasAssist(FFAppState().listaAlertasEnvio));
    } else if ((cat == 'Escala autoestima' || cat == 'CDI') &&
        _model.nivelesAlerta.length >= 3) {
      // Guardamos en bajo/moderado/alto (acceso directo) y también
      // replicamos al array `alertas` para que las vistas que usan
      // calcularNivelAlerta sigan funcionando.
      bajo = _model.nivelesAlerta[0];
      moderado = _model.nivelesAlerta[1];
      alto = _model.nivelesAlerta[2];
      alertasFS = _model.nivelesAlerta
          .map((a) => getAlertaFirestoreData(a, true))
          .toList();
    } else if ((cat == 'Depresión Beck' ||
            cat == 'Escala ansiedad' ||
            cat == 'RQC' ||
            cat == 'SRQ' ||
            cat == 'CRQ' ||
            cat == 'RQC / SRQ' ||
            cat == 'CRQ / SRQ') &&
        _model.nivelesAlerta.isNotEmpty) {
      alertasFS = _model.nivelesAlerta
          .map((a) => getAlertaFirestoreData(a, true))
          .toList();
    } else {
      alertasFS = getAlertaListFirestoreData(FFAppState().listaAlertasEnvio);
    }

    final payload = <String, dynamic>{
      ...createEncuestasRecordData(
        titulo: _model.textController1?.text,
        descripcion: _model.textController2?.text,
        publicado: publicado,
        tipo: tipo,
        categoria: _model.categoriaValue,
        bajo: bajo,
        moderado: moderado,
        alto: alto,
      ),
      ...mapToFirestore({
        'Roles': _model.roleValue ?? [],
        'Preguntas': preguntasFS,
        'alertas': alertasFS,
        'alertasEspeciales': alertasEspecialesFS,
      }),
    };

    if (existing == null) {
      final ref = EncuestasRecord.collection.doc();
      await ref.set({
        ...payload,
        ...mapToFirestore({
          'CreateAt': FieldValue.serverTimestamp(),
          'created_by': currentUserReference,
        }),
      });
      _model.encuestaPersistedRef = ref;
      return ref;
    } else {
      await existing.update(payload);
      return existing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _model = model; // for compatibility with copied code
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 50.0,
                    color: Color(0x26000000),
                    offset: Offset(
                      20.0,
                      20.0,
                    ),
                  )
                ],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 15.0),
                                    child: Text(
                                      'Dirigido a:',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              FlutterFlowDropDown<String>(
                                multiSelectController:
                                    _model.roleValueController ??=
                                        FormListFieldController<String>(null),
                                options: FFAppConstants.Role,
                                width: 276.0,
                                height: 56.0,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF9E8888),
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                hintText: 'Seleccionar',
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF265294),
                                  size: 35.0,
                                ),
                                fillColor: Color(0xFFF5F5F5),
                                elevation: 2.0,
                                borderColor:
                                    FlutterFlowTheme.of(context).alternate,
                                borderWidth: 2.0,
                                borderRadius: 8.0,
                                margin: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 4.0, 16.0, 4.0),
                                hidesUnderline: true,
                                isOverButton: false,
                                isSearchable: false,
                                isMultiSelect: true,
                                onMultiSelectChanged: (val) {
                                  _model.roleValue = val;
                                  onUpdate();
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 40.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                final ref = await _persistirEncuesta(
                                    publicado: false, context: context);
                                if (ref == null) return;
                                FFAppState().selectUser = 'VistaPrevia';
                                FFAppState().createEncuesta = true;
                                onUpdate();
                              },
                              text: 'Vista Previa',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 54.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF265294),
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 3.0,
                                borderSide: BorderSide(
                                  color: Color(0xFFF6BD33),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                final ref = await _persistirEncuesta(
                                    publicado: false, context: context);
                                if (ref == null) return;
                                FFAppState().selectUser = '';
                                onUpdate();
                              },
                              text: 'Guardar como borrador',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 54.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF265294),
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 3.0,
                                borderSide: BorderSide(
                                  color: Color(0xFFF6BD33),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                            ),
                          ),
                          Builder(
                            builder: (builderContext) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  final ref = await _persistirEncuesta(
                                      publicado: true, context: builderContext);
                                  if (ref == null) return;
                                  FFAppState().selectUser = '';
                                  onUpdate();
                                  await showDialog(
                                    context: builderContext,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(Directionality.of(
                                                    builderContext)),
                                        child: WebViewAware(
                                          child: SuccesspopupWidget(),
                                        ),
                                      );
                                    },
                                  );
                                },
                                text: tipo == 'Tamizajes'
                                    ? 'Publicar Tamizaje'
                                    : 'Publicar encuesta',
                                options: FFButtonOptions(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 54.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Color(0xFFF6BD33),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFF265294),
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                  elevation: 3.0,
                                  borderSide: BorderSide(
                                    color: Color(0xFFF6BD33),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._buildAlertasEspeciales(context),
        ].divide(SizedBox(height: 16.0)),
      ),
    );
  }

  List<Widget> _buildAlertasEspeciales(BuildContext context) {
    final _model = model;
    return [
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.2,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 50.0,
                color: Color(0x26000000),
                offset: Offset(
                  20.0,
                  20.0,
                ),
              )
            ],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Visibility(
            // Visible por categoría (antes dependía del tipo de la pregunta
            // que se estaba agregando y desaparecía con Condicionante).
            visible: _model.categoriaValue == 'Consumo de SPA' ||
                _model.tipoValue == 'Tamizaje (Sustancias)',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 0.0, 0.0),
                    child: Text(
                      'Alertas',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 0.0, 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Sustancia: ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      FlutterFlowDropDown<String>(
                        controller: _model.dropDownSustancia2ValueController ??=
                            FormFieldController<String>(null),
                        options: [
                          'Tabaco',
                          'Bebidas alcohólicas',
                          'Cannabis',
                          'Anfetaminas',
                          'Inhalantes',
                          'Tranquilizantes',
                          'Alucinógenos',
                          'Opiáceos',
                          'Otros',
                          'Cocaina'
                        ],
                        onChanged: (val) {
                          _model.dropDownSustancia2Value = val;
                          onUpdate();
                        },
                        width: 200.0,
                        height: 40.0,
                        textStyle:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                        hintText: 'Seleccione',
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 24.0,
                        ),
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 2.0,
                        borderColor: Colors.transparent,
                        borderWidth: 0.0,
                        borderRadius: 8.0,
                        margin: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        hidesUnderline: true,
                        isOverButton: false,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                  child: Text(
                    'Configure los rangos de cada sustancia. Las sustancias '
                    'que deje en 0 usarán los cortes ASSIST de la OMS '
                    '(Alcohol: Bajo 0–10, Moderado 11–26, Alto 27+; resto: '
                    'Bajo 0–3, Moderado 4–26, Alto 27+). En el nivel Alto, '
                    'Max = 0 significa "sin tope".',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    final listaAlertasSustancias =
                        FFAppState().listaAlertasEnvio.toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(listaAlertasSustancias.length,
                          (listaAlertasSustanciasIndex) {
                        final listaAlertasSustanciasItem =
                            listaAlertasSustancias[listaAlertasSustanciasIndex];
                        return Visibility(
                          visible: listaAlertasSustanciasItem.sustancia ==
                              _model.dropDownSustancia2Value,
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 20.0, 8.0, 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listaAlertasSustanciasItem.nivel,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Min',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      TextFieldAlertaWidget(
                                        key: Key(
                                            'Keyswz_${listaAlertasSustanciasIndex}_of_${listaAlertasSustancias.length}'),
                                        parameter1:
                                            listaAlertasSustanciasItem.min,
                                        accion: (nuevoTexto) async {
                                          FFAppState()
                                              .updateListaAlertasEnvioAtIndex(
                                            listaAlertasSustanciasIndex,
                                            (e) => e..min = nuevoTexto,
                                          );
                                          onUpdate();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Max',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      TextFieldAlertaWidget(
                                        key: Key(
                                            'Key82i_${listaAlertasSustanciasIndex}_of_${listaAlertasSustancias.length}'),
                                        parameter1:
                                            listaAlertasSustanciasItem.max,
                                        accion: (nuevoTexto) async {
                                          FFAppState()
                                              .updateListaAlertasEnvioAtIndex(
                                            listaAlertasSustanciasIndex,
                                            (e) => e..max = nuevoTexto,
                                          );
                                          onUpdate();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) {
          if (_model.categoriaValue != 'CRQ / SRQ' &&
              _model.categoriaValue != 'CRQ' &&
              _model.categoriaValue != 'RQC' &&
              _model.categoriaValue != 'SRQ') {
            return SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 50.0,
                    color: Color(0x26000000),
                    offset: Offset(20.0, 20.0),
                  )
                ],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 15.0),
                      child: Text(
                        'Alertas Especiales RQC/SRQ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    TextFormField(
                      controller: _model.alertaEspecialNombreTextController ??=
                          TextEditingController(),
                      focusNode: _model.alertaEspecialNombreFocusNode ??=
                          FocusNode(),
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Nombre de la alerta',
                        hintStyle: FlutterFlowTheme.of(context)
                            .labelMedium
                            .override(
                                font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle),
                                color: Color(0xFF9E8888),
                                fontSize: 14.0,
                                letterSpacing: 0.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(8.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(8.0)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(8.0)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle),
                          letterSpacing: 0.0),
                      validator: _model
                          .alertaEspecialNombreTextControllerValidator
                          .asValidator(context),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                      child: FlutterFlowDropDown<String>(
                        controller:
                            _model.alertaEspecialCondicionValueController ??=
                                FormFieldController<String>(null),
                        options: [
                          'Todas en Sí',
                          'Al menos una en Sí',
                          'Al menos dos en Sí',
                          'Todas en No',
                          'Al menos una en No',
                          'Al menos dos en No',
                          'Puntaje igual a'
                        ],
                        onChanged: (val) {
                          _model.alertaEspecialCondicionValue = val;
                          onUpdate();
                        },
                        width: double.infinity,
                        height: 44.0,
                        textStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                                font: GoogleFonts.inter(
                                    fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle),
                                letterSpacing: 0.0),
                        hintText: 'Condición...',
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0),
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 2.0,
                        borderColor: Colors.transparent,
                        borderWidth: 0.0,
                        borderRadius: 8.0,
                        margin: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        hidesUnderline: true,
                        isOverButton: false,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                    ),
                    if (_model.alertaEspecialCondicionValue ==
                        'Puntaje igual a')
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: TextFormField(
                          controller:
                              _model.alertaEspecialPuntajeTextController ??=
                                  TextEditingController(),
                          focusNode: _model.alertaEspecialPuntajeFocusNode ??=
                              FocusNode(),
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Puntaje',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle),
                                    color: Color(0xFF9E8888),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(8.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(8.0)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(8.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(8.0)),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle),
                                  letterSpacing: 0.0),
                          validator: _model
                              .alertaEspecialPuntajeTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                      child: TextFormField(
                        controller:
                            _model.alertaEspecialPreguntasTextController ??=
                                TextEditingController(),
                        focusNode: _model.alertaEspecialPreguntasFocusNode ??=
                            FocusNode(),
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Números de pregunta (ej: 1, 2, 11)',
                          hintStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle),
                                  color: Color(0xFF9E8888),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(8.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(8.0)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(8.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(8.0)),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle),
                            letterSpacing: 0.0),
                        validator: _model
                            .alertaEspecialPreguntasTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 12.0, 0.0, 0.0),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (_model.alertaEspecialNombreTextController?.text
                                        .isNotEmpty ==
                                    true &&
                                _model.alertaEspecialCondicionValue != null) {
                              final preguntasRaw = _model
                                      .alertaEspecialPreguntasTextController
                                      ?.text ??
                                  '';
                              final List<int> preguntasParsed = preguntasRaw
                                  .split(',')
                                  .map((s) => int.tryParse(s.trim()))
                                  .where((v) => v != null)
                                  .cast<int>()
                                  .toList();
                              final nuevaAlerta = createAlertaEspecialStruct(
                                nombre: _model
                                        .alertaEspecialNombreTextController
                                        ?.text ??
                                    '',
                                condicion:
                                    _model.alertaEspecialCondicionValue ?? '',
                                puntaje: int.tryParse(_model
                                            .alertaEspecialPuntajeTextController
                                            ?.text ??
                                        '') ??
                                    0,
                                clearUnsetFields: false,
                              );
                              nuevaAlerta.preguntas = preguntasParsed;
                              _model.addToAlertasEspeciales(nuevaAlerta);
                              _model.alertaEspecialNombreTextController
                                  ?.clear();
                              _model.alertaEspecialCondicionValueController
                                  ?.value = null;
                              _model.alertaEspecialPuntajeTextController
                                  ?.clear();
                              _model.alertaEspecialPreguntasTextController
                                  ?.clear();
                              onUpdate();
                            }
                          },
                          text: 'Agregar alerta especial',
                          options: FFButtonOptions(
                            height: 34.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 14.0, 0.0),
                            color: const Color(0xFF265294),
                            textStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    if (_model.alertasEspeciales.isNotEmpty)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alertas especiales guardadas',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500),
                            ),
                            ...List.generate(_model.alertasEspeciales.length,
                                (idx) {
                              final alerta = _model.alertasEspeciales[idx];
                              return Container(
                                margin: EdgeInsets.only(top: 8.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(alerta.nombre,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                      font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          Text(
                                              alerta.condicion +
                                                  (alerta.condicion ==
                                                          'Puntaje igual a'
                                                      ? ': ${alerta.puntaje}'
                                                      : ''),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                      font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle),
                                                      letterSpacing: 0.0)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20.0),
                                      onPressed: () {
                                        _model
                                            .removeAtIndexFromAlertasEspeciales(
                                                idx);
                                        onUpdate();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      _buildNivelesClinicos(context),
    ];
  }

  // Panel de umbrales clínicos por categoría (Autoestima / CDI / Beck).
  // Se renderiza solo si la categoría tiene niveles configurables y
  // `nivelesAlerta` ya fue sembrado con defaults desde el model.
  Widget _buildNivelesClinicos(BuildContext context) {
    final _model = model;
    final cat = _model.categoriaValue;
    const categoriasConNiveles = [
      'Escala autoestima',
      'CDI',
      'Depresión Beck',
      'Escala ansiedad',
      'RQC',
      'SRQ',
      'CRQ',
      'RQC / SRQ',
      'CRQ / SRQ',
    ];
    if (!categoriasConNiveles.contains(cat) || _model.nivelesAlerta.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = FlutterFlowTheme.of(context);
    final tituloSeccion = cat == 'Escala autoestima'
        ? 'Niveles de autoestima'
        : cat == 'CDI'
            ? 'Niveles de depresión (CDI)'
            : cat == 'Escala ansiedad'
                ? 'Niveles de ansiedad'
                : cat == 'Depresión Beck'
                    ? 'Niveles de depresión (Beck)'
                    : cat == 'SRQ'
                        ? 'Puntuación psicométrica y subescalas'
                        : 'Escala de valoración';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.2,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 12),
                child: Text(
                  tituloSeccion,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Encabezado de columnas
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text('Nivel',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.secondaryText)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Min',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.secondaryText)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Max',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.secondaryText)),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < _model.nivelesAlerta.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _model.nivelesAlerta[i].nivel,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFieldAlertaWidget(
                          key: ValueKey('niv_min_${i}_$cat'),
                          parameter1: _model.nivelesAlerta[i].min,
                          accion: (nuevoTexto) async {
                            _model.nivelesAlerta[i].min = nuevoTexto;
                            onUpdate();
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: TextFieldAlertaWidget(
                          key: ValueKey('niv_max_${i}_$cat'),
                          parameter1: _model.nivelesAlerta[i].max,
                          accion: (nuevoTexto) async {
                            _model.nivelesAlerta[i].max = nuevoTexto;
                            onUpdate();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
