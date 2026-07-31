part of '../wizard_tamizaje_manual.dart';

class _PasoSeleccionAdolescente extends StatefulWidget {
  const _PasoSeleccionAdolescente({required this.onSeleccionado});
  final ValueChanged<UsersRecord> onSeleccionado;

  @override
  State<_PasoSeleccionAdolescente> createState() =>
      _PasoSeleccionAdolescenteState();
}

class _PasoSeleccionAdolescenteState extends State<_PasoSeleccionAdolescente> {
  String _filtro = '';

  Future<void> _abrirRegistrarNuevo() async {
    final nuevo = await showDialog<UsersRecord>(
      context: context,
      builder: (_) => const _DialogoRegistrarAdolescente(),
    );
    if (nuevo != null) widget.onSeleccionado(nuevo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final profesionalRef = currentUserReference;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿A quién está encuestando?',
            style: theme.titleMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w700),
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _filtro = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar adolescente asignado…',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.alternate),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _abrirRegistrarNuevo,
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('Registrar nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF265294),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: profesionalRef == null
                ? const Center(child: Text('Sin sesión'))
                : StreamBuilder<List<UsersRecord>>(
                    stream: queryUsersRecord(
                      queryBuilder: (q) => q.where(
                        'Profesionales.Ref',
                        isEqualTo: profesionalRef,
                      ),
                    ),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final filtrados = snap.data!.where((u) {
                        final n = u.displayName.toLowerCase();
                        return n.contains(_filtro.toLowerCase());
                      }).toList();
                      if (filtrados.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay adolescentes asignados',
                            style: theme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final u = filtrados[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF265294)
                                  .withValues(alpha: 0.12),
                              child: Text(
                                u.displayName.isNotEmpty
                                    ? u.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Color(0xFF265294),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text(u.displayName.isNotEmpty
                                ? u.displayName
                                : u.email),
                            subtitle: Text(u.email),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => widget.onSeleccionado(u),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DialogoRegistrarAdolescente extends StatefulWidget {
  const _DialogoRegistrarAdolescente();

  @override
  State<_DialogoRegistrarAdolescente> createState() =>
      _DialogoRegistrarAdolescenteState();
}

class _DialogoRegistrarAdolescenteState
    extends State<_DialogoRegistrarAdolescente> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _identidad = TextEditingController();
  final _acudienteNombre = TextEditingController();
  final _acudienteTelefono = TextEditingController();
  final _acudienteCorreo = TextEditingController();
  String? _genero;
  DateTime? _fechaNacimiento;
  String? _colegioSeleccionado;
  String? _epsSeleccionada;
  String? _barrioSeleccionado;
  List<String> _colegiosOpciones = const [];
  List<String> _barriosOpciones = const [];
  bool _cargandoCatalogos = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _telefono.dispose();
    _identidad.dispose();
    _acudienteNombre.dispose();
    _acudienteTelefono.dispose();
    _acudienteCorreo.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    try {
      final resultados = await Future.wait([
        queryColegiosRecordOnce(),
        queryBarriosRecordOnce(),
      ]);
      final colegios = (resultados[0] as List<ColegiosRecord>)
          .map((c) => c.nombre)
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      final barrios = (resultados[1] as List<BarriosRecord>)
          .map((b) => b.nombre)
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _colegiosOpciones = colegios;
        _barriosOpciones = barrios;
        _cargandoCatalogos = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargandoCatalogos = false);
    }
  }

  int? get _edadCalculada {
    if (_fechaNacimiento == null) return null;
    final hoy = DateTime.now();
    int edad = hoy.year - _fechaNacimiento!.year;
    if (hoy.month < _fechaNacimiento!.month ||
        (hoy.month == _fechaNacimiento!.month &&
            hoy.day < _fechaNacimiento!.day)) {
      edad--;
    }
    return edad;
  }

  static const _borderRadius = BorderRadius.all(Radius.circular(8));
  static const _inputBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: Color(0xFFD0D5DD)),
  );
  static const _focusedBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: Color(0xFF6366F1), width: 1.5),
  );

  InputDecoration _inputDecoration(String label, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        border: _inputBorder,
        enabledBorder: _inputBorder,
        focusedBorder: _focusedBorder,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Divider(thickness: 1, color: Color(0xFFE5E7EB)),
            ),
          ],
        ),
      );

  /// Campo autocompletable (buscador) respaldado por un catálogo Firestore.
  /// Usado para Colegio y Barrio donde la lista puede ser larga (>100).
  Widget _buildAutocompleteCatalogo({
    required String label,
    required String hint,
    required List<String> opciones,
    required String? valorSeleccionado,
    required ValueChanged<String?> onSeleccionado,
  }) {
    if (_cargandoCatalogos) {
      return InputDecorator(
        decoration: _inputDecoration(label, hint: 'Cargando...'),
        child: const SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: valorSeleccionado ?? ''),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.toLowerCase();
        if (q.isEmpty) return opciones.take(50);
        return opciones.where((n) => n.toLowerCase().contains(q));
      },
      onSelected: onSeleccionado,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: _inputDecoration(label, hint: hint),
          onChanged: (v) {
            // Solo guardamos el valor si coincide con alguna opción;
            // permitimos texto libre también.
            onSeleccionado(v.isEmpty ? null : v);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 492),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final identidad = _identidad.text.trim();
    final email = _email.text.trim();
    final telefono = _telefono.text.trim();
    final acudienteNombre = _acudienteNombre.text.trim();
    final acudienteTelefono = _acudienteTelefono.text.trim();
    final acudienteCorreo = _acudienteCorreo.text.trim();
    
    if (nombre.isEmpty ||
        identidad.isEmpty ||
        _genero == null || _genero!.isEmpty ||
        _fechaNacimiento == null ||
        email.isEmpty ||
        _colegioSeleccionado == null || _colegioSeleccionado!.isEmpty ||
        _epsSeleccionada == null || _epsSeleccionada!.isEmpty ||
        _barrioSeleccionado == null || _barrioSeleccionado!.isEmpty ||
        acudienteNombre.isEmpty ||
        acudienteTelefono.isEmpty ||
        acudienteCorreo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos obligatorios (solo el teléfono del adolescente es opcional)')),
      );
      return;
    }
    
    // Validar correo
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese un correo válido')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      // Verificar si el correo ya existe
      final usuariosExistentes = await queryUsersRecordOnce(
        queryBuilder: (q) => q.where('email', isEqualTo: email),
        limit: 1,
      );
      
      if (usuariosExistentes.isNotEmpty) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El correo ingresado ya se encuentra registrado')),
            );
            setState(() => _guardando = false);
         }
         return;
      }

      DocumentReference? parentRef;
      if (acudienteCorreo.isNotEmpty) {
        final parentUser = await queryUsersRecordOnce(
          queryBuilder: (usersRecord) => usersRecord
              .where('email', isEqualTo: acudienteCorreo)
              .where('rol', whereIn: ['Acudiente', 'Padre']),
          singleRecord: true,
        ).then((s) => s.firstOrNull);
        if (parentUser != null) {
          parentRef = parentUser.reference;
        }
      }

      final ref = FirebaseFirestore.instance.collection('users').doc();
      final data = createUsersRecordData(
        email: email,
        displayName: nombre,
        phoneNumber: telefono,
        rol: 'Adolescente',
        identidad: identidad,
        genero: _genero ?? '',
        fechaNacimiento: _fechaNacimiento,
        colegio: _colegioSeleccionado ?? '',
        eps: _epsSeleccionada ?? '',
        barrio: _barrioSeleccionado ?? '',
        createdTime: DateTime.now(),
        acudiente: AcudienteStruct(
          nombre: acudienteNombre,
          telefono: acudienteTelefono,
          correo: acudienteCorreo,
          ref: parentRef,
        ),
        profesionales: ProfesionalesStruct(
          ref: currentUserReference,
          nombre: currentUserDisplayName,
        ),
      );
      await ref.set(data);
      final nuevo = await UsersRecord.getDocumentOnce(ref);
      if (mounted) Navigator.of(context).pop(nuevo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded,
                  color: Color(0xFF6366F1), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Registrar nuevo adolescente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Datos del adolescente ──
              _sectionHeader('Datos del adolescente'),
              TextField(
                controller: _nombre,
                decoration: _inputDecoration('Nombre completo *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _identidad,
                decoration: _inputDecoration('Documento de identidad'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _genero,
                decoration: _inputDecoration('Genero'),
                items: const [
                  DropdownMenuItem(
                      value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _genero = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: _borderRadius,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaNacimiento ??
                              DateTime.now()
                                  .subtract(const Duration(days: 365 * 14)),
                          firstDate: DateTime(1990),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _fechaNacimiento = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration('Fecha de nacimiento'),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Color(0xFF6366F1)),
                            const SizedBox(width: 8),
                            Text(
                              _fechaNacimiento == null
                                  ? 'Seleccionar fecha'
                                  : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}',
                              style: TextStyle(
                                color: _fechaNacimiento == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_edadCalculada != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                      ),
                      child: Text(
                        '$_edadCalculada años',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ── Contacto ──
              const SizedBox(height: 8),
              _sectionHeader('Contacto'),
              TextField(
                controller: _email,
                decoration: _inputDecoration('Correo'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefono,
                decoration: _inputDecoration('Telefono'),
                keyboardType: TextInputType.phone,
              ),

              // ── Informacion adicional ──
              const SizedBox(height: 8),
              _sectionHeader('Informacion adicional'),
              _buildAutocompleteCatalogo(
                label: 'Colegio',
                hint: 'Seleccionar colegio',
                opciones: _colegiosOpciones,
                valorSeleccionado: _colegioSeleccionado,
                onSeleccionado: (v) => setState(() => _colegioSeleccionado = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _epsSeleccionada,
                isExpanded: true,
                decoration: _inputDecoration('EPS', hint: 'Seleccionar EPS'),
                hint: const Text('Seleccionar EPS'),
                items: kListaEPS
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _epsSeleccionada = v),
              ),
              const SizedBox(height: 12),
              _buildAutocompleteCatalogo(
                label: 'Barrio',
                hint: 'Seleccionar barrio',
                opciones: _barriosOpciones,
                valorSeleccionado: _barrioSeleccionado,
                onSeleccionado: (v) => setState(() => _barrioSeleccionado = v),
              ),

              // ── Acudiente ──
              const SizedBox(height: 8),
              _sectionHeader('Acudiente (Tutor)'),
              TextField(
                controller: _acudienteNombre,
                decoration: _inputDecoration('Nombre del acudiente'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _acudienteTelefono,
                decoration: _inputDecoration('Telefono del acudiente'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _acudienteCorreo,
                decoration: _inputDecoration('Email del acudiente'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _guardando
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Registrar'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 2 — selección del tamizaje
// ─────────────────────────────────────────────────────────────────────────────
