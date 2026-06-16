// Model state holder for the refactored EditarEncuestaWidget.
// Keeps all text controllers, focus nodes, form field controllers and
// the transient lists used while composing a new question inside the
// edit panel. The model is intentionally verbose so every form widget
// under `forms/` can operate on a shared, well-typed container.

import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/flutter_flow/form_field_controller.dart';

class EditarEncuestaModel {
  // ── Encabezado encuesta ──────────────────────────────────────────────────
  final TextEditingController tituloController = TextEditingController();
  final FocusNode tituloFocus = FocusNode();

  final TextEditingController descripcionController = TextEditingController();
  final FocusNode descripcionFocus = FocusNode();

  String? categoriaValue;
  FormFieldController<String>? categoriaValueController;

  List<String> rolesValue = [];
  FormFieldController<List<String>>? rolesValueController;

  // ── Nueva pregunta (campos comunes) ──────────────────────────────────────
  final TextEditingController preguntaController = TextEditingController();
  final FocusNode preguntaFocus = FocusNode();

  String? tipoValue;
  FormFieldController<String>? tipoValueController;

  bool obligatorio = false;
  bool ocultarRespuestaValue = false;

  // ── Tipo: abierta / descriptiva ──────────────────────────────────────────
  final TextEditingController abiertaController = TextEditingController();
  final FocusNode abiertaFocus = FocusNode();

  // ── Tipo: selección ──────────────────────────────────────────────────────
  final TextEditingController seleccionOpcionController = TextEditingController();
  final FocusNode seleccionOpcionFocus = FocusNode();
  List<String> respuestaSelection = [];

  // ── Tipo: selección única ────────────────────────────────────────────────
  final TextEditingController seleccionUnicaController = TextEditingController();
  final FocusNode seleccionUnicaFocus = FocusNode();
  List<String> seleccionUnica = [];
  String? seleccionUnicaCorrectaValue;
  FormFieldController<String>? seleccionUnicaCorrectaController;

  // ── Tipo: verdadero / falso ──────────────────────────────────────────────
  bool vfVerdadero = false;
  bool vfFalso = false;

  // ── Tipo: condicionante ──────────────────────────────────────────────────
  final TextEditingController condicionanteEtiquetaController =
      TextEditingController();
  final FocusNode condicionanteEtiquetaFocus = FocusNode();
  String? condicionanteSustanciaValue;
  FormFieldController<String>? condicionanteSustanciaController;
  List<ValorCondicionanteStruct> respuestaCondicionante = [];

  // ── Tipo: tamizaje / autoestima / sustancias ─────────────────────────────
  final TextEditingController tamizajeEtiquetaController =
      TextEditingController();
  final FocusNode tamizajeEtiquetaFocus = FocusNode();
  final TextEditingController tamizajeValorController = TextEditingController();
  final FocusNode tamizajeValorFocus = FocusNode();
  List<AtributosStruct> respuestaTamizaje = [];

  // ── Tipo: tamizaje sustancias ────────────────────────────────────────────
  String? sustanciaValue;
  FormFieldController<String>? sustanciaController;
  // Sidebar (panel de alertas) selecciona una sustancia a editar:
  String? sustanciaAlertasValue;
  FormFieldController<String>? sustanciaAlertasController;

  // ── Tipo: Tamizaje CDI / Beck ────────────────────────────────────────────
  String? variableCDIValue;
  FormFieldController<String>? variableCDIController;
  final TextEditingController cdiEtiquetaController = TextEditingController();
  final FocusNode cdiEtiquetaFocus = FocusNode();
  final TextEditingController cdiValorController = TextEditingController();
  final FocusNode cdiValorFocus = FocusNode();
  bool ideacionSuicidaValue = false;
  List<AtributosStruct> respuestaCDI = [];

