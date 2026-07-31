// Main entry point for editing an encuesta. This widget replaces the
// legacy FlutterFlow-generated `model/editar_encuesta/editar_encuesta_widget.dart`.
//
// The widget loads an existing `EncuestasRecord` into an
// [EditarEncuestaModel], composes the modular form components under
// `forms/` to add new questions, shows existing questions via the
// already-refactored `PreguntaCard`, and delegates alert configuration
// to the widgets in `widgets/`.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/backend/backend.dart';
import '/dashboard/web/encuestas/crearencuesta/pregunta_card_widget.dart';
import '/dashboard/web/encuestas/model/emptytest/emptytest_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';

import '../encuesta_form_helpers.dart';
import 'editar_encuesta_model.dart';
import 'forms/form_abierta.dart';
import 'forms/form_condicionante.dart';
import 'forms/form_descriptiva.dart';
import 'forms/form_seleccion.dart';
import 'forms/form_sustancias.dart';
import 'forms/form_tamizaje.dart';
import 'forms/form_verdadero_falso.dart';
import 'widgets/alertas_config.dart';
import 'widgets/alertas_especiales_config.dart';

class EditarEncuestaWidget extends StatefulWidget {
  const EditarEncuestaWidget({
    super.key,
    required this.encuestaID,
    required this.doc,
  });

  final DocumentReference? encuestaID;
  final EncuestasRecord? doc;

  @override
  State<EditarEncuestaWidget> createState() => _EditarEncuestaWidgetState();
}

class _EditarEncuestaWidgetState extends State<EditarEncuestaWidget> {
  late final EditarEncuestaModel _model;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const List<String> _tiposPregunta = [
    'abiertas',
    'selección',
    'Selección única',
    'Verdadero o falso',
    'Condicionante',
    'Tamizaje',
    'Tamizaje (Sustancias)',
    'Tamizaje autoestima',
    'Tamizaje ansiedad',
    'Tamizaje CDI',
    'Tamizajes Depresion Beck',
    'Tamizaje CRQ',
    'Tamizaje SRQ',
    'Tamizaje CRQ / SRQ',
    'Descriptiva',
  ];

