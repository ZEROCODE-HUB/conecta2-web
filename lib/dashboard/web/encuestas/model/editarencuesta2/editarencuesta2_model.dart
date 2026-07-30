import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'editarencuesta2_widget.dart' show Editarencuesta2Widget;
import '/components/text_fieltaamizaje_model.dart';
import '/components/seleccion_unica_model.dart';
import 'package:flutter/material.dart';


class Editarencuesta2Model extends FlutterFlowModel<Editarencuesta2Widget> {
  ///  Local state fields for this component.

  List<String> respuestaSelection = [];
  void addToRespuestaSelection(String item) => respuestaSelection.add(item);
  void removeFromRespuestaSelection(String item) =>
      respuestaSelection.remove(item);
  void removeAtIndexFromRespuestaSelection(int index) =>
      respuestaSelection.removeAt(index);

  List<String> seleccionunica = [];
  void addToSeleccionunica(String item) => seleccionunica.add(item);
  void removeFromSeleccionunica(String item) => seleccionunica.remove(item);
  void removeAtIndexFromSeleccionunica(int index) =>
      seleccionunica.removeAt(index);

  String? seleccionunicarespuesta;

  // Tamizaje autoestima / sustancias / base
  List<AtributosStruct> respuestaTamizaje = [];
  List<AtributosStruct> get listaTamizaje => respuestaTamizaje;
  set listaTamizaje(List<AtributosStruct> val) => respuestaTamizaje = val;

  void addToRespuestaTamizaje(AtributosStruct item) => respuestaTamizaje.add(item);
  void addToListaTamizaje(AtributosStruct item) => addToRespuestaTamizaje(item);

  void removeFromRespuestaTamizaje(AtributosStruct item) =>
      respuestaTamizaje.remove(item);
  void removeFromListaTamizaje(AtributosStruct item) =>
      removeFromRespuestaTamizaje(item);

  void removeAtIndexFromRespuestaTamizaje(int index) =>
      respuestaTamizaje.removeAt(index);
  void removeAtIndexFromListaTamizaje(int index) =>
      removeAtIndexFromRespuestaTamizaje(index);

  void insertAtIndexInRespuestaTamizaje(int index, AtributosStruct item) =>
      respuestaTamizaje.insert(index, item);
  void updateRespuestaTamizajeAtIndex(
          int index, Function(AtributosStruct) updateFn) =>
      respuestaTamizaje[index] = updateFn(respuestaTamizaje[index]);

  // CDI / Beck
  List<AtributosStruct> respuestaCDI = [];
  void addToRespuestaCDI(AtributosStruct item) => respuestaCDI.add(item);
  void removeFromRespuestaCDI(AtributosStruct item) =>
      respuestaCDI.remove(item);
  void removeAtIndexFromRespuestaCDI(int index) =>
      respuestaCDI.removeAt(index);
  void insertAtIndexInRespuestaCDI(int index, AtributosStruct item) =>
      respuestaCDI.insert(index, item);
  void updateRespuestaCDIAtIndex(
          int index, Function(AtributosStruct) updateFn) =>
      respuestaCDI[index] = updateFn(respuestaCDI[index]);

  List<AlertaStruct> listaAlertas = [];
  void addToListaAlertas(AlertaStruct item) => listaAlertas.add(item);
  void removeFromListaAlertas(AlertaStruct item) => listaAlertas.remove(item);
  void removeAtIndexFromListaAlertas(int index) => listaAlertas.removeAt(index);

  List<AlertaEspecialStruct> alertasEspeciales = [];
  void addToAlertasEspeciales(AlertaEspecialStruct item) => alertasEspeciales.add(item);
  void removeFromAlertasEspeciales(AlertaEspecialStruct item) => alertasEspeciales.remove(item);
  void removeAtIndexFromAlertasEspeciales(int index) => alertasEspeciales.removeAt(index);

  List<ValorCondicionanteStruct> respuestaCondicionante = [];
  List<ValorCondicionanteStruct> get listaCondicionante => respuestaCondicionante;
  set listaCondicionante(List<ValorCondicionanteStruct> val) =>
      respuestaCondicionante = val;

  void addToRespuestaCondicionante(ValorCondicionanteStruct item) =>
      respuestaCondicionante.add(item);
  void addToListaCondicionante(ValorCondicionanteStruct item) =>
      addToRespuestaCondicionante(item);

  void removeFromRespuestaCondicionante(ValorCondicionanteStruct item) =>
      respuestaCondicionante.remove(item);
  void removeFromListaCondicionante(ValorCondicionanteStruct item) =>
      removeFromRespuestaCondicionante(item);

  void removeAtIndexFromRespuestaCondicionante(int index) =>
      respuestaCondicionante.removeAt(index);
  void removeAtIndexFromListaCondicionante(int index) =>
      removeAtIndexFromRespuestaCondicionante(index);