  // ── Tipo: Tamizaje CRQ / SRQ ─────────────────────────────────────────────
  final TextEditingController crqNumeroPreguntaController =
      TextEditingController();
  final FocusNode crqNumeroPreguntaFocus = FocusNode();
  final TextEditingController crqSiScoreController = TextEditingController();
  final FocusNode crqSiScoreFocus = FocusNode();
  final TextEditingController crqNoScoreController = TextEditingController();
  final FocusNode crqNoScoreFocus = FocusNode();

  // ── Alertas especiales (sidebar) ─────────────────────────────────────────
  final TextEditingController alertaEspecialNombreController =
      TextEditingController();
  final FocusNode alertaEspecialNombreFocus = FocusNode();
  String? alertaEspecialCondicionValue;
  FormFieldController<String>? alertaEspecialCondicionController;
  final TextEditingController alertaEspecialPuntajeController =
      TextEditingController();
  final FocusNode alertaEspecialPuntajeFocus = FocusNode();
  final TextEditingController alertaEspecialPreguntasController =
      TextEditingController();
  final FocusNode alertaEspecialPreguntasFocus = FocusNode();

  // ── Helpers list operations ──────────────────────────────────────────────
  void addToRespuestaSelection(String item) => respuestaSelection.add(item);
  void removeFromRespuestaSelection(String item) =>
      respuestaSelection.remove(item);

  void addToSeleccionUnica(String item) => seleccionUnica.add(item);
  void removeFromSeleccionUnica(String item) => seleccionUnica.remove(item);

  void addToRespuestaCondicionante(ValorCondicionanteStruct item) =>
      respuestaCondicionante.add(item);
  void removeFromRespuestaCondicionante(ValorCondicionanteStruct item) =>
      respuestaCondicionante.remove(item);

  void addToRespuestaTamizaje(AtributosStruct item) =>
      respuestaTamizaje.add(item);
  void removeAtIndexFromRespuestaTamizaje(int index) =>
      respuestaTamizaje.removeAt(index);

  void addToRespuestaCDI(AtributosStruct item) => respuestaCDI.add(item);
  void removeAtIndexFromRespuestaCDI(int index) => respuestaCDI.removeAt(index);

  /// Initialize controllers from an existing record (used by the widget in
  /// initState the first time the stream returns a doc).
  void loadFromRecord(EncuestasRecord doc) {
    tituloController.text = doc.titulo;
    descripcionController.text = doc.descripcion;
    rolesValue = List<String>.from(doc.roles);
    categoriaValue = doc.categoria;
    categoriaValueController?.value = doc.categoria;
  }

  /// Reset the transient form state after a question is successfully saved.
  void resetNuevaPreguntaForm() {
    preguntaController.clear();
    abiertaController.clear();
    seleccionOpcionController.clear();
    seleccionUnicaController.clear();
    condicionanteEtiquetaController.clear();
    tamizajeEtiquetaController.clear();
    tamizajeValorController.clear();
    cdiEtiquetaController.clear();
    cdiValorController.clear();
    crqNumeroPreguntaController.clear();
    crqSiScoreController.clear();
    crqNoScoreController.clear();

    respuestaSelection = [];
    seleccionUnica = [];
    seleccionUnicaCorrectaValue = null;
    seleccionUnicaCorrectaController?.value = null;

    respuestaCondicionante = [];
    respuestaTamizaje = [];
    respuestaCDI = [];

    vfVerdadero = false;
    vfFalso = false;

    tipoValue = null;
    tipoValueController?.value = null;

    sustanciaValue = null;
    sustanciaController?.value = null;

    condicionanteSustanciaValue = null;
    condicionanteSustanciaController?.value = null;

    variableCDIValue = null;
    variableCDIController?.value = null;

    ideacionSuicidaValue = false;
    ocultarRespuestaValue = false;
    obligatorio = false;
  }