  @override
  void initState() {
    super.initState();
    _model = EditarEncuestaModel();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.doc != null) {
        setState(() {
          _model.loadFromRecord(widget.doc!, _tiposPregunta);
          // Force-sync the controller that may have been created with null
          // during the first build (before this callback fired).
          final v = _model.tipoValue;
          if (v != null) {
            if (_model.tipoValueController == null) {
              _model.tipoValueController = FormFieldController<String>(v);
            } else {
              _model.tipoValueController!.value = v;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: SingleChildScrollView(
        primary: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(40.0, 20.0, 40.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30.0),
              _buildBody(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Row(
      children: [
        InkWell(
          onTap: () {
            FFAppState().selectUser = '';
            _update();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/Down.png',
              width: 26.0,
              height: 26.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20.0),
        Text(
          'Editar Encuesta',
          style: tema.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
            fontSize: 36.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Body (form + sidebar) ─────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    if (widget.encuestaID == null) {
      return const Center(child: Text('Encuesta no especificada.'));
    }
    return StreamBuilder<EncuestasRecord>(
      stream: EncuestasRecord.getDocument(widget.encuestaID!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        }
        final encuesta = snapshot.data!;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildMainPanel(context, encuesta)),
            const SizedBox(width: 20.0),
            _buildSidebar(context, encuesta),
          ],
        );
      },
    );
  }

  // ── Main panel ─────────────────────────────────────────────────────────

  Widget _buildMainPanel(BuildContext context, EncuestasRecord encuesta) {
    return Container(
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatosPrincipales(context),
              const Divider(height: 40.0),
              _buildNuevaPreguntaForm(context, encuesta),
              const Divider(height: 40.0),
              _buildListaPreguntas(encuesta),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatosPrincipales(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos principales',
          style: tema.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 20.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLabeledField(
                label: 'Nombre de la encuesta',
                child: TextFormField(
                  controller: _model.tituloController,
                  focusNode: _model.tituloFocus,
                  maxLines: 4,
                  minLines: 1,
                  decoration: _filledDecoration(hint: 'Nombre de la encuesta'),
                ),
              ),
            ),
            const SizedBox(width: 25.0),
            Expanded(
              child: _buildLabeledField(
                label: 'Categoría',
                child: FlutterFlowDropDown<String>(
                  controller: _model.categoriaValueController ??=
                      FormFieldController<String>(_model.categoriaValue),
                  options: const [
                    'Todas',
                    'Consumo de SPA',
                    'Escala autoestima',
                    'CDI',
                    'Depresión Beck',
                    'CRQ / SRQ',
                    'CRQ',
                    'SRQ',
                  ],
                  onChanged: (val) {
                    _model.categoriaValue = val;
                    final permitidos = tiposPermitidos(val, _tiposPregunta);
                    if (_model.tipoValue != null &&
                        !permitidos.contains(_model.tipoValue)) {
                      _model.tipoValue = null;
                      _model.tipoValueController?.value = null;
                    }
                    _update();
                  },
                  width: double.infinity,
                  height: 48.0,
                  textStyle: tema.bodyMedium,
                  hintText: 'Seleccionar',
                  fillColor: tema.secondaryBackground,
                  elevation: 2.0,
                  borderColor: Colors.transparent,
                  borderWidth: 0.0,
                  borderRadius: 8.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 0.0, 12.0, 0.0),
                  hidesUnderline: true,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        _buildLabeledField(
          label: 'Descripción de la encuesta',
          child: TextFormField(
            controller: _model.descripcionController,
            focusNode: _model.descripcionFocus,
            maxLines: 5,
            minLines: 1,
            decoration: _filledDecoration(hint: 'Descripción...'),
          ),
        ),
      ],
    );
  }

  // ── Nueva pregunta ─────────────────────────────────────────────────────

  Widget _buildNuevaPreguntaForm(
      BuildContext context, EncuestasRecord encuesta) {
    final tema = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFF6E98D7)),
      ),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva pregunta',
            style: tema.bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLabeledField(
                  label: 'Título de la pregunta',
                  child: TextFormField(
                    controller: _model.preguntaController,
                    focusNode: _model.preguntaFocus,
                    decoration:
                        _filledDecoration(hint: 'Ingresa la pregunta...'),
                  ),
                ),
              ),
              const SizedBox(width: 25.0),
              Expanded(
                child: _buildLabeledField(
                  label: 'Tipo de pregunta',
                  child: Builder(builder: (context) {
                    final opciones =
                        tiposPermitidos(_model.categoriaValue, _tiposPregunta);
                    if (_model.tipoValue != null &&
                        !opciones.contains(_model.tipoValue)) {
                      _model.tipoValue = null;
                      _model.tipoValueController?.value = null;
                    }
                    return FlutterFlowDropDown<String>(
                      controller: _model.tipoValueController ??=
                          FormFieldController<String>(_model.tipoValue),
                      options: opciones,
                      onChanged: (val) {
                        if (val == null) return;
                        _model.tipoValue = val;
                        _update();
                      },
                      width: double.infinity,
                      height: 56.0,
                      textStyle: tema.bodyMedium,
                      hintText: 'Seleccione un tipo...',
                      fillColor: Colors.white,
                      elevation: 2.0,
                      borderColor: tema.alternate,
                      borderWidth: 2.0,
                      borderRadius: 8.0,
                      margin: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 4.0, 16.0, 4.0),
                      hidesUnderline: true,
                      isSearchable: false,
                      isMultiSelect: false,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildTipoEspecificoForm(),
          if (_model.tipoValue != null &&
              _model.tipoValue != 'Descriptiva') ...[
            const SizedBox(height: 10.0),
            Row(
              children: [
                Checkbox(
                  value: _model.ocultarRespuestaValue,
                  onChanged: (v) {
                    _model.ocultarRespuestaValue = v ?? false;
                    _update();
                  },
                ),
                const Text('Ocultar respuesta'),
              ],
            ),
          ],
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _model.obligatorio,
                    onChanged: (v) {
                      _model.obligatorio = v ?? false;
                      _update();
                    },
                    activeColor: const Color(0xFF265294),
                  ),
                  const Text('Obligatorio'),
                ],
              ),
              const SizedBox(width: 20.0),
              FFButtonWidget(
                onPressed: () => _agregarPregunta(context, encuesta),
                text: 'Agregar pregunta',
                options: FFButtonOptions(
                  height: 44.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0, 0.0, 24.0, 0.0),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  textStyle: tema.titleSmall.override(
                    color: const Color(0xFF265294),
                    fontSize: 16.0,
                  ),
                  elevation: 3.0,
                  borderSide: const BorderSide(
                    color: Color(0xFFF6BD33),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipoEspecificoForm() {
    switch (_model.tipoValue) {
      case 'abiertas':
        return FormAbierta(model: _model);
      case 'selección':
        return FormSeleccion(model: _model, onUpdate: _update);
      case 'Selección única':
        return FormSeleccionUnica(model: _model, onUpdate: _update);
      case 'Verdadero o falso':
        return FormVerdaderoFalso(model: _model, onUpdate: _update);
      case 'Condicionante':
        return FormCondicionante(model: _model, onUpdate: _update);
      case 'Tamizaje':
      case 'Tamizaje autoestima':
        return FormTamizajeAutoestima(model: _model, onUpdate: _update);
      case 'Tamizaje (Sustancias)':
        return FormSustancias(model: _model, onUpdate: _update);
      case 'Tamizaje CDI':
      case 'Tamizajes Depresion Beck':
        return FormTamizajeCDI(model: _model, onUpdate: _update);
      case 'Tamizaje CRQ / SRQ':
      case 'Tamizaje CRQ':
      case 'Tamizaje SRQ':
        return FormTamizajeCRQ(model: _model);
      case 'Descriptiva':
        return FormDescriptiva(model: _model);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _agregarPregunta(
      BuildContext context, EncuestasRecord encuesta) async {
    if (_model.preguntaController.text.trim().isEmpty) {
      _showError(context, 'Por favor ingrese el título de la pregunta.');
      return;
    }
    if (_model.tipoValue == null) {
      _showError(context, 'Por favor seleccione un tipo de pregunta.');
      return;
    }
    if (_model.tipoValue == 'Tamizaje (Sustancias)' &&
        (_model.sustanciaValue == null || _model.sustanciaValue!.isEmpty)) {
      _showError(context, 'Por favor seleccione una sustancia.');
      return;
    }
    if (_model.tipoValue == 'Selección única' &&
        _model.seleccionUnica.isEmpty) {
      _showError(context, 'Por favor agregue al menos una opción.');
      return;
    }

    await encuesta.reference.update(_model.buildNuevaPreguntaFirestoreEntry());

    setState(() {
      _model.resetNuevaPreguntaForm();
    });
  }

  void _showError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje,
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText)),
        duration: const Duration(milliseconds: 3500),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }

  String _normalizeTitulo(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<bool> _tituloYaExiste({
    required String titulo,
    required DocumentReference encuestaRef,
  }) async {
    final normalizado = _normalizeTitulo(titulo);
    final encuestas = await queryEncuestasRecordOnce();
    for (final e in encuestas) {
      if (e.reference == encuestaRef) continue;
      if (_normalizeTitulo(e.titulo) == normalizado) return true;
    }
    return false;
  }

  // ── Lista de preguntas ya guardadas ───────────────────────────────────

  Widget _buildListaPreguntas(EncuestasRecord encuesta) {
    final preguntas = encuesta.preguntas.toList();
    if (preguntas.isEmpty) {
      return const Center(child: EmptytestWidget());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < preguntas.length; i++)
          PreguntaCard(
            pregunta: preguntas[i],
            encuestasRecord: encuesta,
            index: i,
            categoria: _model.categoriaValue ?? encuesta.categoria,
            onEdit: (updatedPregunta) {
              setState(() {
                // If this widget is used, update in firestore or local state
                encuesta.reference.update({
                  'Preguntas': FieldValue.arrayRemove([
                    getPreguntasEncuestaFirestoreData(
                      updatePreguntasEncuestaStruct(
                        preguntas[i],
                        clearUnsetFields: false,
                      ),
                      true,
                    )
                  ])
                }).then((_) {
                  encuesta.reference.update({
                    'Preguntas': FieldValue.arrayUnion([
                      getPreguntasEncuestaFirestoreData(
                        updatePreguntasEncuestaStruct(
                          updatedPregunta,
                          clearUnsetFields: false,
                        ),
                        true,
                      )
                    ])
                  });
                });
              });
            },
          ),
      ],
    );
  }

  // ── Sidebar (roles + botones + alertas) ───────────────────────────────

  Widget _buildSidebar(BuildContext context, EncuestasRecord encuesta) {
    final tema = FlutterFlowTheme.of(context);
    final width = MediaQuery.sizeOf(context).width * 0.2;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dirigido a:',
                  style: tema.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 12.0),
                FlutterFlowDropDown<String>(
                  multiSelectController: _model.rolesValueController ??=
                      FormListFieldController<String>(
                          List<String>.from(encuesta.roles)),
                  options: FFAppConstants.Role,
                  width: double.infinity,
                  height: 56.0,
                  textStyle: tema.bodyMedium,
                  hintText: 'Seleccionar',
                  fillColor: const Color(0xFFF5F5F5),
                  elevation: 2.0,
                  borderColor: tema.alternate,
                  borderWidth: 2.0,
                  borderRadius: 8.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 4.0, 16.0, 4.0),
                  hidesUnderline: true,
                  isSearchable: false,
                  isMultiSelect: true,
                  onMultiSelectChanged: (val) async {
                    _model.rolesValue = val ?? [];
                    await encuesta.reference.update({
                      ...mapToFirestore({'Roles': _model.rolesValue}),
                    });
                    _update();
                  },
                ),
                const SizedBox(height: 40.0),
                _buildActionButton(
                  label: 'Vista Previa',
                  onPressed: () => _guardarYNavegar(encuesta,
                      publicado: false, vistaPrevia: true),
                ),
                const SizedBox(height: 20.0),
                _buildActionButton(
                  label: 'Guardar como borrador',
                  onPressed: () => _guardarYNavegar(encuesta,
                      publicado: false, vistaPrevia: false),
                ),
                const SizedBox(height: 20.0),
                _buildActionButton(
                  label: 'Publicar encuesta',
                  onPressed: () => _guardarYNavegar(encuesta,
                      publicado: true, vistaPrevia: false),
                  filled: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          AlertasConfig(
            model: _model,
            onUpdate: _update,
            encuesta: encuesta,
          ),
          const SizedBox(height: 16.0),
          AlertasEspecialesConfig(
            model: _model,
            encuestaID: widget.encuestaID!,
            onUpdate: _update,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Future<void> Function() onPressed,
    bool filled = false,
  }) {
    final tema = FlutterFlowTheme.of(context);
    return FFButtonWidget(
      onPressed: onPressed,
      text: label,
      options: FFButtonOptions(
        width: double.infinity,
        height: 54.0,
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        color: filled ? const Color(0xFFF6BD33) : tema.secondaryBackground,
        textStyle: tema.titleSmall.override(
          color: const Color(0xFF265294),
          fontSize: 18.0,
        ),
        elevation: 3.0,
        borderSide: const BorderSide(color: Color(0xFFF6BD33), width: 1.0),
        borderRadius: BorderRadius.circular(40.0),
      ),
    );
  }

  Future<void> _guardarYNavegar(
    EncuestasRecord encuesta, {
    required bool publicado,
    required bool vistaPrevia,
  }) async {
    final titulo = _model.tituloController.text.trim();
    if (titulo.isEmpty) {
      _showError(context, 'El nombre del tamizaje es obligatorio.');
      return;
    }
    final duplicado =
        await _tituloYaExiste(titulo: titulo, encuestaRef: encuesta.reference);
    if (duplicado) {
      _showError(
        context,
        'Ya existe un tamizaje con ese nombre. Usa un nombre diferente.',
      );
      return;
    }
    await encuesta.reference.update(createEncuestasRecordData(
      titulo: titulo,
      descripcion: _model.descripcionController.text,
      categoria: _model.categoriaValue,
      publicado: publicado,
    ));
    FFAppState().selectUser = vistaPrevia ? 'VistaPrevia' : '';
    if (vistaPrevia) {
      FFAppState().createEncuesta = false;
    }
    _update();
  }

  // ── Small UI helpers ──────────────────────────────────────────────────

  Widget _buildLabeledField({required String label, required Widget child}) {
    final tema = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tema.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w500),
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(height: 10.0),
        child,
      ],
    );
  }

  InputDecoration _filledDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