  void insertAtIndexInRespuestaCondicionante(
          int index, ValorCondicionanteStruct item) =>
      respuestaCondicionante.insert(index, item);
  void updateRespuestaCondicionanteAtIndex(
          int index, Function(ValorCondicionanteStruct) updateFn) =>
      respuestaCondicionante[index] = updateFn(respuestaCondicionante[index]);

  List<PreguntasEncuestaStruct> preguntas = [];
  void addToPreguntas(PreguntasEncuestaStruct item) => preguntas.add(item);
  void removeFromPreguntas(PreguntasEncuestaStruct item) => preguntas.remove(item);
  void removeAtIndexFromPreguntas(int index) => preguntas.removeAt(index);

  String? variableCDI;
  bool? ideacionSuicidaValue;
  String? variableCDIValue;

  ///  State fields for stateful widgets in this component.

  // Datos principales
  FocusNode? textFieldFocusNode;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;

  FocusNode? descFocusNode;
  TextEditingController? descTextController;
  String? Function(BuildContext, String?)? descTextControllerValidator;

  // Categoría
  String? categoriaValue;
  FormFieldController<String>? categoriaValueController;

  // Pregunta
  FocusNode? preguntaFocusNode;
  TextEditingController? preguntaTextController;
  String? Function(BuildContext, String?)? preguntaTextControllerValidator;

  // Tipo
  String? tipoValue;
  FormFieldController<String>? tipoValueController;

  // Sustancia
  String? dropDownSustanciaValue;
  FormFieldController<String>? dropDownSustanciaValueController;

  // Ocultar respuesta
  bool? ocultarRespuestaValue;

  // Abierta / Descriptiva
  FocusNode? abiertaFocusNode;
  TextEditingController? abiertaTextController;
  String? Function(BuildContext, String?)? abiertaTextControllerValidator;

  // Selección
  FocusNode? selection1FocusNode2;
  TextEditingController? selection1TextController2;
  String? Function(BuildContext, String?)? selection1TextController2Validator;

  // Selección única
  FocusNode? selectionunica1FocusNode;
  TextEditingController? selectionunica1TextController;
  String? Function(BuildContext, String?)?
      selectionunica1TextControllerValidator;
  FormFieldController<String>? sunicarespValueController;

  // Tamizaje base (etiqueta + puntaje)
  FocusNode? selection1FocusNode1;
  TextEditingController? selection1TextController1;
  String? Function(BuildContext, String?)? selection1TextController1Validator;

  FocusNode? selectionPuntajeFocusNode;
  TextEditingController? selectionPuntajeTextController;
  String? Function(BuildContext, String?)?
      selectionPuntajeTextControllerValidator;

  // Autoestima (mismo esquema, controladores independientes)
  FocusNode? autoestimaEtiquetaFocusNode;
  TextEditingController? autoestimaEtiquetaTextController;
  FocusNode? autoestimaValorFocusNode;
  TextEditingController? autoestimaValorTextController;

  // CDI / Depresion Beck
  FormFieldController<String>? variableCDIValueController;
  FocusNode? cdiFocusNode;
  TextEditingController? cdiTextController;
  FocusNode? cdiValorFocusNode;
  TextEditingController? cdiValorTextController;

  // CRQ / SRQ
  FocusNode? crqNumeroPreguntaFocusNode;
  TextEditingController? crqNumeroPreguntaTextController;
  FocusNode? crqSiScoreFocusNode;
  TextEditingController? crqSiScoreTextController;
  FocusNode? crqNoScoreFocusNode;
  TextEditingController? crqNoScoreTextController;

  // Condicionante
  FocusNode? selection1CondicionFocusNode;
  TextEditingController? selection1CondicionTextController;
  String? Function(BuildContext, String?)?
      selection1CondicionTextControllerValidator;
  String? dropDownSustanciaCondicionanValue;
  FormFieldController<String>? dropDownSustanciaCondicionanValueController;

  // Alerta especial nombre
  FocusNode? alertaEspecialNombreFocusNode;
  TextEditingController? alertaEspecialNombreTextController;
  String? Function(BuildContext, String?)? alertaEspecialNombreTextControllerValidator;
  // Alerta especial condicion
  String? alertaEspecialCondicionValue;
  FormFieldController<String>? alertaEspecialCondicionValueController;
  // Alerta especial preguntas
  FocusNode? alertaEspecialPreguntasFocusNode;
  TextEditingController? alertaEspecialPreguntasTextController;
  String? Function(BuildContext, String?)? alertaEspecialPreguntasTextControllerValidator;
  // Alerta especial puntaje
  FocusNode? alertaEspecialPuntajeFocusNode;
  TextEditingController? alertaEspecialPuntajeTextController;
  String? Function(BuildContext, String?)? alertaEspecialPuntajeTextControllerValidator;

