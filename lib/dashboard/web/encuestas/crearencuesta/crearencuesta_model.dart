import '/backend/backend.dart';
import '/components/seleccion_unica_widget.dart';
import '/components/text_fieltaamizaje_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'crearencuesta_widget.dart' show CrearencuestaWidget;
import 'package:flutter/material.dart';

class CrearencuestaModel extends FlutterFlowModel<CrearencuestaWidget> {
  ///  Local state fields for this component.

  List<String> respuestaSelection = [];
  void addToRespuestaSelection(String item) => respuestaSelection.add(item);
  void removeFromRespuestaSelection(String item) =>
      respuestaSelection.remove(item);
  void removeAtIndexFromRespuestaSelection(int index) =>
      respuestaSelection.removeAt(index);
  void insertAtIndexInRespuestaSelection(int index, String item) =>
      respuestaSelection.insert(index, item);
  void updateRespuestaSelectionAtIndex(int index, Function(String) updateFn) =>
      respuestaSelection[index] = updateFn(respuestaSelection[index]);

  List<String> seleccionunica = [];
  void addToSeleccionunica(String item) => seleccionunica.add(item);
  void removeFromSeleccionunica(String item) => seleccionunica.remove(item);
  void removeAtIndexFromSeleccionunica(int index) =>
      seleccionunica.removeAt(index);
  void insertAtIndexInSeleccionunica(int index, String item) =>
      seleccionunica.insert(index, item);
  void updateSeleccionunicaAtIndex(int index, Function(String) updateFn) =>
      seleccionunica[index] = updateFn(seleccionunica[index]);

  String? seleccionunicarespuesta;

  List<AtributosStruct> respuestaTamizaje = [];
  void addToRespuestaTamizaje(AtributosStruct item) =>
      respuestaTamizaje.add(item);
  void removeFromRespuestaTamizaje(AtributosStruct item) =>
      respuestaTamizaje.remove(item);
  void removeAtIndexFromRespuestaTamizaje(int index) =>
      respuestaTamizaje.removeAt(index);
  void insertAtIndexInRespuestaTamizaje(int index, AtributosStruct item) =>
      respuestaTamizaje.insert(index, item);
  void updateRespuestaTamizajeAtIndex(
          int index, Function(AtributosStruct) updateFn) =>
      respuestaTamizaje[index] = updateFn(respuestaTamizaje[index]);

  List<ValorCondicionanteStruct> respuestaCondicionante = [];
  void addToRespuestaCondicionante(ValorCondicionanteStruct item) =>
      respuestaCondicionante.add(item);
  void removeFromRespuestaCondicionante(ValorCondicionanteStruct item) =>
      respuestaCondicionante.remove(item);
  void removeAtIndexFromRespuestaCondicionante(int index) =>
      respuestaCondicionante.removeAt(index);
  void insertAtIndexInRespuestaCondicionante(
          int index, ValorCondicionanteStruct item) =>
      respuestaCondicionante.insert(index, item);
  void updateRespuestaCondicionanteAtIndex(
          int index, Function(ValorCondicionanteStruct) updateFn) =>
      respuestaCondicionante[index] = updateFn(respuestaCondicionante[index]);

  List<String> tipospreguntas = [
    'Tamizaje (Sustancias)',
    'Condicionante',
    'Abierta',
    'Tamizaje autoestima',
    'Tamizaje ansiedad',
    'Descriptiva',
    'Tamizaje CDI',
    'Tamizajes Depresion Beck',
    'Selección única',
    'Selección',
    'Verdadero o falso',
    'Tamizaje CRQ',
    'Tamizaje SRQ',
    'Tamizaje RQC',
    'Tamizaje CRQ / SRQ',
    'Tamizaje RQC / SRQ'
  ];
  void addToTipospreguntas(String item) => tipospreguntas.add(item);
  void removeFromTipospreguntas(String item) => tipospreguntas.remove(item);
  void removeAtIndexFromTipospreguntas(int index) =>
      tipospreguntas.removeAt(index);
  void insertAtIndexInTipospreguntas(int index, String item) =>
      tipospreguntas.insert(index, item);
  void updateTipospreguntasAtIndex(int index, Function(String) updateFn) =>
      tipospreguntas[index] = updateFn(tipospreguntas[index]);