  void dispose() {
    tituloController.dispose();
    tituloFocus.dispose();
    descripcionController.dispose();
    descripcionFocus.dispose();
    preguntaController.dispose();
    preguntaFocus.dispose();
    abiertaController.dispose();
    abiertaFocus.dispose();
    seleccionOpcionController.dispose();
    seleccionOpcionFocus.dispose();
    seleccionUnicaController.dispose();
    seleccionUnicaFocus.dispose();
    condicionanteEtiquetaController.dispose();
    condicionanteEtiquetaFocus.dispose();
    tamizajeEtiquetaController.dispose();
    tamizajeEtiquetaFocus.dispose();
    tamizajeValorController.dispose();
    tamizajeValorFocus.dispose();
    cdiEtiquetaController.dispose();
    cdiEtiquetaFocus.dispose();
    cdiValorController.dispose();
    cdiValorFocus.dispose();
    crqNumeroPreguntaController.dispose();
    crqNumeroPreguntaFocus.dispose();
    crqSiScoreController.dispose();
    crqSiScoreFocus.dispose();
    crqNoScoreController.dispose();
    crqNoScoreFocus.dispose();
    alertaEspecialNombreController.dispose();
    alertaEspecialNombreFocus.dispose();
    alertaEspecialPuntajeController.dispose();
    alertaEspecialPuntajeFocus.dispose();
    alertaEspecialPreguntasController.dispose();
    alertaEspecialPreguntasFocus.dispose();
  }

  // ── Firestore helpers ────────────────────────────────────────────────────

  /// Build a PreguntasEncuestaStruct from the current form state for the
  /// selected `tipoValue`, and return the data map ready to be pushed with
  /// FieldValue.arrayUnion on the `Preguntas` field of the encuesta doc.
  Map<String, dynamic> buildNuevaPreguntaFirestoreEntry() {
    final String tipo = tipoValue ?? '';

    List<AtributosStruct> tamizaje;
    switch (tipo) {
      case 'Tamizaje CDI':
      case 'Tamizajes Depresion Beck':
        tamizaje = respuestaCDI;
        break;
      case 'Tamizaje CRQ / SRQ':
      case 'Tamizaje CRQ':
      case 'Tamizaje SRQ':
        tamizaje = [
          AtributosStruct(
            etiqueta: 'Sí',
            valor: int.tryParse(crqSiScoreController.text) ?? 1,
          ),
          AtributosStruct(
            etiqueta: 'No',
            valor: int.tryParse(crqNoScoreController.text) ?? 0,
          ),
        ];
        break;
      default:
        tamizaje = respuestaTamizaje;
    }

    final String? respuestaSUnicaCorrecta = seleccionUnicaCorrectaValue;
    final int? numeroPregunta = (tipo == 'Tamizaje CRQ / SRQ' ||
            tipo == 'Tamizaje CRQ' ||
            tipo == 'Tamizaje SRQ')
        ? int.tryParse(crqNumeroPreguntaController.text)
        : null;
    final String? variable =
        (tipo == 'Tamizaje CDI' || tipo == 'Tamizajes Depresion Beck')
            ? variableCDIValue
            : null;
    final String? sustancia =
        tipo == 'Tamizaje (Sustancias)' ? sustanciaValue : null;

    final nueva = createPreguntasEncuestaStruct(
      pregunta: preguntaController.text,
      tipo: tipo,
      respuestaLarga: abiertaController.text,
      respuestaSUnicaCorrecta: respuestaSUnicaCorrecta,
      sustancia: sustancia,
      ocultarRespuesta: ocultarRespuestaValue,
      variable: variable,
      numeroPregunta: numeroPregunta,
      fieldValues: {
        'RespuestaSelection': respuestaSelection,
        'RespuestasSeleccionUnica': seleccionUnica,
        'RespuestaTamizaje': getAtributosListFirestoreData(tamizaje),
        'RespuestaCondicionante':
            getValorCondicionanteListFirestoreData(respuestaCondicionante),
      },
      clearUnsetFields: false,
    );
    // nPregunta: 1 = obligatoria.
    nueva.nPregunta = obligatorio ? 1 : 0;

    return {
      ...mapToFirestore({
        'Preguntas':
            FieldValue.arrayUnion([getPreguntasEncuestaFirestoreData(nueva, true)]),
      }),
    };
  }
}