  // Verdadero o falso
  bool? checkboxValue5;
  bool? checkboxValue6;
  bool? get checkboxValue9 => checkboxValue5;
  set checkboxValue9(bool? val) => checkboxValue5 = val;
  bool? get checkboxValue10 => checkboxValue6;
  set checkboxValue10(bool? val) => checkboxValue6 = val;

  // Checkbox maps and lists
  Map<String, bool> checkboxValueMap2 = {};
  List<String> get checkboxCheckedItems2 => checkboxValueMap2.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<ValorCondicionanteStruct, bool> checkboxValueMap6 = {};
  List<ValorCondicionanteStruct> get checkboxCheckedItems6 => checkboxValueMap6.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<AtributosStruct, bool> checkboxValueMap8 = {};
  List<AtributosStruct> get checkboxCheckedItems8 => checkboxValueMap8.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<ValorCondicionanteStruct, bool> checkboxValueMap11 = {};
  List<ValorCondicionanteStruct> get checkboxCheckedItems11 => checkboxValueMap11.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<String, bool> checkboxValueMap12 = {};
  List<String> get checkboxCheckedItems12 => checkboxValueMap12.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<AtributosStruct, bool> checkboxValueMap13 = {};
  List<AtributosStruct> get checkboxCheckedItems13 => checkboxValueMap13.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<PreguntasEncuestaStruct, bool> checkboxValueMap14 = {};
  List<PreguntasEncuestaStruct> get checkboxCheckedItems14 => checkboxValueMap14.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<PreguntasEncuestaStruct, bool> checkboxValueMap15 = {};
  List<PreguntasEncuestaStruct> get checkboxCheckedItems15 => checkboxValueMap15.entries.where((e) => e.value).map((e) => e.key).toList();
  Map<PreguntasEncuestaStruct, bool> checkboxNPValueMap2 = {};
  List<PreguntasEncuestaStruct> get checkboxNPCheckedItems2 => checkboxNPValueMap2.entries.where((e) => e.value).map((e) => e.key).toList();

  // Dynamic models
  late FlutterFlowDynamicModels<TextFieltaamizajeModel> textFieltaamizajeModels1;
  late FlutterFlowDynamicModels<TextFieltaamizajeModel> textFieltaamizajeModels2;
  late FlutterFlowDynamicModels<SeleccionUnicaModel> seleccionUnicaModels;

  // Obligatorio
  bool? checkboxNPValue1;

  // Roles
  List<String>? roleValue;
  FormFieldController<List<String>>? roleValueController;

  // Alertas sustancias (panel derecho)
  String? dropDownSustancia2Value;
  FormFieldController<String>? dropDownSustancia2ValueController;

  @override
  void initState(BuildContext context) {
    textFieltaamizajeModels1 =
        FlutterFlowDynamicModels(() => TextFieltaamizajeModel());
    textFieltaamizajeModels2 =
        FlutterFlowDynamicModels(() => TextFieltaamizajeModel());
    seleccionUnicaModels =
        FlutterFlowDynamicModels(() => SeleccionUnicaModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController1?.dispose();
    descFocusNode?.dispose();
    descTextController?.dispose();
    preguntaFocusNode?.dispose();
    preguntaTextController?.dispose();
    abiertaFocusNode?.dispose();
    abiertaTextController?.dispose();
    selection1FocusNode2?.dispose();
    selection1TextController2?.dispose();
    selectionunica1FocusNode?.dispose();
    selectionunica1TextController?.dispose();
    selection1FocusNode1?.dispose();
    selection1TextController1?.dispose();
    selectionPuntajeFocusNode?.dispose();
    selectionPuntajeTextController?.dispose();
    autoestimaEtiquetaFocusNode?.dispose();
    autoestimaEtiquetaTextController?.dispose();
    autoestimaValorFocusNode?.dispose();
    autoestimaValorTextController?.dispose();
    cdiFocusNode?.dispose();
    cdiTextController?.dispose();
    cdiValorFocusNode?.dispose();
    cdiValorTextController?.dispose();
    crqNumeroPreguntaFocusNode?.dispose();
    crqNumeroPreguntaTextController?.dispose();
    crqSiScoreFocusNode?.dispose();
    crqSiScoreTextController?.dispose();
    crqNoScoreFocusNode?.dispose();
    crqNoScoreTextController?.dispose();
    selection1CondicionFocusNode?.dispose();
    selection1CondicionTextController?.dispose();

    alertaEspecialNombreFocusNode?.dispose();
    alertaEspecialNombreTextController?.dispose();
    alertaEspecialPreguntasFocusNode?.dispose();
    alertaEspecialPreguntasTextController?.dispose();
    alertaEspecialPuntajeFocusNode?.dispose();
    alertaEspecialPuntajeTextController?.dispose();

    textFieltaamizajeModels1.dispose();
    textFieltaamizajeModels2.dispose();
    seleccionUnicaModels.dispose();
  }

  /// Additional helper methods.
  String? get sunicarespValue => sunicarespValueController?.value;
}