  String? categoria;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for categoria widget.
  String? categoriaValue;
  FormFieldController<String>? categoriaValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for Pregunta widget.
  FocusNode? preguntaFocusNode1;
  TextEditingController? preguntaTextController1;
  String? Function(BuildContext, String?)? preguntaTextController1Validator;
  // State field(s) for tipo widget.
  String? tipoValue;
  FormFieldController<String>? tipoValueController;
  // State field(s) for Pregunta widget.
  FocusNode? preguntaFocusNode2;
  TextEditingController? preguntaTextController2;
  String? Function(BuildContext, String?)? preguntaTextController2Validator;
  // State field(s) for DropDownSustancia widget.
  String? dropDownSustanciaValue;
  FormFieldController<String>? dropDownSustanciaValueController;
  // State field(s) for OcultarRespuesta widget.
  bool? ocultarRespuestaValue;
  // State field(s) for abierta widget.
  FocusNode? abiertaFocusNode;
  TextEditingController? abiertaTextController;
  String? Function(BuildContext, String?)? abiertaTextControllerValidator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for selection1 widget.
  FocusNode? selection1FocusNode1;
  TextEditingController? selection1TextController1;
  String? Function(BuildContext, String?)? selection1TextController1Validator;
  // State field(s) for Checkbox widget.
  Map<String, bool> checkboxValueMap2 = {};
  List<String> get checkboxCheckedItems2 => checkboxValueMap2.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // State field(s) for selection1 widget.
  FocusNode? selection1FocusNode2;
  TextEditingController? selection1TextController2;
  String? Function(BuildContext, String?)? selection1TextController2Validator;
  // State field(s) for DropDownSustanciaCondicionan widget.
  String? dropDownSustanciaCondicionanValue;
  FormFieldController<String>? dropDownSustanciaCondicionanValueController;
  // State field(s) for Checkbox widget.
  bool? checkboxValue4;
  // State field(s) for Checkbox widget.
  bool? checkboxValue5;
  // State field(s) for Checkbox widget.
  Map<ValorCondicionanteStruct, bool> checkboxValueMap6 = {};
  List<ValorCondicionanteStruct> get checkboxCheckedItems6 =>
      checkboxValueMap6.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  // Models for TextFieltaamizaje dynamic component.
  late FlutterFlowDynamicModels<TextFieltaamizajeModel>
      textFieltaamizajeModels1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue7;
  // State field(s) for selection1 widget.
  FocusNode? selection1FocusNode3;
  TextEditingController? selection1TextController3;
  String? Function(BuildContext, String?)? selection1TextController3Validator;
  // State field(s) for valor1 widget.
  FocusNode? valor1FocusNode;
  TextEditingController? valor1TextController;
  String? Function(BuildContext, String?)? valor1TextControllerValidator;
  // State field(s) for Checkbox widget.
  Map<AtributosStruct, bool> checkboxValueMap8 = {};
  List<AtributosStruct> get checkboxCheckedItems8 => checkboxValueMap8.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  // Models for TextFieltaamizaje dynamic component.
  late FlutterFlowDynamicModels<TextFieltaamizajeModel>
      textFieltaamizajeModels2;
  // State field(s) for selectionunica1 widget.
  FocusNode? selectionunica1FocusNode;
  TextEditingController? selectionunica1TextController;
  String? Function(BuildContext, String?)?
      selectionunica1TextControllerValidator;
  // State field(s) for sunicaresp widget.
  FormFieldController<String>? sunicarespValueController;
  // State field(s) for Checkbox widget.
  bool? checkboxValue9;
  // State field(s) for Checkbox widget.
  bool? checkboxValue10;
  // State field(s) for CheckboxNP widget.
  bool? checkboxNPValue1;
  // State field(s) for Checkbox widget.
  Map<ValorCondicionanteStruct, bool> checkboxValueMap11 = {};
  List<ValorCondicionanteStruct> get checkboxCheckedItems11 =>
      checkboxValueMap11.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  // State field(s) for Checkbox widget.
  Map<String, bool> checkboxValueMap12 = {};
  List<String> get checkboxCheckedItems12 => checkboxValueMap12.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  // State field(s) for Checkbox widget.
  Map<AtributosStruct, bool> checkboxValueMap13 = {};
  List<AtributosStruct> get checkboxCheckedItems13 => checkboxValueMap13.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  // Models for SeleccionUnica dynamic component.
  late FlutterFlowDynamicModels<SeleccionUnicaModel> seleccionUnicaModels;
  // State field(s) for Checkbox widget.
  Map<PreguntasEncuestaStruct, bool> checkboxValueMap14 = {};
  List<PreguntasEncuestaStruct> get checkboxCheckedItems14 =>
      checkboxValueMap14.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  // State field(s) for Checkbox widget.
  Map<PreguntasEncuestaStruct, bool> checkboxValueMap15 = {};
  List<PreguntasEncuestaStruct> get checkboxCheckedItems15 =>
      checkboxValueMap15.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  // State field(s) for CheckboxNP widget.
  Map<PreguntasEncuestaStruct, bool> checkboxNPValueMap2 = {};
  List<PreguntasEncuestaStruct> get checkboxNPCheckedItems2 =>
      checkboxNPValueMap2.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

