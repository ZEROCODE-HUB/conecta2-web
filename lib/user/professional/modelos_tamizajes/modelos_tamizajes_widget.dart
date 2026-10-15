import '/backend/backend.dart';
import '/components/footer_professionals/footer_professionals_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/tamizajes/shared/assist_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import '/user/professional/tamizajes_manuales/wizard/state/respuesta_state.dart'
    show PreguntaTipo, resolvePreguntaTipo;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modelos de tamizajes (profesional, móvil): plantillas publicadas en
/// solo lectura. Botón 4 del menú del profesional.
///
/// Lista los tamizajes publicados (`Encuestas.tipo == 'Tamizajes'`) con
/// búsqueda y filtro por categoría; al tocar uno abre su detalle: preguntas
/// con opciones y puntaje, niveles (rangos) y alertas especiales. No se
/// puede crear ni editar.
class ModelosTamizajesWidget extends StatefulWidget {
  const ModelosTamizajesWidget({super.key});

  static String routeName = 'modelosTamizajes';
  static String routePath = '/modelosTamizajes';

  @override
  State<ModelosTamizajesWidget> createState() => _ModelosTamizajesWidgetState();
}

class _ModelosTamizajesWidgetState extends State<ModelosTamizajesWidget> {
  final _busquedaController = TextEditingController();
  String _busqueda = '';
  String? _categoria; // null = todas

