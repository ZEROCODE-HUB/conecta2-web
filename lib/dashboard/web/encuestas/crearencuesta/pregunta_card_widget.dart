import '/tamizajes/shared/assist_utils.dart'
    show canonicaSustancia, esTipoSustancia;
import '/backend/backend.dart';
import '/components/seleccion_unica_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import '../encuesta_form_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Devuelve el color asociado a cada tipo de pregunta.
Color colorForTipo(String tipo) {
  switch (tipo) {
    case 'abiertas':
      return const Color(0xFF2196F3);
    case 'Condicionante':
      return const Color(0xFFFF9800);
    case 'selección':
      return const Color(0xFF9C27B0);
    case 'Tamizaje':
      return const Color(0xFF009688);
    case 'Tamizaje autoestima':
    case 'Tamizaje ansiedad':
      return const Color(0xFFE91E63);
    case 'Tamizaje CDI':
    case 'Tamizajes Depresion Beck':
      return const Color(0xFF3F51B5);
    case 'Tamizaje RQC':
    case 'Tamizaje CRQ':
    case 'Tamizaje SRQ':
    case 'Tamizaje CRQ / SRQ':
    case 'Tamizaje RQC / SRQ':
      return const Color(0xFF4CAF50);
    case 'Selección única':
      return const Color(0xFFFF5722);
    case 'Verdadero o falso':
      return const Color(0xFF00BCD4);
    case 'Descriptiva':
      return const Color(0xFF607D8B);
    case 'Tamizaje (Sustancias)':
      return const Color(0xFF009688);
    default:
      return const Color(0xFF265294);
  }
}