  // State field(s) for role widget.
  List<String>? roleValue;
  FormFieldController<List<String>>? roleValueController;
  // State field(s) for DropDownSustancia2 widget.
  String? dropDownSustancia2Value;
  FormFieldController<String>? dropDownSustancia2ValueController;

  // Variable para preguntas CDI/Beck
  String? variableCDI;

  // Lista de opciones CDI/Beck con ideacion suicida
  List<AtributosStruct> respuestaCDI = [];
  void addToRespuestaCDI(AtributosStruct item) => respuestaCDI.add(item);
  void removeFromRespuestaCDI(AtributosStruct item) =>
      respuestaCDI.remove(item);
  void removeAtIndexFromRespuestaCDI(int index) => respuestaCDI.removeAt(index);
  void insertAtIndexInRespuestaCDI(int index, AtributosStruct item) =>
      respuestaCDI.insert(index, item);
  void updateRespuestaCDIAtIndex(
          int index, Function(AtributosStruct) updateFn) =>
      respuestaCDI[index] = updateFn(respuestaCDI[index]);

  // Lista de alertas especiales CRQ/SRQ
  List<AlertaEspecialStruct> alertasEspeciales = [];
  void addToAlertasEspeciales(AlertaEspecialStruct item) =>
      alertasEspeciales.add(item);
  void removeFromAlertasEspeciales(AlertaEspecialStruct item) =>
      alertasEspeciales.remove(item);
  void removeAtIndexFromAlertasEspeciales(int index) =>
      alertasEspeciales.removeAt(index);

  // Buffer local de preguntas en modo creación. Se persiste a Firestore al
  // presionar Vista Previa / Guardar borrador / Publicar.
  List<PreguntasEncuestaStruct> preguntasBuffer = [];
  void addToPreguntasBuffer(PreguntasEncuestaStruct item) =>
      preguntasBuffer.add(item);
  void removeAtIndexFromPreguntasBuffer(int index) =>
      preguntasBuffer.removeAt(index);

  // Referencia al doc ya persistido. Null mientras el usuario no haya
  // presionado ningún botón de acción (creación pura en memoria).
  DocumentReference? encuestaPersistedRef;

  // Umbrales clínicos configurables por categoría (Autoestima/CDI: 3 niveles;
  // Beck: 4 niveles). Se inicializan con defaults cuando el usuario elige
  // categoría y se pueden editar en el sidebar.
  List<AlertaStruct> nivelesAlerta = [];

  /// Rellena [nivelesAlerta] con los defaults clínicos estándar para la
  /// categoría dada. No hace nada si la categoría no tiene niveles
  /// configurables (Sustancias/CRQ tienen su propia UI).
  void seedNivelesAlerta(String? categoria) {
    switch (categoria) {
      case 'Escala autoestima':
        // Labels deben coincidir con kNivelesPorCategoria en
        // tamizajes_niveles.dart para que calcularNivelAlerta matchee.
        nivelesAlerta = [
          AlertaStruct(nivel: 'Autoestima Baja', min: 0, max: 25),
          AlertaStruct(nivel: 'Autoestima Media', min: 26, max: 29),
          AlertaStruct(nivel: 'Autoestima Elevada', min: 30, max: 999),
        ];
        break;
      case 'Escala ansiedad':
        nivelesAlerta = [
          AlertaStruct(nivel: 'Sin sintomatología', min: 0, max: 7),
          AlertaStruct(nivel: 'Leve', min: 8, max: 15),
          AlertaStruct(nivel: 'Moderado', min: 16, max: 25),
          AlertaStruct(nivel: 'Severo', min: 26, max: 999),
        ];
        break;
      case 'CDI':
        nivelesAlerta = [
          AlertaStruct(nivel: 'Sin sintomatología', min: 0, max: 6),
          AlertaStruct(nivel: 'Leve', min: 7, max: 19),
          AlertaStruct(nivel: 'Severo', min: 20, max: 999),
        ];
        break;
      case 'Depresión Beck':
        nivelesAlerta = [
          AlertaStruct(nivel: 'Mínima', min: 0, max: 13),
          AlertaStruct(nivel: 'Leve', min: 14, max: 19),
          AlertaStruct(nivel: 'Moderada', min: 20, max: 28),
          AlertaStruct(nivel: 'Grave', min: 29, max: 999),
        ];
        break;
      case 'CRQ / SRQ':
      case 'RQC / SRQ':
        nivelesAlerta = [
          AlertaStruct(nivel: 'Sin alerta', min: 0, max: 0),
          AlertaStruct(nivel: 'Moderada', min: 1, max: 2),
          AlertaStruct(nivel: 'Severo', min: 3, max: 999),
        ];
        break;
      case 'RQC':
      case 'CRQ':
      case 'SRQ':
        nivelesAlerta = [
          AlertaStruct(nivel: 'Sin alerta', min: 0, max: 0),
          AlertaStruct(nivel: 'Subescala 1', min: 1, max: 2),
          AlertaStruct(nivel: 'Subescala 2', min: 3, max: 999),
        ];
        break;
      default:
        nivelesAlerta = [];
    }
  }

