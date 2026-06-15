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
  final void Function(
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
  List<_RespuestaState> _estados = const [];
  late Future<List<PreguntasEncuestaStruct>> _preguntasFuture;
  bool _guardando = false;

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

  void _enviar() {
    // Validar que todas las preguntas con input tengan respuesta.
    for (var i = 0; i < _estados.length; i++) {
      final s = _estados[i];
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
      final r = s.toStruct(i + 1);
      respuestas.add(r);
      for (final atr in r.respuestaTamizaje) {
        puntaje += atr.valor;
        if (atr.ideacionSuicida) ideacion = true;
      }
    }
    widget.onFinalizado(respuestas, puntaje, ideacion);
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
                      preguntas.map((p) => _RespuestaState(p)).toList();
                }
                return ListView.builder(
                  itemCount: _estados.length,
                  itemBuilder: (context, i) {
                    return _PreguntaCard(
                      numero: i + 1,
                      estado: _estados[i],
                      theme: theme,
                      onChanged: () => setState(() {}),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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

/// Estado por pregunta del formulario.
///
/// Uses [PreguntaTipo] to normalise raw DB strings (case-insensitive,
/// accent-insensitive) so that 'Selección', 'selección' and 'seleccion' all
/// resolve to the same kind.
class _RespuestaState {
  _RespuestaState(this.pregunta) {
    textController = TextEditingController();
  }

  final PreguntasEncuestaStruct pregunta;
  late final TextEditingController textController;

  /// Atributo seleccionado (para tamizajes con respuestaTamizaje).
  AtributosStruct? atributoSeleccionado;

  /// Para selección múltiple ('selección').
  final Set<String> seleccionMultiple = {};

  /// Para selección única ('Selección única').
  String? seleccionUnica;

  /// Para verdadero/falso (1 = verdadero, 0 = falso).
  int? trueAndFalseSeleccion;

  /// Per-substance selection for 'Tamizaje (Sustancias)'.
  final Map<String, AtributosStruct> sustanciaSelecciones = {};

  /// Selected value for 'Condicionante' questions.
  String? condicionanteSeleccion;

  PreguntaTipo get tipoKind => resolvePreguntaTipo(pregunta.tipo);

  static const _sustancias = [
    'Tabaco',
    'Bebidas alcoh\u00f3licas',
    'Cannabis',
    'Coca\u00edna',
    'Anfetaminas',
    'Inhalantes',
    'Tranquilizantes',
    'Alucin\u00f3genos',
    'Opi\u00e1ceos',
    'Otros',
  ];

  bool estaCompleto() {
    if (pregunta.nPregunta != 1) {
      return true;
    }
    switch (tipoKind) {
      case PreguntaTipo.descriptiva:
        return true;
      case PreguntaTipo.abiertas:
        return textController.text.trim().isNotEmpty;
      case PreguntaTipo.seleccionMultiple:
        return seleccionMultiple.isNotEmpty;
      case PreguntaTipo.seleccionUnica:
        return seleccionUnica != null && seleccionUnica!.isNotEmpty;
      case PreguntaTipo.verdaderoFalso:
        return trueAndFalseSeleccion != null;
      case PreguntaTipo.tamizajeRadio:
        return atributoSeleccionado != null;
      case PreguntaTipo.tamizajeSustancias:
        return sustanciaSelecciones.isNotEmpty;
      case PreguntaTipo.condicionante:
        return condicionanteSeleccion != null;
      case PreguntaTipo.desconocido:
        return true;
    }
  }

  RespuestaTestStruct toStruct(int numero) {
    final kind = tipoKind;
    final rawTipo = pregunta.tipo;

    // Collect tamizaje attributes.
    List<AtributosStruct> tamizajeList = [];
    if (kind == PreguntaTipo.tamizajeRadio && atributoSeleccionado != null) {
      tamizajeList = [atributoSeleccionado!];
    } else if (kind == PreguntaTipo.tamizajeSustancias) {
      tamizajeList = sustanciaSelecciones.values.toList();
    } else if (kind == PreguntaTipo.condicionante &&
        condicionanteSeleccion != null) {
      final match = pregunta.respuestaCondicionante
          .where((c) => c.etiqueta == condicionanteSeleccion)
          .toList();
      if (match.isNotEmpty) {
        tamizajeList = [
          AtributosStruct(
            etiqueta: match.first.etiqueta,
            valor: 0,
          ),
        ];
      }
    }

    String respuestaSU = '';
    if (kind == PreguntaTipo.tamizajeRadio && atributoSeleccionado != null) {
      respuestaSU = atributoSeleccionado!.etiqueta;
    } else if (kind == PreguntaTipo.condicionante) {
      respuestaSU = condicionanteSeleccion ?? '';
    } else if (kind == PreguntaTipo.seleccionUnica) {
      respuestaSU = seleccionUnica ?? '';
    }

    return RespuestaTestStruct(
      pregunta: pregunta.pregunta,
      tipo: rawTipo,
      nPregunta: numero,
      respuesta:
          kind == PreguntaTipo.abiertas ? textController.text.trim() : '',
      respuestaSeleccionUnica: respuestaSU,
      respuestasSeleccionadas: kind == PreguntaTipo.seleccionMultiple
          ? seleccionMultiple.toList()
          : <String>[],
      trueAndFalse: trueAndFalseSeleccion,
      respuestaTamizaje: tamizajeList,
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
  final _RespuestaState estado;
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
      return Text(
        '(Pregunta descriptiva — sin respuesta)',
        style: theme.bodySmall.override(
          font: GoogleFonts.inter(fontStyle: FontStyle.italic),
          color: theme.secondaryText,
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
      final opciones = p.respuestaTamizaje;
      if (opciones.isEmpty) {
        return Text(
          'Sin opciones configuradas',
          style: theme.bodySmall,
        );
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
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      );
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

    // Tamizaje (Sustancias) -- dropdown per substance
    if (kind == PreguntaTipo.tamizajeSustancias) {
      final opciones = p.respuestaTamizaje;
      if (opciones.isEmpty) {
        return Text('Sin opciones configuradas', style: theme.bodySmall);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _RespuestaState._sustancias.map((sustancia) {
          final seleccionada = estado.sustanciaSelecciones[sustancia];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    sustancia,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: seleccionada?.etiqueta,
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.alternate),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    hint: Text(
                      'Seleccionar...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.secondaryText,
                      ),
                    ),
                    items: opciones.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt.etiqueta,
                        child: Text('${opt.etiqueta}  (${opt.valor})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final opt = opciones.firstWhere(
                            (o) => o.etiqueta == val);
                        estado.sustanciaSelecciones[sustancia] =
                            AtributosStruct(
                          etiqueta: '$sustancia: ${opt.etiqueta}',
                          valor: opt.valor,
                          ideacionSuicida: opt.ideacionSuicida,
                        );
                        onChanged();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (kind == PreguntaTipo.condicionante) {
      final opciones = p.respuestaCondicionante;
      if (opciones.isEmpty) {
        return Text('Sin opciones condicionantes configuradas',
            style: theme.bodySmall);
      }
      return RadioGroup<String>(
        groupValue: estado.condicionanteSeleccion,
        onChanged: (value) {
          estado.condicionanteSeleccion = value;
          onChanged();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: opciones.map((opt) {
            return RadioListTile<String>(
              value: opt.etiqueta,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                opt.etiqueta,
                style: GoogleFonts.inter(
                  fontWeight: estado.condicionanteSeleccion == opt.etiqueta
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 4 — resultados + notas + recordatorio opcional
// ─────────────────────────────────────────────────────────────────────────────

