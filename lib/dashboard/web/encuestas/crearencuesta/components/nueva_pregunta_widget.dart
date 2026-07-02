import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/backend/backend.dart';
import '../crearencuesta_model.dart';
import '../../encuesta_form_helpers.dart';

class NuevaPreguntaWidget extends StatelessWidget {
  final CrearencuestaModel model;
  final VoidCallback onUpdate;

  const NuevaPreguntaWidget({
    super.key,
    required this.model,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preguntas',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                            ),
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Color(0xFF6E98D7),
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: _buildFormularioPregunta(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(width: 25.0)),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 40.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FFButtonWidget(
                onPressed: () async {
                  // 1. Common Validation: Question Title
                  if (model.preguntaTextController1.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Por favor ingrese el título de la pregunta.',
                          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
                        ),
                        duration: Duration(milliseconds: 4000),
                        backgroundColor: FlutterFlowTheme.of(context).error,
                      ),
                    );
                    return;
                  }

                  int? finalNumPregunta;

                  // 2. Type-Specific Validation
                  if (model.tipoValue == 'Tamizaje (Sustancias)') {
                    if (model.dropDownSustanciaValue == null ||
                        model.dropDownSustanciaValue == '-' ||
                        model.dropDownSustanciaValue == 'Seleccione') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Por favor seleccione una sustancia.',
                            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
                          ),
                          duration: Duration(milliseconds: 4000),
                          backgroundColor: FlutterFlowTheme.of(context).error,
                        ),
                      );
                      return;
                    }
                  } else if (model.tipoValue == 'Tamizaje CRQ / SRQ' || model.tipoValue == 'Tamizaje CRQ' || model.tipoValue == 'Tamizaje SRQ') {
                    int? numPregunta = int.tryParse(model.crqNumeroPreguntaTextController?.text ?? '');
                    if (numPregunta == null || numPregunta <= 0) {
                      int maxNum = 0;
                      for (var p in model.preguntasBuffer) {
                        if (p.numeroPregunta > maxNum) maxNum = p.numeroPregunta;
                      }
                      numPregunta = maxNum + 1;
                    }

                    if (model.preguntasBuffer.any((p) => p.numeroPregunta == numPregunta)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'El número de pregunta $numPregunta ya existe. Debe ser único.',
                            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
                          ),
                          duration: Duration(milliseconds: 4000),
                          backgroundColor: FlutterFlowTheme.of(context).error,
                        ),
                      );
                      return;
                    }
                    finalNumPregunta = numPregunta;
                  } else if (model.tipoValue == 'Selección' && model.seleccionunica.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Por favor agregue al menos una opción.',
                          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
                        ),
                        duration: Duration(milliseconds: 4000),
                        backgroundColor: FlutterFlowTheme.of(context).error,
                      ),
                    );
                    return;
                  }

                  // 3. Agregar al buffer local (NO persiste a Firestore aquí;
                  // la persistencia ocurre al presionar Vista Previa /
                  // Guardar borrador / Publicar).
                  //
                  // Las listas (respuestaTamizaje / respuestaSelection /
                  // seleccionunica / respuestaCondicionante) se setean vía
                  // setters del struct, NO vía fieldValues — fieldValues
                  // solo surte efecto al serializar contra Firestore, pero
                  // acá estamos en buffer local y el panel los lee directo
                  // de los getters del struct.
                  final esCDIoBeck = model.tipoValue == 'Tamizaje CDI' ||
                      model.tipoValue == 'Tamizajes Depresion Beck';
                  final esCRQ = model.tipoValue == 'Tamizaje CRQ / SRQ' ||
                      model.tipoValue == 'Tamizaje CRQ' ||
                      model.tipoValue == 'Tamizaje SRQ';
                  final respuestaTamizaje = esCDIoBeck
                      ? model.respuestaCDI.toList()
                      : esCRQ
                          ? [
                              AtributosStruct(
                                  etiqueta: 'Sí',
                                  valor: int.tryParse(model
                                              .crqSiScoreTextController
                                              ?.text ??
                                          '') ??
                                      1),
                              AtributosStruct(
                                  etiqueta: 'No',
                                  valor: int.tryParse(model
                                              .crqNoScoreTextController
                                              ?.text ??
                                          '') ??
                                      0),
                            ]
                          : model.respuestaTamizaje.toList();

                  final nueva = createPreguntasEncuestaStruct(
                    pregunta: model.preguntaTextController1.text,
                    tipo: model.tipoValue,
                    respuestaLarga: model.abiertaTextController.text,
                    respuestaSUnicaCorrecta: model.sunicarespValue,
                    sustancia: model.dropDownSustanciaValue,
                    ocultarRespuesta: model.ocultarRespuestaValue,
                    variable: esCDIoBeck ? model.variableCDIValue : null,
                    numeroPregunta: esCRQ ? finalNumPregunta : null,
                    nPregunta: model.checkboxNPValue1 == true ? 1 : 0,
                    clearUnsetFields: false,
                  )
                    ..respuestaTamizaje = respuestaTamizaje
                    ..respuestaSelection = model.respuestaSelection.toList()
                    ..respuestasSeleccionUnica = model.seleccionunica.toList()
                    ..respuestaCondicionante =
                        model.respuestaCondicionante.toList();

                  model.addToPreguntasBuffer(nueva);

                  // 4. FULL STATE RESET
                  model.respuestaSelection = [];
                  model.seleccionunicarespuesta = null;
                  model.seleccionunica = [];
                  model.respuestaTamizaje = [];
                  model.respuestaCondicionante = [];
                  model.respuestaCDI = [];
                  model.variableCDI = null;
                  model.variableCDIValue = null;
                  model.ideacionSuicidaValue = false;
                  model.ocultarRespuestaValue = false;
                  model.dropDownSustanciaValue = null;
                  model.checkboxNPValue1 = false;
                  model.dropDownSustanciaValueController?.value = null;
                  model.variableCDIValueController?.value = null;

                  // Clear text controllers
                  model.preguntaTextController1?.clear();
                  model.abiertaTextController?.clear();
                  model.cdiTextController?.clear();
                  model.cdiValorTextController?.clear();
                  model.crqNumeroPreguntaTextController?.clear();
                  model.crqSiScoreTextController?.clear();
                  model.crqNoScoreTextController?.clear();
                  model.autoestimaEtiquetaTextController?.clear();
                  model.autoestimaValorTextController?.clear();

                  // Reset type selection
                  model.tipoValue = null;
                  model.tipoValueController?.value = null;

                  onUpdate();
                },
                text: 'Agregar preguntas',
                options: FFButtonOptions(
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: Color(0xFF265294),
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 3.0,
                  borderSide: BorderSide(
                    color: Color(0xFFF6BD33),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormularioPregunta(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Título de la pregunta',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                      child: TextFormField(
                        controller: model.preguntaTextController1,
                        focusNode: model.preguntaFocusNode1,
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Ingresa la pregunta...',
                          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Inter',
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                              ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 14.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF265294),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                            ),
                        validator: model.preguntaTextController1Validator.asValidator(context),
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
                    Text(
                      'Tipo de pregunta',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                      child: Builder(builder: (context) {
                        const todosLosTipos = [
                          'abiertas',
                          'selección',
                          'Selección única',
                          'Verdadero o falso',
                          'Condicionante',
                          'Tamizaje',
                          'Tamizaje (Sustancias)',
                          'Tamizaje autoestima',
                          'Tamizaje CDI',
                          'Tamizajes Depresion Beck',
                          'Tamizaje CRQ',
                          'Tamizaje SRQ',
                          'Tamizaje CRQ / SRQ',
                          'Tamizaje ansiedad',
                          'Descriptiva'
                        ];
                        final opciones = tiposPermitidos(model.categoria, todosLosTipos);
                        // Si el tipo seleccionado ya no es valido para la categoria actual, limpiarlo.
                        if (model.tipoValue != null && !opciones.contains(model.tipoValue)) {
                          model.tipoValue = null;
                          model.tipoValueController?.value = null;
                        }
                        return FlutterFlowDropDown<String>(
                        controller: model.tipoValueController ??= FormFieldController<String>(null),
                        options: opciones,
                        onChanged: (val) {
                          model.tipoValue = val;
                          onUpdate();
                        },
                        width: double.infinity,
                        height: 56.0,
                        textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                        hintText: 'Seleccione un tipo...',
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF265294),
                          size: 35.0,
                        ),
                        fillColor: Colors.white,
                        elevation: 2.0,
                        borderColor: FlutterFlowTheme.of(context).alternate,
                        borderWidth: 2.0,
                        borderRadius: 8.0,
                        margin: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                        hidesUnderline: true,
                        isOverButton: false,
                        isSearchable: false,
                        isMultiSelect: false,
                      );
                      }),
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(width: 25.0)),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: EncuestaFormHelpers.buildFormularioEspecifico(
            context,
            model,
            onUpdate,
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 153.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Theme(
                        data: ThemeData(
                          checkboxTheme: CheckboxThemeData(
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          unselectedWidgetColor: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        child: Checkbox(
                          value: model.checkboxNPValue1 ??= false,
                          onChanged: (val) {
                            model.checkboxNPValue1 = val!;
                            onUpdate();
                          },
                          side: BorderSide(
                            width: 2,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          activeColor: Color(0xFF265294),
                          checkColor: FlutterFlowTheme.of(context).info,
                        ),
                      ),
                      Text(
                        'Obligatorio',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