  // CDI/Beck variable dropdown
  String? variableCDIValue;
  FormFieldController<String>? variableCDIValueController;
  // CDI/Beck ideacion suicida checkbox
  bool? ideacionSuicidaValue;
  // CDI/Beck etiqueta text field
  FocusNode? cdiFocusNode;
  TextEditingController? cdiTextController;
  String? Function(BuildContext, String?)? cdiTextControllerValidator;
  // CDI/Beck valor text field
  FocusNode? cdiValorFocusNode;
  TextEditingController? cdiValorTextController;
  String? Function(BuildContext, String?)? cdiValorTextControllerValidator;
  // CRQ numero pregunta
  FocusNode? crqNumeroPreguntaFocusNode;
  TextEditingController? crqNumeroPreguntaTextController;
  String? Function(BuildContext, String?)?
      crqNumeroPreguntaTextControllerValidator;
  // CRQ SI score
  FocusNode? crqSiScoreFocusNode;
  TextEditingController? crqSiScoreTextController;
  String? Function(BuildContext, String?)? crqSiScoreTextControllerValidator;
  // CRQ NO score
  FocusNode? crqNoScoreFocusNode;
  TextEditingController? crqNoScoreTextController;
  String? Function(BuildContext, String?)? crqNoScoreTextControllerValidator;
  // Alerta especial nombre
  FocusNode? alertaEspecialNombreFocusNode;
  TextEditingController? alertaEspecialNombreTextController;
  String? Function(BuildContext, String?)?
      alertaEspecialNombreTextControllerValidator;
  // Alerta especial condicion
  String? alertaEspecialCondicionValue;
  FormFieldController<String>? alertaEspecialCondicionValueController;
  // Alerta especial preguntas
  FocusNode? alertaEspecialPreguntasFocusNode;
  TextEditingController? alertaEspecialPreguntasTextController;
  String? Function(BuildContext, String?)?
      alertaEspecialPreguntasTextControllerValidator;
  // Alerta especial puntaje
  FocusNode? alertaEspecialPuntajeFocusNode;
  TextEditingController? alertaEspecialPuntajeTextController;
  String? Function(BuildContext, String?)?
      alertaEspecialPuntajeTextControllerValidator;
  // Autoestima etiqueta
  FocusNode? autoestimaEtiquetaFocusNode;
  TextEditingController? autoestimaEtiquetaTextController;
  String? Function(BuildContext, String?)?
      autoestimaEtiquetaTextControllerValidator;
  // Autoestima valor
  FocusNode? autoestimaValorFocusNode;
  TextEditingController? autoestimaValorTextController;
  String? Function(BuildContext, String?)?
      autoestimaValorTextControllerValidator;

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
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    preguntaFocusNode1?.dispose();
    preguntaTextController1?.dispose();

    preguntaFocusNode2?.dispose();
    preguntaTextController2?.dispose();

    abiertaFocusNode?.dispose();
    abiertaTextController?.dispose();

    selection1FocusNode1?.dispose();
    selection1TextController1?.dispose();

    selection1FocusNode2?.dispose();
    selection1TextController2?.dispose();

    textFieltaamizajeModels1.dispose();
    selection1FocusNode3?.dispose();
    selection1TextController3?.dispose();

    valor1FocusNode?.dispose();
    valor1TextController?.dispose();

    textFieltaamizajeModels2.dispose();
    selectionunica1FocusNode?.dispose();
    selectionunica1TextController?.dispose();

    seleccionUnicaModels.dispose();

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
    alertaEspecialNombreFocusNode?.dispose();
    alertaEspecialNombreTextController?.dispose();
    alertaEspecialPreguntasFocusNode?.dispose();
    alertaEspecialPreguntasTextController?.dispose();
    alertaEspecialPuntajeFocusNode?.dispose();
    alertaEspecialPuntajeTextController?.dispose();
    autoestimaEtiquetaFocusNode?.dispose();
    autoestimaEtiquetaTextController?.dispose();
    autoestimaValorFocusNode?.dispose();
    autoestimaValorTextController?.dispose();
  }

  /// Additional helper methods.
  String? get sunicarespValue => sunicarespValueController?.value;
}
