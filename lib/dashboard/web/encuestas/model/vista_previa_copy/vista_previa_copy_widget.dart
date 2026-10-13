import '/backend/backend.dart';
import '/components/radios_button_vista_previa_widget.dart';
import '/dashboard/web/encuestas/vista_previa/widgets/preview_header.dart';
import '/dashboard/web/encuestas/vista_previa/widgets/preview_actions.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'vista_previa_copy_model.dart';
export 'vista_previa_copy_model.dart';

const _kAzul = Color(0xFF265294);
const _kBorde = Color(0xFF6E98D7);

const _kTiposCRQ = {
  'Tamizaje CRQ',
  'Tamizaje RQC',
  'Tamizaje SRQ',
  'Tamizaje CRQ / SRQ',
  'Tamizaje RQC / SRQ',
};

class VistaPreviaCopyWidget extends StatefulWidget {
  const VistaPreviaCopyWidget({
    super.key,
    required this.encuestaID,
  });

  final DocumentReference? encuestaID;

  @override
  State<VistaPreviaCopyWidget> createState() => _VistaPreviaCopyWidgetState();
}

class _VistaPreviaCopyWidgetState extends State<VistaPreviaCopyWidget> {
  late VistaPreviaCopyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VistaPreviaCopyModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<EncuestasRecord>(
      stream: EncuestasRecord.getDocument(widget.encuestaID!),
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

        final encuesta = snapshot.data!;
        final preguntas = encuesta.preguntas.toList();

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          padding: const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PreviewHeader(),
              const SizedBox(height: 30.0),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 50.0,
                            color: Color(0x26000000),
                            offset: Offset(20.0, 20.0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: SingleChildScrollView(
                          primary: false,
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                encuesta.titulo,
                                style: _estilo(context, 30.0),
                              ),
                              if (encuesta.descripcion.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    encuesta.descripcion,
                                    style: _estilo(context, null,
                                        weight: FontWeight.w500),
                                  ),
                                ),
                              const SizedBox(height: 12.0),
                              if (preguntas.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0),
                                  child: Text(
                                    'Aún no hay preguntas para mostrar.',
                                    style: _nota(context),
                                  ),
                                ),
                              for (var i = 0; i < preguntas.length; i++) ...[
                                const Divider(height: 40.0),
                                _buildPregunta(context, preguntas[i], i),
                              ],
                              const SizedBox(height: 30.0),
                              PreviewSubmitButton(
                                encuestaID: widget.encuestaID!,
                                esTamizaje: encuesta.tipo == 'Tamizajes',
                                onSubmitted: () => safeSetState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dibuja una pregunta según su `tipo`. Todos los tipos de tamizaje
  /// (autoestima, ansiedad, CDI, Beck, CRQ/RQC/SRQ, Sustancias) guardan sus
  /// opciones en `respuestaTamizaje` y se responden con una sola opción.
  Widget _buildPregunta(
      BuildContext context, PreguntasEncuestaStruct p, int index) {
    final tipo = p.tipo;
    final numero = index + 1;

    if (tipo == 'Descriptiva') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo(context, valueOrDefault<String>(p.pregunta, 'Sin texto')),
          if (p.respuestaLarga.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(p.respuestaLarga, style: _nota(context)),
            ),
        ],
      );
    }

    if (tipo.startsWith('Tamizaje')) {
      final esCRQ = _kTiposCRQ.contains(tipo);
      final texto = esCRQ && p.numeroPregunta > 0
          ? '${p.numeroPregunta}. ${p.pregunta}'
          : '$numero. ${p.pregunta}';
      final chips = <String>[
        if (tipo == 'Tamizaje (Sustancias)' && p.sustancia.isNotEmpty)
          'Sustancia: ${p.sustancia}',
        if ((tipo == 'Tamizaje CDI' || tipo == 'Tamizajes Depresion Beck') &&
            p.variable.isNotEmpty)
          'Variable: ${p.variable}',
      ];
      return _bloque(
        context,
        titulo: texto,
        chips: chips,
        vacio: p.respuestaTamizaje.isEmpty,
        opciones: [
          for (final o in p.respuestaTamizaje)
            _opcion(context, Icons.radio_button_unchecked, o.etiqueta,
                chip: 'Puntaje: ${o.valor}'),
        ],
      );
    }

    if (tipo == 'Condicionante') {
      return _bloque(
        context,
        titulo: '$numero. ${p.pregunta}',
        vacio: p.respuestaCondicionante.isEmpty,
        opciones: [
          for (final o in p.respuestaCondicionante)
            _opcion(context, Icons.radio_button_unchecked, o.etiqueta,
                chip: o.sustanciaValor.isEmpty ? null : o.sustanciaValor),
        ],
      );
    }

    if (tipo == 'selección') {
      return _bloque(
        context,
        titulo: '$numero. ${p.pregunta}',
        vacio: p.respuestaSelection.isEmpty,
        opciones: [
          for (final o in p.respuestaSelection)
            _opcion(context, Icons.check_box_outline_blank, o),
        ],
      );
    }

    if (tipo == 'Selección única') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo(context, '$numero. ${p.pregunta}'),
          const SizedBox(height: 12.0),
          RadiosButtonVistaPreviaWidget(
            key: Key('preview_unica_${index}_${p.pregunta.hashCode}'),
            parameter1: p.respuestaSUnicaCorrecta,
            parameter2: p.respuestasSeleccionUnica,
          ),
        ],
      );
    }

    if (tipo == 'Verdadero o falso') {
      return _bloque(
        context,
        titulo: '$numero. ${p.pregunta}',
        opciones: [
          _opcion(context, Icons.radio_button_unchecked, 'Verdadero'),
          _opcion(context, Icons.radio_button_unchecked, 'Falso'),
        ],
      );
    }

    if (tipo == 'abiertas') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo(context, '$numero. ${p.pregunta}'),
          const SizedBox(height: 12.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _kBorde),
            ),
            child: Text('Respuesta abierta del usuario',
                style: _nota(context)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo(context, '$numero. ${p.pregunta}'),
        const SizedBox(height: 8.0),
        Text('Tipo no soportado en vista previa: "$tipo"',
            style: _nota(context)),
      ],
    );
  }

  Widget _bloque(
    BuildContext context, {
    required String titulo,
    required List<Widget> opciones,
    List<String> chips = const [],
    bool vacio = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo(context, titulo),
        if (chips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [for (final c in chips) _chip(context, c)],
            ),
          ),
        const SizedBox(height: 12.0),
        if (vacio)
          Text('Esta pregunta no tiene opciones configuradas.',
              style: _nota(context))
        else
          ...opciones,
      ],
    );
  }

  Widget _opcion(BuildContext context, IconData icono, String texto,
      {String? chip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _kBorde),
        ),
        child: Row(
          children: [
            Icon(icono,
                color: FlutterFlowTheme.of(context).secondaryText, size: 22.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(texto,
                  style: _estilo(context, 16.0, weight: FontWeight.w500)),
            ),
            if (chip != null) ...[
              const SizedBox(width: 10.0),
              _chip(context, chip),
            ],
          ],
        ),
      ),
    );
  }

  Widget _titulo(BuildContext context, String texto) =>
      Text(texto, style: _estilo(context, 18.0));

  Widget _chip(BuildContext context, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0x14265294),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        texto,
        style: _estilo(context, 12.0, weight: FontWeight.w600)
            .copyWith(color: _kAzul),
      ),
    );
  }

  TextStyle _estilo(BuildContext context, double? size,
      {FontWeight weight = FontWeight.w600}) {
    final base = FlutterFlowTheme.of(context).bodyMedium;
    return base.override(
      font: GoogleFonts.inter(fontWeight: weight, fontStyle: base.fontStyle),
      fontSize: size,
      letterSpacing: 0.0,
      fontWeight: weight,
      fontStyle: base.fontStyle,
    );
  }

  TextStyle _nota(BuildContext context) =>
      _estilo(context, 14.0, weight: FontWeight.w400).copyWith(
        color: FlutterFlowTheme.of(context).secondaryText,
        fontStyle: FontStyle.italic,
      );
}
