part of '../wizard_tamizaje_manual.dart';

class _PasoFormulario extends StatefulWidget {
  const _PasoFormulario({
    super.key,
    required this.encuesta,
    required this.adolescente,
    required this.onFinalizado,
    required this.onAtras,
    required this.onInvalidar,
  });

  final EncuestasRecord encuesta;
  final UsersRecord? adolescente;
  /// Devuelve true si se guardó; si es false, el formulario se reactiva
  /// para reintentar.
  final Future<bool> Function(
    List<RespuestaTestStruct> respuestas,
    int puntajeTotal,
    bool tieneIdeacion,
  ) onFinalizado;
  final VoidCallback onAtras;
  final VoidCallback onInvalidar;

  @override
  State<_PasoFormulario> createState() => _PasoFormularioState();
}

class _PasoFormularioState extends State<_PasoFormulario> {
  List<RespuestaState> _estados = const [];
  late Future<List<PreguntasEncuestaStruct>> _preguntasFuture;
  bool _guardando = false;

  /// true = sub-paso "Consumo" (solo Condicionantes, ASSIST); false = resto.
  bool _enConsumo = false;

  VisibilidadAssist get _visibilidad => VisibilidadAssist(_estados);

  /// Condicionantes y las Descriptivas que aparecen antes del primero.
  Set<int> get _indicesConsumo {
    final primero = _estados.indexWhere((e) => e.esCondicionante);
    if (primero < 0) return {};
    return {
      for (var i = 0; i < _estados.length; i++)
        if (_estados[i].esCondicionante ||
            (i < primero &&
                _estados[i].tipoKind == PreguntaTipo.descriptiva))
          i,
    };
  }

  List<int> get _indicesVisibles {
    final vis = _visibilidad;
    final consumo = _indicesConsumo;
    return [
      for (var i = 0; i < _estados.length; i++)
        if (_enConsumo ? consumo.contains(i) : !consumo.contains(i))
          if (vis.esVisible(_estados[i])) i,
    ];
  }