  late final Stream<List<EncuestasRecord>> _stream = queryEncuestasRecord(
    queryBuilder: (q) => q
        .where('tipo', isEqualTo: 'Tamizajes')
        .where('Publicado', isEqualTo: true),
  );

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 0.0, 16.0, 100.0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80.0),
                        _titulo(theme),
                        _buscador(),
                        const SizedBox(height: 12.0),
                        StreamBuilder<List<EncuestasRecord>>(
                          stream: _stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const TamizajeEmptyState(
                                icon: Icons.error_outline,
                                mensaje: 'No se pudieron cargar los modelos',
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 60.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(kNavy),
                                  ),
                                ),
                              );
                            }
                            return _lista(snapshot.data!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: FooterProfessionalsWidget(active: 4),
                ),
                const ProfesionalHeaderWidget(name: 'Modelos'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titulo(FlutterFlowTheme theme) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 4.0),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: kNavy, size: 24.0),
            const SizedBox(width: 8.0),
            Text(
              'Modelos de tamizajes',
              style: theme.headlineSmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                color: kNavy,
                fontSize: 20.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      );

  Widget _buscador() => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextField(
          controller: _busquedaController,
          onChanged: (v) => setState(() => _busqueda = v),
          decoration: InputDecoration(
            hintText: 'Buscar tamizaje…',
            hintStyle: GoogleFonts.inter(fontSize: 14.0),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _busqueda.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _busquedaController.clear();
                      setState(() => _busqueda = '');
                    },
                  ),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      );

  Widget _lista(List<EncuestasRecord> todos) {
    final categorias = {
      for (final e in todos)
        if (e.categoria.trim().isNotEmpty) e.categoria.trim(),
    }.toList()
      ..sort();
    final q = _busqueda.trim().toLowerCase();
    final visibles = todos.where((e) {
      if (_categoria != null && e.categoria.trim() != _categoria) return false;
      if (q.isEmpty) return true;
      return e.titulo.toLowerCase().contains(q) ||
          e.categoria.toLowerCase().contains(q);
    }).toList()
      ..sort(
          (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (categorias.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('Todas', _categoria == null,
                    () => setState(() => _categoria = null)),
                for (final c in categorias)
                  _chip(c, _categoria == c,
                      () => setState(() => _categoria = c)),
              ],
            ),
          ),
        const SizedBox(height: 12.0),
        if (visibles.isEmpty)
          const TamizajeEmptyState(
            icon: Icons.inbox_outlined,
            mensaje: 'No hay modelos que coincidan',
          )
        else
          for (final e in visibles) _tarjeta(e),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ChoiceChip(
          label: Text(label, style: GoogleFonts.inter(fontSize: 13.0)),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _tarjeta(EncuestasRecord e) {
    final preguntas = e.preguntas
        .where((p) => resolvePreguntaTipo(p.tipo) != PreguntaTipo.descriptiva)
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ModeloDetalle(encuesta: e),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.titulo.isEmpty ? 'Sin título' : e.titulo,
                        style: GoogleFonts.inter(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          if (e.categoria.trim().isNotEmpty)
                            _Etiqueta(e.categoria.trim()),
                          _Etiqueta('$preguntas preguntas', suave: true),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: kNavy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detalle de una plantilla (solo lectura) ─────────────────────────────────

class _ModeloDetalle extends StatelessWidget {
  const _ModeloDetalle({required this.encuesta});
  final EncuestasRecord encuesta;

  @override
  Widget build(BuildContext context) {
    final e = encuesta;
    final niveles = [...e.alertas]..sort((a, b) {
        final s = canonicaSustancia(a.sustancia)
            .compareTo(canonicaSustancia(b.sustancia));
        return s != 0 ? s : a.min.compareTo(b.min);
      });
    var numero = 0;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: kNavy,
        foregroundColor: Colors.white,
        title: Text(
          e.titulo.isEmpty ? 'Modelo de tamizaje' : e.titulo,
          style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _Seccion(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    if (e.categoria.trim().isNotEmpty)
                      _Etiqueta(e.categoria.trim()),
                    const _Etiqueta('Solo lectura', suave: true),
                  ],
                ),
                if (e.descripcion.trim().isNotEmpty) ...[
                  const SizedBox(height: 10.0),
                  Text(e.descripcion.trim(),
                      style: GoogleFonts.inter(
                          fontSize: 14.0, color: const Color(0xFF4B5563))),
                ],
              ],
            ),
            if (niveles.isNotEmpty) ...[
              const _Titulo('Niveles (rangos de puntaje)'),
              _Seccion(
                children: [
                  for (final n in niveles)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              [
                                if (n.sustancia.trim().isNotEmpty)
                                  canonicaSustancia(n.sustancia),
                                n.nivel.isEmpty ? '—' : n.nivel,
                              ].join(' · '),
                              style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text('${n.min} – ${n.max} pts',
                              style: GoogleFonts.inter(
                                  fontSize: 13.0,
                                  color: const Color(0xFF4B5563))),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            if (e.alertasEspeciales.isNotEmpty) ...[
              const _Titulo('Alertas especiales'),
              _Seccion(
                children: [
                  for (final a in e.alertasEspeciales)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 18.0, color: kDanger),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              [
                                a.nombre.isEmpty ? 'Alerta' : a.nombre,
                                if (a.condicion.isNotEmpty)
                                  'condición: ${a.condicion}',
                                if (a.preguntas.isNotEmpty)
                                  'preguntas ${a.preguntas.join(', ')}',
                                if (a.puntaje != 0) 'puntaje ${a.puntaje}',
                              ].join(' · '),
                              style: GoogleFonts.inter(fontSize: 13.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            _Titulo('Preguntas (${e.preguntas.length})'),
            for (final p in e.preguntas)
              _PreguntaModelo(
                pregunta: p,
                numero: resolvePreguntaTipo(p.tipo) == PreguntaTipo.descriptiva
                    ? null
                    : ++numero,
              ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}

class _PreguntaModelo extends StatelessWidget {
  const _PreguntaModelo({required this.pregunta, this.numero});
  final PreguntasEncuestaStruct pregunta;
  final int? numero;

  static String _tipoLegible(PreguntaTipo t) => switch (t) {
        PreguntaTipo.descriptiva => 'Texto informativo',
        PreguntaTipo.abiertas => 'Respuesta abierta',
        PreguntaTipo.seleccionMultiple => 'Selección múltiple',
        PreguntaTipo.seleccionUnica => 'Selección única',
        PreguntaTipo.verdaderoFalso => 'Verdadero o falso',
        PreguntaTipo.tamizajeRadio => 'Escala con puntaje',
        PreguntaTipo.tamizajeSustancias => 'Escala por sustancia',
        PreguntaTipo.condicionante => 'Condicionante (sustancias)',
        PreguntaTipo.desconocido => 'Otro',
      };

  @override
  Widget build(BuildContext context) {
    final p = pregunta;
    final tipo = resolvePreguntaTipo(p.tipo);
    final texto = GoogleFonts.inter(fontSize: 13.0);

    final List<Widget> opciones = switch (tipo) {
      PreguntaTipo.tamizajeRadio ||
      PreguntaTipo.tamizajeSustancias =>
        ([...p.respuestaTamizaje]..sort((a, b) => a.orden.compareTo(b.orden)))
            .map((o) => _Opcion(
                  o.etiqueta,
                  trailing: '${o.valor} pts',
                  alerta: o.ideacionSuicida,
                ))
            .toList(),
      PreguntaTipo.seleccionUnica =>
        p.respuestasSeleccionUnica.map((o) => _Opcion(o)).toList(),
      PreguntaTipo.seleccionMultiple =>
        p.respuestaSelection.map((o) => _Opcion(o)).toList(),
      PreguntaTipo.condicionante => p.respuestaCondicionante
          .map((o) => _Opcion(o.etiqueta,
              trailing: o.sustanciaValor.trim().isEmpty
                  ? null
                  : '→ ${canonicaSustancia(o.sustanciaValor)}'))
          .toList(),
      PreguntaTipo.verdaderoFalso => const [
          _Opcion('Verdadero'),
          _Opcion('Falso'),
        ],
      PreguntaTipo.abiertas => [
          Text('El paciente responde con texto libre.',
              style: texto.copyWith(color: const Color(0xFF6B7280))),
        ],
      _ => const [],
    };

    return _Seccion(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (numero != null) ...[
              Container(
                width: 26.0,
                height: 26.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text('$numero',
                    style: GoogleFonts.inter(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: kNavy)),
              ),
              const SizedBox(width: 10.0),
            ],
            Expanded(
              child: Text(
                p.pregunta.isEmpty ? '—' : p.pregunta,
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: tipo == PreguntaTipo.descriptiva
                      ? FontWeight.w400
                      : FontWeight.w600,
                  fontStyle: tipo == PreguntaTipo.descriptiva
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 4.0,
          children: [
            _Etiqueta(_tipoLegible(tipo), suave: true),
            if (p.variable.trim().isNotEmpty)
              _Etiqueta('Subescala: ${p.variable.trim()}', suave: true),
            if (p.sustancia.trim().isNotEmpty)
              _Etiqueta(canonicaSustancia(p.sustancia), suave: true),
          ],
        ),
        if (opciones.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          ...opciones,
        ],
      ],
    );
  }
}

// ─── Piezas visuales ─────────────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  const _Seccion({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
        child: Text(
          texto,
          style: GoogleFonts.inter(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
      );
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, {this.suave = false});
  final String texto;
  final bool suave;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: suave ? const Color(0xFFF3F4F6) : kNavy.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          texto,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: suave ? const Color(0xFF4B5563) : kNavy,
          ),
        ),
      );
}

class _Opcion extends StatelessWidget {
  const _Opcion(this.etiqueta, {this.trailing, this.alerta = false});
  final String etiqueta;
  final String? trailing;
  final bool alerta;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          children: [
            const Icon(Icons.radio_button_unchecked,
                size: 16.0, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(etiqueta.isEmpty ? '—' : etiqueta,
                  style: GoogleFonts.inter(fontSize: 13.0)),
            ),
            if (alerta)
              const Padding(
                padding: EdgeInsets.only(right: 6.0),
                child: Tooltip(
                  message: 'Marca ideación suicida',
                  child: Icon(Icons.warning_amber_rounded,
                      size: 16.0, color: kDanger),
                ),
              ),
            if (trailing != null)
              Text(trailing!,
                  style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: kNavy)),
          ],
        ),
      );
}