/// Devuelve la etiqueta corta para el badge de tipo.
String labelForTipo(String tipo) {
  switch (tipo) {
    case 'abiertas':
      return 'Abierta';
    case 'Condicionante':
      return 'Condicional';
    case 'selección':
      return 'Selección';
    case 'Tamizaje':
      return 'Tamizaje';
    case 'Tamizaje autoestima':
      return 'Autoestima';
    case 'Tamizaje ansiedad':
      return 'Ansiedad';
    case 'Tamizaje CDI':
      return 'CDI';
    case 'Tamizajes Depresion Beck':
      return 'Beck';
    case 'Tamizaje RQC':
    case 'Tamizaje CRQ':
      return 'RQC';
    case 'Tamizaje CRQ / SRQ':
    case 'Tamizaje RQC / SRQ':
      return 'RQC / SRQ';
    case 'Tamizaje SRQ':
      return 'SRQ';
    case 'Selección única':
      return 'Sel. Única';
    case 'Verdadero o falso':
      return 'V / F';
    case 'Descriptiva':
      return 'Descriptiva';
    case 'Tamizaje (Sustancias)':
      return 'Tamizaje (Sub)';
    default:
      return tipo;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PreguntaCard: tarjeta visual de una pregunta guardada en Firestore
// ─────────────────────────────────────────────────────────────────────────────

class PreguntaCard extends StatefulWidget {
  const PreguntaCard({
    super.key,
    required this.pregunta,
    required this.encuestasRecord,
    required this.index,
    this.categoria,
    this.onDelete,
    this.onEdit,
  });

  final PreguntasEncuestaStruct pregunta;
  final EncuestasRecord encuestasRecord;
  final int index;
  final String? categoria;
  // Cuando se pasa, el botón de eliminar llama a este callback en lugar de
  // persistir `arrayRemove` al doc. Se usa en creación (buffer local).
  final VoidCallback? onDelete;
  final Function(PreguntasEncuestaStruct updatedPregunta)? onEdit;

  @override
  State<PreguntaCard> createState() => _PreguntaCardState();
}

class _PreguntaCardState extends State<PreguntaCard> {
  late SeleccionUnicaModel _seleccionUnicaModel;

  bool _isEditing = false;
  late TextEditingController _preguntaTextController;
  late TextEditingController _respuestaLargaController;
  late TextEditingController _crqNumeroPreguntaController;
  late TextEditingController _crqSiScoreController;
  late TextEditingController _crqNoScoreController;
  late TextEditingController _opcionTextController;
  late TextEditingController _opcionPuntajeController;
  late TextEditingController _condicionanteEtiquetaController;

  FormFieldController<String?>? _tipoValueController;
  FormFieldController<String?>? _sustanciaValueController;
  FormFieldController<String?>? _condicionanteSustanciaController;
  FormFieldController<String?>? _variableValueController;
  List<FormFieldController<String?>> _condicionanteSustanciaControllers = [];

  String? _tipoValue;
  String? _sustanciaValue;
  String? _condicionanteSustanciaValue;
  String? _variableValue;
  String? _seleccionUnicaCorrecta;
  bool _nPreguntaObligatoria = false;
  bool _ocultarRespuesta = false;
  bool _ideacionSuicidaOption = false;

  List<String> _respuestaSelection = [];
  List<String> _respuestasSeleccionUnica = [];
  List<AtributosStruct> _respuestaTamizaje = [];
  List<ValorCondicionanteStruct> _respuestaCondicionante = [];

  @override
  void initState() {
    super.initState();
    _seleccionUnicaModel = createModel(context, () => SeleccionUnicaModel());
    _preguntaTextController = TextEditingController();
    _respuestaLargaController = TextEditingController();
    _crqNumeroPreguntaController = TextEditingController();
    _crqSiScoreController = TextEditingController();
    _crqNoScoreController = TextEditingController();
    _opcionTextController = TextEditingController();
    _opcionPuntajeController = TextEditingController();
    _condicionanteEtiquetaController = TextEditingController();
  }

  @override
  void dispose() {
    _seleccionUnicaModel.dispose();
    _preguntaTextController.dispose();
    _respuestaLargaController.dispose();
    _crqNumeroPreguntaController.dispose();
    _crqSiScoreController.dispose();
    _crqNoScoreController.dispose();
    _opcionTextController.dispose();
    _opcionPuntajeController.dispose();
    _condicionanteEtiquetaController.dispose();
    _tipoValueController?.dispose();
    _sustanciaValueController?.dispose();
    _condicionanteSustanciaController?.dispose();
    _variableValueController?.dispose();
    for (var c in _condicionanteSustanciaControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startEditing() {
    _preguntaTextController.text = widget.pregunta.pregunta;
    _respuestaLargaController.text = widget.pregunta.respuestaLarga;
    _crqNumeroPreguntaController.text = widget.pregunta.numeroPregunta > 0
        ? widget.pregunta.numeroPregunta.toString()
        : '';
    _nPreguntaObligatoria = widget.pregunta.nPregunta == 1;
    _ocultarRespuesta = widget.pregunta.ocultarRespuesta;
    _tipoValue = widget.pregunta.tipo;
    _sustanciaValue = widget.pregunta.sustancia;
    _variableValue = widget.pregunta.variable;
    _seleccionUnicaCorrecta = widget.pregunta.respuestaSUnicaCorrecta;
    _respuestaSelection = List<String>.from(widget.pregunta.respuestaSelection);
    _respuestasSeleccionUnica =
        List<String>.from(widget.pregunta.respuestasSeleccionUnica);
    _respuestaTamizaje =
        List<AtributosStruct>.from(widget.pregunta.respuestaTamizaje);
    _respuestaCondicionante =
        List<ValorCondicionanteStruct>.from(widget.pregunta.respuestaCondicionante);

    for (var c in _condicionanteSustanciaControllers) {
      c.dispose();
    }
    _condicionanteSustanciaControllers = _respuestaCondicionante
        .map((cond) => FormFieldController<String?>(cond.sustanciaValor))
        .toList();

    final esCRQ = _tipoValue == 'Tamizaje CRQ' ||
        _tipoValue == 'Tamizaje RQC' ||
        _tipoValue == 'Tamizaje SRQ' ||
        _tipoValue == 'Tamizaje CRQ / SRQ' ||
        _tipoValue == 'Tamizaje RQC / SRQ';
    if (esCRQ) {
      final siAttr = _respuestaTamizaje.firstWhere(
        (a) => a.etiqueta.toLowerCase() == 'sí' || a.etiqueta.toLowerCase() == 'si',
        orElse: () => AtributosStruct(etiqueta: 'Sí', valor: 1),
      );
      final noAttr = _respuestaTamizaje.firstWhere(
        (a) => a.etiqueta.toLowerCase() == 'no',
        orElse: () => AtributosStruct(etiqueta: 'No', valor: 0),
      );
      _crqSiScoreController.text = siAttr.valor.toString();
      _crqNoScoreController.text = noAttr.valor.toString();
    } else {
      _crqSiScoreController.clear();
      _crqNoScoreController.clear();
    }

    _opcionTextController.clear();
    _opcionPuntajeController.clear();
    _condicionanteEtiquetaController.clear();
    _ideacionSuicidaOption = false;

    _tipoValueController = FormFieldController<String?>(_tipoValue);
    _sustanciaValueController = FormFieldController<String?>(_sustanciaValue);
    _condicionanteSustanciaController = FormFieldController<String?>(null);
    _variableValueController = FormFieldController<String?>(_variableValue);

    setState(() {
      _isEditing = true;
    });
  }

  void _saveChanges() {
    if (_preguntaTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el título de la pregunta.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final esCDIoBeck = _tipoValue == 'Tamizaje CDI' ||
        _tipoValue == 'Tamizajes Depresion Beck';
    final esCRQ = _tipoValue == 'Tamizaje CRQ' ||
        _tipoValue == 'Tamizaje RQC' ||
        _tipoValue == 'Tamizaje SRQ' ||
        _tipoValue == 'Tamizaje CRQ / SRQ' ||
        _tipoValue == 'Tamizaje RQC / SRQ';

    final numPregunta = int.tryParse(_crqNumeroPreguntaController.text.trim()) ?? 0;

    final finalRespuestaTamizaje = esCRQ
        ? [
            AtributosStruct(
              etiqueta: 'Sí',
              valor: int.tryParse(_crqSiScoreController.text.trim()) ?? 1,
            ),
            AtributosStruct(
              etiqueta: 'No',
              valor: int.tryParse(_crqNoScoreController.text.trim()) ?? 0,
            ),
          ]
        : _respuestaTamizaje;

    final updated = createPreguntasEncuestaStruct(
      pregunta: _preguntaTextController.text.trim(),
      tipo: _tipoValue,
      respuestaLarga: _respuestaLargaController.text.trim(),
      respuestaSUnicaCorrecta: _seleccionUnicaCorrecta,
      sustancia: _sustanciaValue,
      ocultarRespuesta: _ocultarRespuesta,
      variable: esCDIoBeck ? _variableValue : (_tipoValue == 'Tamizaje RQC' || _tipoValue == 'Tamizaje SRQ' || _tipoValue == 'Tamizaje CRQ' ? 'CRQ' : widget.pregunta.variable),
      numeroPregunta: esCRQ ? numPregunta : 0,
      nPregunta: _nPreguntaObligatoria ? 1 : 0,
      clearUnsetFields: false,
    );

    updated.respuestaSelection = _respuestaSelection;
    updated.respuestasSeleccionUnica = _respuestasSeleccionUnica;
    updated.respuestaCondicionante = _respuestaCondicionante;
    updated.respuestaTamizaje = finalRespuestaTamizaje;

    if (widget.onEdit != null) {
      widget.onEdit!(updated);
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildEditForm(context);
    }

    final tipo = widget.pregunta.tipo;
    final Color typeColor = colorForTipo(tipo);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border(left: BorderSide(color: typeColor, width: 5.0)),
          boxShadow: const [
            BoxShadow(
                blurRadius: 8.0, color: Color(0x18000000), offset: Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Encabezado ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pregunta.pregunta.isEmpty
                              ? 'Sin pregunta'
                              : widget.pregunta.pregunta,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (widget.pregunta.variable.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            'Variable: ${widget.pregunta.variable}',
                            style: const TextStyle(
                                fontSize: 11.0,
                                color: Color(0xFF9E9E9E),
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildTypeBadge(tipo, typeColor),
                  if (widget.pregunta.nPregunta == 1) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.red.shade300, width: 0.8),
                      ),
                      child: const Text(
                        '* Obligatoria',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Divider(height: 24.0, color: Colors.grey.shade200),
              // ── Contenido por tipo ───────────────────────────────
              _buildPreguntaContent(),
              const SizedBox(height: 12.0),
              // ── Acciones ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.pregunta.nPregunta == 1
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: widget.pregunta.nPregunta == 1
                              ? const Color(0xFF265294)
                              : Colors.grey,
                          size: 18.0,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          'Obligatorio',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () => _startEditing(),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF1976D2),
                        size: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () async {
                      if (widget.onDelete != null) {
                        widget.onDelete!();
                        return;
                      }
                      await widget.encuestasRecord.reference.update({
                        ...mapToFirestore({
                          'Preguntas': FieldValue.arrayRemove([
                            getPreguntasEncuestaFirestoreData(
                              updatePreguntasEncuestaStruct(
                                widget.pregunta,
                                clearUnsetFields: false,
                              ),
                              true,
                            )
                          ]),
                        }),
                      });
                    },
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE53935),
                        size: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Badge de tipo ──────────────────────────────────────────────────────────

  Widget _buildTypeBadge(String tipo, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Text(
        _etiquetaBadge(tipo),
        style: TextStyle(
            color: color, fontSize: 11.0, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// En las preguntas de sustancia (ASSIST) el chip muestra la sustancia
  /// asignada en vez del genérico "Tamizaje (Sub)".
  String _etiquetaBadge(String tipo) {
    final sustancia = widget.pregunta.sustancia.trim();
    if (esTipoSustancia(tipo, sustancia) && sustancia.isNotEmpty) {
      return 'Sustancia: ${canonicaSustancia(sustancia)}';
    }
    return labelForTipo(tipo);
  }

  // ── Dispatcher de contenido ────────────────────────────────────────────────

  Widget _buildPreguntaContent() {
    switch (widget.pregunta.tipo) {
      case 'abiertas':
        return _contentAbiertas();
      case 'Condicionante':
        return _contentCondicionante();
      case 'selección':
        return _contentSeleccion();
      case 'Tamizaje':
      case 'Tamizaje autoestima':
      case 'Tamizaje ansiedad':
      case 'Tamizaje (Sustancias)':
        return _contentTamizajeOpciones();
      case 'Tamizaje CDI':
      case 'Tamizajes Depresion Beck':
        return _contentTamizajeCDI();
      case 'Tamizaje RQC':
      case 'Tamizaje RQC / SRQ':
        return _contentTamizajeCRQ();
      case 'Tamizaje CRQ':
      case 'Tamizaje SRQ':
        return _contentTamizajeCRQ();
      case 'Selección única':
        return _contentSeleccionUnica();
      case 'Verdadero o falso':
        return _contentVerdaderoFalso();
      case 'Descriptiva':
        return _contentDescriptiva();
      default:
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8.0)),
          child: Text('Tipo no reconocido: ${widget.pregunta.tipo}',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12.0)),
        );
    }
  }

  // ── Contenidos por tipo ────────────────────────────────────────────────────

  Widget _contentAbiertas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded,
              color: Colors.grey.shade400, size: 20.0),
          const SizedBox(width: 8.0),
          Text(
            'Campo de respuesta libre (texto largo)',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13.0,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _contentCondicionante() {
    final opciones = widget.pregunta.respuestaCondicionante;
    if (opciones.isEmpty) {
      return Text('Sin opciones definidas',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13.0));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: opciones
          .map((op) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked,
                          color: Color(0xFFFF9800), size: 16.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                          child: Text(op.etiqueta,
                              style: const TextStyle(fontSize: 13.0))),
                      if (op.sustanciaValor.isNotEmpty) ...[
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(op.sustanciaValor,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11.0)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _contentSeleccion() {
    final opciones = widget.pregunta.respuestaSelection;
    if (opciones.isEmpty) {
      return Text('Sin opciones definidas',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13.0));
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 6.0,
      children: opciones
          .map((op) => Chip(
                label: Text(op, style: const TextStyle(fontSize: 12.0)),
                backgroundColor: const Color(0xFFF3E5F5),
                side: const BorderSide(color: Color(0xFF9C27B0), width: 1.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  Widget _contentTamizajeOpciones() {
    final opciones = widget.pregunta.respuestaTamizaje;
    if (opciones.isEmpty) {
      return Text('Sin opciones definidas',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13.0));
    }
    final Color color = widget.pregunta.tipo == 'Tamizaje autoestima' ||
            widget.pregunta.tipo == 'Tamizaje ansiedad'
        ? const Color(0xFFE91E63)
        : const Color(0xFF009688);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: opciones
          .map((op) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_unchecked,
                          color: color, size: 16.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                          child: Text(op.etiqueta,
                              style: const TextStyle(fontSize: 13.0))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text('${op.valor}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _contentTamizajeCDI() {
    final opciones = widget.pregunta.respuestaTamizaje;
    if (opciones.isEmpty) {
      return Text('Sin opciones definidas',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13.0));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: opciones
          .map((op) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(8.0),
                    border: op.ideacionSuicida
                        ? Border.all(color: const Color(0xFFE53935), width: 1.0)
                        : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked,
                          color: Color(0xFF3F51B5), size: 16.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                          child: Text(op.etiqueta,
                              style: const TextStyle(fontSize: 13.0))),
                      if (op.ideacionSuicida) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 6.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 10.0),
                              SizedBox(width: 3.0),
                              Text('IS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F51B5),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text('${op.valor}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _contentTamizajeCRQ() {
    final opciones = widget.pregunta.respuestaTamizaje;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.pregunta.numeroPregunta > 0) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF4CAF50), width: 1.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('N°',
                    style: TextStyle(fontSize: 10.0, color: Color(0xFF4CAF50))),
                Text('${widget.pregunta.numeroPregunta}',
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50))),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
        ],
        Expanded(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: opciones.isEmpty
                ? [
                    _siNoChip('SI', true),
                    _siNoChip('NO', false),
                  ]
                : opciones.map(_siNoChipValor).toList(),
          ),
        ),
      ],
    );
  }

  Widget _siNoChip(String label, bool isSi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isSi ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
            color: isSi ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
            width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSi ? Icons.check : Icons.close,
              color: isSi ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
              size: 14.0),
          const SizedBox(width: 4.0),
          Text(label,
              style: TextStyle(
                  color:
                      isSi ? const Color(0xFF388E3C) : const Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0)),
        ],
      ),
    );
  }

  Widget _siNoChipValor(AtributosStruct op) {
    final isSi = op.valor == 1;
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 64),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isSi ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
            color: isSi ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
            width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSi ? Icons.check : Icons.close,
              color: isSi ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
              size: 14.0),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(op.etiqueta,
                style: TextStyle(
                    color: isSi
                        ? const Color(0xFF388E3C)
                        : const Color(0xFFD32F2F),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0)),
          ),
          const SizedBox(width: 4.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            decoration: BoxDecoration(
              color: isSi ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text('${op.valor}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _contentSeleccionUnica() {
    return wrapWithModel(
      model: _seleccionUnicaModel,
      updateCallback: () => setState(() {}),
      child: SeleccionUnicaWidget(
        key: Key('pregcard_su_${widget.index}'),
        parameter1: widget.pregunta.respuestaSUnicaCorrecta,
        parameter2: widget.pregunta.respuestasSeleccionUnica,
      ),
    );
  }

  Widget _contentVerdaderoFalso() {
    return Wrap(
      spacing: 12.0,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF1976D2), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_outline,
                  color: Color(0xFF1976D2), size: 16.0),
              SizedBox(width: 6.0),
              Text('Verdadero',
                  style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFFD32F2F), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cancel_outlined, color: Color(0xFFD32F2F), size: 16.0),
              SizedBox(width: 6.0),
              Text('Falso',
                  style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contentDescriptiva() {
    final texto = widget.pregunta.respuestaLarga;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF607D8B), size: 18.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              texto.isNotEmpty
                  ? texto
                  : 'Texto descriptivo (solo lectura, sin respuesta)',
              style: TextStyle(
                  color: texto.isNotEmpty
                      ? const Color(0xFF37474F)
                      : const Color(0xFF546E7A),
                  fontSize: 13.0,
                  fontStyle:
                      texto.isNotEmpty ? FontStyle.normal : FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEditForm(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
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
      'Tamizaje RQC',
      'Tamizaje RQC / SRQ',
      'Tamizaje ansiedad',
      'Descriptiva'
    ];

    final permitidos = tiposPermitidos(
        widget.categoria ?? widget.encuestasRecord.categoria, todosLosTipos);
    // Conserva el tipo actual aunque la categoría ya no lo permita (p. ej.
    // preguntas 'abiertas' o 'Tamizaje' legacy en un ASSIST): si no estuviera
    // en las opciones, el dropdown quedaría con un valor inválido.
    final opcionesTipo = [
      ...permitidos,
      if ((_tipoValue ?? '').isNotEmpty && !permitidos.contains(_tipoValue))
        _tipoValue!,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFF265294), width: 2.0),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x18000000),
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editando Pregunta #${widget.index + 1}',
                    style: theme.bodyMedium.override(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: const Color(0xFF265294),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => setState(() => _isEditing = false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_rounded, color: Colors.green, size: 28),
                        onPressed: _saveChanges,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8.0),

              // Title TextFormField
              TextFormField(
                controller: _preguntaTextController,
                decoration: const InputDecoration(
                  labelText: 'Texto de la Pregunta',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12.0),

              // Required & Hide Answer Switch/Checkboxes
              Row(
                children: [
                  Checkbox(
                    value: _nPreguntaObligatoria,
                    onChanged: (val) => setState(() => _nPreguntaObligatoria = val ?? false),
                    activeColor: const Color(0xFF265294),
                  ),
                  Text('Obligatoria', style: theme.bodyMedium),
                  const SizedBox(width: 24.0),
                  if (_tipoValue != 'Descriptiva') ...[
                    Checkbox(
                      value: _ocultarRespuesta,
                      onChanged: (val) => setState(() => _ocultarRespuesta = val ?? false),
                      activeColor: const Color(0xFF265294),
                    ),
                    Text('Ocultar respuesta', style: theme.bodyMedium),
                  ],
                ],
              ),
              const SizedBox(height: 12.0),

              // Question Type Dropdown
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo de Pregunta', style: theme.bodySmall),
                        const SizedBox(height: 4.0),
                        FlutterFlowDropDown<String>(
                          controller: _tipoValueController ??= FormFieldController<String?>(_tipoValue),
                          options: opcionesTipo,
                          onChanged: (val) {
                            setState(() {
                              _tipoValue = val;
                              _respuestaSelection.clear();
                              _respuestasSeleccionUnica.clear();
                              _respuestaTamizaje.clear();
                              _respuestaCondicionante.clear();
                              _seleccionUnicaCorrecta = null;
                            });
                          },
                          width: double.infinity,
                          height: 48,
                          textStyle: theme.bodyMedium,
                          fillColor: Colors.white,
                          elevation: 2.0,
                          borderColor: Colors.grey.shade400,
                          borderWidth: 1.0,
                          borderRadius: 8,
                          margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                          hidesUnderline: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Specific editing controls based on type
              _buildTypeSpecificEditor(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificEditor(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tipo = _tipoValue;

    if (tipo == 'abiertas') {
      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: const [
            Icon(Icons.edit_note_rounded, color: Colors.grey),
            SizedBox(width: 8.0),
            Text('Respuesta abierta (texto libre por parte del usuario).',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    if (tipo == 'Descriptiva') {
      return TextFormField(
        controller: _respuestaLargaController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Texto descriptivo o informativo',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      );
    }

    if (tipo == 'selección') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _opcionTextController,
                  decoration: const InputDecoration(
                    labelText: 'Añadir opción',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF265294), size: 32),
                onPressed: () {
                  final text = _opcionTextController.text.trim();
                  if (text.isNotEmpty && !_respuestaSelection.contains(text)) {
                    setState(() {
                      _respuestaSelection.add(text);
                      _opcionTextController.clear();
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 8.0),
          Column(
            children: List.generate(_respuestaSelection.length, (idx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Text('${idx + 1}. ', style: theme.bodyMedium),
                    Expanded(
                      child: TextFormField(
                        initialValue: _respuestaSelection[idx],
                        onChanged: (val) => _respuestaSelection[idx] = val,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _respuestaSelection.removeAt(idx)),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      );
    }

    if (tipo == 'Selección única') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _opcionTextController,
                  decoration: const InputDecoration(
                    labelText: 'Añadir opción única',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF265294), size: 32),
                onPressed: () {
                  final text = _opcionTextController.text.trim();
                  if (text.isNotEmpty && !_respuestasSeleccionUnica.contains(text)) {
                    setState(() {
                      _respuestasSeleccionUnica.add(text);
                      _opcionTextController.clear();
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 8.0),
          if (_respuestasSeleccionUnica.isNotEmpty) ...[
            Text('Selecciona la opción correcta y edita si lo deseas:', style: theme.bodySmall),
            const SizedBox(height: 4.0),
            Column(
              children: List.generate(_respuestasSeleccionUnica.length, (idx) {
                final opt = _respuestasSeleccionUnica[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: opt,
                        groupValue: _seleccionUnicaCorrecta,
                        onChanged: (val) => setState(() => _seleccionUnicaCorrecta = val),
                        activeColor: const Color(0xFF265294),
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: opt,
                          onChanged: (val) {
                            setState(() {
                              _respuestasSeleccionUnica[idx] = val;
                              if (_seleccionUnicaCorrecta == opt) {
                                _seleccionUnicaCorrecta = val;
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _respuestasSeleccionUnica.removeAt(idx);
                            if (_seleccionUnicaCorrecta == opt) {
                              _seleccionUnicaCorrecta = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      );
    }

    if (tipo == 'Verdadero o falso') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opción Correcta:', style: theme.bodySmall),
          Row(
            children: [
              Radio<String>(
                value: 'Verdadero',
                groupValue: _seleccionUnicaCorrecta,
                onChanged: (val) => setState(() => _seleccionUnicaCorrecta = val),
                activeColor: const Color(0xFF265294),
              ),
              Text('Verdadero', style: theme.bodyMedium),
              const SizedBox(width: 24.0),
              Radio<String>(
                value: 'Falso',
                groupValue: _seleccionUnicaCorrecta,
                onChanged: (val) => setState(() => _seleccionUnicaCorrecta = val),
                activeColor: const Color(0xFF265294),
              ),
              Text('Falso', style: theme.bodyMedium),
            ],
          ),
        ],
      );
    }

    if (tipo == 'Condicionante') {
      const sustancias = [
        'Tabaco',
        'Bebidas alcohólicas',
        'Cannabis',
        'Anfetaminas',
        'Inhalantes',
        'Tranquilizantes',
        'Alucinógenos',
        'Opiáceos',
        'Cocaina',
        'Otros'
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _condicionanteEtiquetaController,
                  decoration: const InputDecoration(
                    labelText: 'Etiqueta (ej: Sí, fumo)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: _condicionanteSustanciaController ??= FormFieldController<String?>(_condicionanteSustanciaValue),
                  options: sustancias,
                  onChanged: (val) => setState(() => _condicionanteSustanciaValue = val),
                  width: double.infinity,
                  height: 48,
                  hintText: 'Sustancia',
                  textStyle: theme.bodyMedium,
                  fillColor: Colors.white,
                  elevation: 2.0,
                  borderColor: Colors.grey.shade400,
                  borderWidth: 1.0,
                  borderRadius: 8,
                  margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  hidesUnderline: true,
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF265294), size: 32),
                onPressed: () {
                  final etiq = _condicionanteEtiquetaController.text.trim();
                  final subst = _condicionanteSustanciaValue;
                  if (etiq.isNotEmpty && subst != null) {
                    setState(() {
                      _respuestaCondicionante.add(ValorCondicionanteStruct(
                        etiqueta: etiq,
                        sustanciaValor: subst,
                      ));
                      _condicionanteSustanciaControllers.add(FormFieldController<String?>(subst));
                      _condicionanteEtiquetaController.clear();
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 8.0),
          Column(
            children: List.generate(_respuestaCondicionante.length, (idx) {
              final cond = _respuestaCondicionante[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: cond.etiqueta,
                        onChanged: (val) => cond.etiqueta = val,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: FlutterFlowDropDown<String>(
                        controller: _condicionanteSustanciaControllers[idx],
                        options: sustancias,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              cond.sustanciaValor = val;
                            });
                          }
                        },
                        width: double.infinity,
                        height: 40,
                        textStyle: theme.bodyMedium,
                        fillColor: Colors.white,
                        elevation: 2.0,
                        borderColor: Colors.grey.shade400,
                        borderWidth: 1.0,
                        borderRadius: 8,
                        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                        hidesUnderline: true,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _respuestaCondicionante.removeAt(idx);
                          final controller = _condicionanteSustanciaControllers.removeAt(idx);
                          controller.dispose();
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      );
    }

    if (tipo == 'Tamizaje (Sustancias)') {
      const sustancias = [
        'Tabaco',
        'Bebidas alcohólicas',
        'Cannabis',
        'Anfetaminas',
        'Inhalantes',
        'Tranquilizantes',
        'Alucinógenos',
        'Opiáceos',
        'Cocaina',
        'Otros'
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Sustancia: ', style: theme.bodyMedium),
              const SizedBox(width: 8.0),
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: _sustanciaValueController ??= FormFieldController<String?>(_sustanciaValue),
                  options: sustancias,
                  onChanged: (val) => setState(() => _sustanciaValue = val),
                  width: double.infinity,
                  height: 48,
                  textStyle: theme.bodyMedium,
                  fillColor: Colors.white,
                  elevation: 2.0,
                  borderColor: Colors.grey.shade400,
                  borderWidth: 1.0,
                  borderRadius: 8,
                  margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  hidesUnderline: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildTamizajeOptionsEditor(context),
        ],
      );
    }

    if (tipo == 'Tamizaje' || tipo == 'Tamizaje autoestima' || tipo == 'Tamizaje ansiedad') {
      return _buildTamizajeOptionsEditor(context);
    }

    if (tipo == 'Tamizaje CDI' || tipo == 'Tamizajes Depresion Beck') {
      final isCDI = tipo == 'Tamizaje CDI';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Variable: ', style: theme.bodyMedium),
              const SizedBox(width: 8.0),
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: _variableValueController ??= FormFieldController<String?>(_variableValue),
                  options: isCDI ? const ['Disforia', 'Autoestima Negativa'] : kVariablesBeckBDI,
                  onChanged: (val) => setState(() => _variableValue = val),
                  width: double.infinity,
                  height: 48,
                  textStyle: theme.bodyMedium,
                  fillColor: Colors.white,
                  elevation: 2.0,
                  borderColor: Colors.grey.shade400,
                  borderWidth: 1.0,
                  borderRadius: 8,
                  margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  hidesUnderline: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildCDIBeckOptionsEditor(context),
        ],
      );
    }

    if (tipo == 'Tamizaje RQC' || tipo == 'Tamizaje SRQ' || tipo == 'Tamizaje CRQ' || tipo == 'Tamizaje CRQ / SRQ' || tipo == 'Tamizaje RQC / SRQ') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _crqNumeroPreguntaController,
            decoration: const InputDecoration(
              labelText: 'Número de pregunta original (ej. 17)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _crqSiScoreController,
                  decoration: const InputDecoration(
                    labelText: 'Puntaje SI',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextFormField(
                  controller: _crqNoScoreController,
                  decoration: const InputDecoration(
                    labelText: 'Puntaje NO',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTamizajeOptionsEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _opcionTextController,
                decoration: const InputDecoration(
                  labelText: 'Opción (ej: En desacuerdo)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _opcionPuntajeController,
                decoration: const InputDecoration(
                  labelText: 'Puntaje',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF265294), size: 32),
              onPressed: () {
                final etiq = _opcionTextController.text.trim();
                final val = int.tryParse(_opcionPuntajeController.text.trim()) ?? 0;
                if (etiq.isNotEmpty) {
                  setState(() {
                    _respuestaTamizaje.add(AtributosStruct(
                      etiqueta: etiq,
                      valor: val,
                    ));
                    _opcionTextController.clear();
                    _opcionPuntajeController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Column(
          children: List.generate(_respuestaTamizaje.length, (idx) {
            final opt = _respuestaTamizaje[idx];
            final theme = FlutterFlowTheme.of(context);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Text('${idx + 1}. ', style: theme.bodyMedium),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: opt.etiqueta,
                      onChanged: (val) => opt.etiqueta = val,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: opt.valor.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => opt.valor = int.tryParse(val) ?? 0,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _respuestaTamizaje.removeAt(idx)),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCDIBeckOptionsEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _opcionTextController,
                decoration: const InputDecoration(
                  labelText: 'Opción de respuesta',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _opcionPuntajeController,
                decoration: const InputDecoration(
                  labelText: 'Puntaje',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6.0),
            Checkbox(
              value: _ideacionSuicidaOption,
              onChanged: (val) => setState(() => _ideacionSuicidaOption = val ?? false),
            ),
            const Text('IS', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF265294), size: 32),
              onPressed: () {
                final etiq = _opcionTextController.text.trim();
                final val = int.tryParse(_opcionPuntajeController.text.trim()) ?? 0;
                if (etiq.isNotEmpty) {
                  setState(() {
                    _respuestaTamizaje.add(AtributosStruct(
                      etiqueta: etiq,
                      valor: val,
                      ideacionSuicida: _ideacionSuicidaOption,
                    ));
                    _opcionTextController.clear();
                    _opcionPuntajeController.clear();
                    _ideacionSuicidaOption = false;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Column(
          children: List.generate(_respuestaTamizaje.length, (idx) {
            final opt = _respuestaTamizaje[idx];
            final theme = FlutterFlowTheme.of(context);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Text('${idx + 1}. ', style: theme.bodyMedium),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: opt.etiqueta,
                      onChanged: (val) => opt.etiqueta = val,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: opt.valor.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => opt.valor = int.tryParse(val) ?? 0,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: opt.ideacionSuicida,
                    onChanged: (val) => setState(() => opt.ideacionSuicida = val ?? false),
                  ),
                  const Text('IS', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _respuestaTamizaje.removeAt(idx)),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