  void _continuar() {
    for (final i in _indicesConsumo) {
      if (!_estados[i].estaCompleto()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Marque al menos una opción en la pregunta ${i + 1}'),
          ),
        );
        return;
      }
    }
    _visibilidad.limpiarOcultas(_estados);
    setState(() => _enConsumo = false);
  }

  @override
  void initState() {
    super.initState();
    _preguntasFuture = _cargarPreguntas();
  }

  /// Loads questions, trying the inline `Preguntas` array first, and
  /// falling back to the `Encuestas/{id}/Preguntas` subcollection when
  /// the array is empty. Some encuestas created through the legacy
  /// editor only persist their questions in the subcollection.
  Future<List<PreguntasEncuestaStruct>> _cargarPreguntas() async {
    // 1) Array field on the parent document.
    final inline = widget.encuesta.preguntas;
    if (inline.isNotEmpty) {
      return inline;
    }

    // 2) Fallback: Encuestas/{id}/Preguntas subcollection.
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Encuestas')
          .doc(widget.encuesta.reference.id)
          .collection('Preguntas')
          .get();
      if (snap.docs.isEmpty) return const [];
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final ad = a.data();
          final bd = b.data();
          final an = (ad['NPregunta'] ?? ad['NumeroPregunta'] ?? 0) as num;
          final bn = (bd['NPregunta'] ?? bd['NumeroPregunta'] ?? 0) as num;
          return an.compareTo(bn);
        });
      return docs
          .map((d) => PreguntasEncuestaStruct.fromMap(d.data()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _enviar() async {
    // Validar solo las preguntas visibles (las de sustancias no marcadas en
    // el Condicionante no aplican, igual que en el flujo del adolescente).
    final vis = _visibilidad;
    for (var i = 0; i < _estados.length; i++) {
      final s = _estados[i];
      if (!vis.esVisible(s)) continue;
      if (!s.estaCompleto()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falta responder la pregunta ${i + 1}'),
          ),
        );
        return;
      }
    }

    setState(() => _guardando = true);
    final respuestas = <RespuestaTestStruct>[];
    var puntaje = 0;
    var ideacion = false;
    for (var i = 0; i < _estados.length; i++) {
      final s = _estados[i];
      final r = s.toStruct(i + 1, visible: vis.esVisible(s));
      respuestas.add(r);
      for (final atr in r.respuestaTamizaje) {
        puntaje += atr.valor;
        if (atr.ideacionSuicida) ideacion = true;
      }
    }
    final ok = await widget.onFinalizado(respuestas, puntaje, ideacion);
    if (!ok && mounted) setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onAtras,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.encuesta.titulo,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              if (widget.adolescente != null)
                Chip(
                  avatar: const Icon(Icons.person, size: 16),
                  label: Text(widget.adolescente!.displayName),
                ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          const Icon(Icons.block_outlined,
                              color: Color(0xFFE53935), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Invalidar prueba',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Bajo criterio médico, ¿deseas invalidar esta prueba?\n\n'
                        'El paciente no podrá repetirla durante 24 horas y '
                        'el evento quedará registrado en su historial.',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Cancelar',
                              style: GoogleFonts.inter(
                                  color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Invalidar',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) widget.onInvalidar();
                },
                icon: const Icon(Icons.block_outlined,
                    size: 14, color: Color(0xFFE53935)),
                label: Text(
                  'Invalidar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE53935),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          if (widget.encuesta.descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 56),
              child: Text(
                widget.encuesta.descripcion,
                style: theme.bodySmall.override(
                  font: GoogleFonts.inter(),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<PreguntasEncuestaStruct>>(
              future: _preguntasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final preguntas = snapshot.data ?? const [];
                if (preguntas.isEmpty) {
                  return _buildEmptyState(theme);
                }
                // (Re)build the answer states the first time we have data,
                // or whenever the number of preguntas changed (defensive).
                if (_estados.length != preguntas.length) {
                  _estados =
                      preguntas.map((p) => RespuestaState(p)).toList();
                  _enConsumo = _estados.any((e) => e.esCondicionante);
                }
                final indices = _indicesVisibles;
                final tieneConsumo = _indicesConsumo.isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tieneConsumo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _enConsumo
                              ? 'Parte 1 de 2 · Consumo: marque las sustancias que aplican'
                              : 'Parte 2 de 2 · Preguntas de las sustancias marcadas',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF265294),
                          ),
                        ),
                      ),
                    Expanded(
                      child: indices.isEmpty
                          ? Center(
                              child: Text(
                                'No hay preguntas que responder para las '
                                'opciones marcadas. Puede finalizar el tamizaje.',
                                textAlign: TextAlign.center,
                                style: theme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              itemCount: indices.length,
                              itemBuilder: (context, k) {
                                final i = indices[k];
                                return _PreguntaCard(
                                  numero: i + 1,
                                  estado: _estados[i],
                                  theme: theme,
                                  onChanged: () => setState(() {}),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_indicesConsumo.isNotEmpty && !_enConsumo) ...[
                OutlinedButton.icon(
                  onPressed: _guardando
                      ? null
                      : () => setState(() => _enConsumo = true),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Volver a Consumo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (_enConsumo)
                ElevatedButton.icon(
                  onPressed: _estados.isEmpty ? null : _continuar,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF265294),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    textStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!_enConsumo)
              ElevatedButton.icon(
                onPressed: (_estados.isEmpty || _guardando) ? null : _enviar,
                icon: _guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_guardando
                    ? 'Guardando…'
                    : 'Finalizar y guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34A853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(FlutterFlowTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: theme.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'Esta encuesta no tiene preguntas configuradas',
              textAlign: TextAlign.center,
              style: theme.titleSmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona otro tamizaje o configura preguntas en el editor de encuestas.',
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                font: GoogleFonts.inter(),
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: widget.onAtras,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreguntaCard extends StatelessWidget {
  const _PreguntaCard({
    required this.numero,
    required this.estado,
    required this.theme,
    required this.onChanged,
  });

  final int numero;
  final RespuestaState estado;
  final FlutterFlowTheme theme;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final p = estado.pregunta;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.alternate),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF265294),
                  child: Text(
                    '$numero',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.pregunta,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _renderInput(),
          ],
        ),
      ),
    );
  }

  Widget _renderInput() {
    final p = estado.pregunta;
    final tipo = p.tipo;
    final kind = estado.tipoKind;

    if (kind == PreguntaTipo.descriptiva) {
      final desc = p.respuestaLarga.trim();
      if (desc.isEmpty) {
        return Text(
          '(Este tamizaje no cuenta con una descripción adicional)',
          style: theme.bodySmall.override(
            font: GoogleFonts.inter(fontStyle: FontStyle.italic),
            color: theme.secondaryText,
            letterSpacing: 0.0,
          ),
        );
      }
      return Text(
        desc,
        style: theme.bodyMedium.override(
          font: GoogleFonts.inter(),
          letterSpacing: 0.0,
        ),
      );
    }

    if (kind == PreguntaTipo.abiertas) {
      return TextField(
        controller: estado.textController,
        maxLines: 3,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Respuesta del adolescente…',
        ),
        onChanged: (_) => onChanged(),
      );
    }

    if (kind == PreguntaTipo.tamizajeRadio) {
      return _radioAtributos(p.respuestaTamizaje);
    }

    if (kind == PreguntaTipo.seleccionMultiple) {
      final opciones = p.respuestaSelection;
      if (opciones.isEmpty) {
        return Text('Sin opciones configuradas', style: theme.bodySmall);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: opciones.map((op) {
          final marcada = estado.seleccionMultiple.contains(op);
          return CheckboxListTile(
            value: marcada,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(op),
            onChanged: (v) {
              if (v == true) {
                estado.seleccionMultiple.add(op);
              } else {
                estado.seleccionMultiple.remove(op);
              }
              onChanged();
            },
          );
        }).toList(),
      );
    }

    if (kind == PreguntaTipo.seleccionUnica) {
      final opciones = p.respuestasSeleccionUnica;
      if (opciones.isEmpty) {
        return Text('Sin opciones configuradas', style: theme.bodySmall);
      }
      return RadioGroup<String>(
        groupValue: estado.seleccionUnica,
        onChanged: (v) {
          estado.seleccionUnica = v;
          onChanged();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: opciones.map((op) {
            return RadioListTile<String>(
              value: op,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                op,
                style: GoogleFonts.inter(
                  fontWeight: estado.seleccionUnica == op
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    if (kind == PreguntaTipo.verdaderoFalso) {
      return RadioGroup<int>(
        groupValue: estado.trueAndFalseSeleccion,
        onChanged: (v) {
          estado.trueAndFalseSeleccion = v;
          onChanged();
        },
        child: Row(
          children: const [
            Expanded(
              child: RadioListTile<int>(
                value: 1,
                title: Text('Verdadero'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                value: 0,
                title: Text('Falso'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      );
    }

    // Tamizaje (Sustancias): una pregunta evalúa SOLO su sustancia asignada.
    if (kind == PreguntaTipo.tamizajeSustancias) {
      final sustancia = canonicaSustancia(p.sustancia);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sustancia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor:
                    const Color(0xFF009688).withValues(alpha: 0.12),
                side: BorderSide(
                    color: const Color(0xFF009688).withValues(alpha: 0.5)),
                label: Text(
                  'Sustancia: $sustancia',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00796B),
                  ),
                ),
              ),
            ),
          _radioAtributos(p.respuestaTamizaje),
        ],
      );
    }

    // Condicionante: selección MÚLTIPLE; cada opción marcada habilita las
    // preguntas de su sustancia.
    if (kind == PreguntaTipo.condicionante) {
      final opciones = p.respuestaCondicionante;
      if (opciones.isEmpty) {
        return Text('Sin opciones condicionantes configuradas',
            style: theme.bodySmall);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marque todas las que apliquen.',
            style: theme.bodySmall.override(
              font: GoogleFonts.inter(fontStyle: FontStyle.italic),
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          ...opciones.map((opt) {
            final marcada =
                estado.condicionanteSeleccionadas.contains(opt.etiqueta);
            final sustancia = canonicaSustancia(opt.sustanciaValor);
            return CheckboxListTile(
              value: marcada,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                opt.etiqueta,
                style: GoogleFonts.inter(
                  fontWeight: marcada ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              subtitle: sustancia.isEmpty ? null : Text(sustancia),
              onChanged: (v) {
                if (v == true) {
                  estado.condicionanteSeleccionadas.add(opt.etiqueta);
                } else {
                  estado.condicionanteSeleccionadas.remove(opt.etiqueta);
                }
                onChanged();
              },
            );
          }),
        ],
      );
    }

    // Unknown type fallback -- warning styled, shows raw tipo string.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 20, color: Color(0xFFE65100)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de pregunta no soportado',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Valor recibido: "${tipo.isEmpty ? '(vacío)' : tipo}"',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A4500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Radio sobre las opciones etiqueta→valor de una pregunta de tamizaje.
  Widget _radioAtributos(List<AtributosStruct> opciones) {
    if (opciones.isEmpty) {
      return Text('Sin opciones configuradas', style: theme.bodySmall);
    }
    return RadioGroup<String>(
      groupValue: estado.atributoSeleccionado?.etiqueta,
      onChanged: (value) {
        final opt = opciones.firstWhere(
          (o) => o.etiqueta == value,
          orElse: () => opciones.first,
        );
        estado.atributoSeleccionado = opt;
        onChanged();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: opciones.map((opt) {
          final selected =
              estado.atributoSeleccionado?.etiqueta == opt.etiqueta;
          return RadioListTile<String>(
            value: opt.etiqueta,
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${opt.etiqueta}  (${opt.valor})',
              style: GoogleFonts.inter(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 4 — resultados + notas + recordatorio opcional
// ─────────────────────────────────────────────────────────────────────────────

