import '/backend/backend.dart';
import '/components/seleccion_unica_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
    this.onDelete,
  });

  final PreguntasEncuestaStruct pregunta;
  final EncuestasRecord encuestasRecord;
  final int index;
  // Cuando se pasa, el botón de eliminar llama a este callback en lugar de
  // persistir `arrayRemove` al doc. Se usa en creación (buffer local).
  final VoidCallback? onDelete;

  @override
  State<PreguntaCard> createState() => _PreguntaCardState();
}

class _PreguntaCardState extends State<PreguntaCard> {
  late SeleccionUnicaModel _seleccionUnicaModel;

  @override
  void initState() {
    super.initState();
    _seleccionUnicaModel = createModel(context, () => SeleccionUnicaModel());
  }

  @override
  void dispose() {
    _seleccionUnicaModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        labelForTipo(tipo),
        style: TextStyle(
            color: color, fontSize: 11.0, fontWeight: FontWeight.w600),
      ),
    );
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
}
