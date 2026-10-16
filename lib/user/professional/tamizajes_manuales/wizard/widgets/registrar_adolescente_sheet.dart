import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/shared/listas_fijas.dart';
import '/backend/schema/shared/ubicacion_colegio.dart';
import '/components/ubicacion_colegio/ubicacion_colegio_readonly.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet to register a brand-new adolescent without leaving the wizard.
class BottomSheetRegistrarAdolescente extends StatefulWidget {
  const BottomSheetRegistrarAdolescente({super.key});

  @override
  State<BottomSheetRegistrarAdolescente> createState() =>
      _BottomSheetRegistrarAdolescenteState();
}

class _BottomSheetRegistrarAdolescenteState
    extends State<BottomSheetRegistrarAdolescente> {
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

  /// Último catálogo de colegios recibido: el municipio y el barrio del
  /// adolescente salen del colegio elegido.
  List<ColegiosRecord> _colegios = const [];
  bool _guardando = false;

  int? get _edadCalculada {
    if (_fechaNacimiento == null) return null;
    final now = DateTime.now();
    int age = now.year - _fechaNacimiento!.year;
    if (now.month < _fechaNacimiento!.month ||
        (now.month == _fechaNacimiento!.month &&
            now.day < _fechaNacimiento!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      DocumentReference? parentRef;
      final parentEmail = _acudienteCorreo.text.trim();
      if (parentEmail.isNotEmpty) {
        final parentUser = await queryUsersRecordOnce(
          queryBuilder: (usersRecord) => usersRecord
              .where('email', isEqualTo: parentEmail)
              .where('rol', whereIn: ['Acudiente', 'Padre']),
          singleRecord: true,
        ).then((s) => s.firstOrNull);
        if (parentUser != null) {
          parentRef = parentUser.reference;
        }
      }

      final ref = FirebaseFirestore.instance.collection('users').doc();
      final ubicacion = ubicacionDeColegio(_colegios, _colegioSeleccionado);
      final data = createUsersRecordData(
        email: _email.text.trim(),
        displayName: _nombre.text.trim(),
        phoneNumber: _telefono.text.trim(),
        rol: 'Adolescente',
        identidad: _identidad.text.trim(),
        genero: _genero ?? '',
        fechaNacimiento: _fechaNacimiento,
        colegio: _colegioSeleccionado ?? '',
        eps: _epsSeleccionada ?? '',
        municipio: ubicacion?.municipio ?? '',
        barrio: ubicacion?.barrio ?? '',
        createdTime: DateTime.now(),
        profesionales: ProfesionalesStruct(
          ref: currentUserReference,
          nombre: currentUserDisplayName,
        ),
        acudiente: AcudienteStruct(
          nombre: _acudienteNombre.text.trim(),
          telefono: _acudienteTelefono.text.trim(),
          correo: parentEmail,
          ref: parentRef,
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

  /// Campo autocompletable (buscador) para catálogos Firestore largos
  /// (colegios, barrios). Mantiene el estilo visual de los demás inputs.
  Widget _buildAutocompleteField({
    required String label,
    required String hint,
    required List<String> opciones,
    required String? valor,
    required ValueChanged<String?> onChanged,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: valor ?? ''),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.toLowerCase();
        if (q.isEmpty) return opciones.take(50);
        return opciones.where((n) => n.toLowerCase().contains(q));
      },
      onSelected: onChanged,
      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: _inputDecoration(label).copyWith(hintText: hint),
          onChanged: (v) => onChanged(v.isEmpty ? null : v),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
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
                      child: Text(
                        option,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 14),
      filled: true,
      fillColor: FlutterFlowTheme.of(context).primaryBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF265294), width: 1.5),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Registrar nuevo adolescente',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.secondaryText),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nombre,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: _inputDecoration('Nombre completo *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: _inputDecoration('Correo'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telefono,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: _inputDecoration('Tel\u00e9fono'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _identidad,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration:
                          _inputDecoration('Documento de identidad'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _genero,
                      decoration: _inputDecoration('G\u00e9nero'),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: theme.primaryText),
                      items: const [
                        DropdownMenuItem(
                            value: 'Masculino', child: Text('Masculino')),
                        DropdownMenuItem(
                            value: 'Femenino', child: Text('Femenino')),
                        DropdownMenuItem(
                            value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (v) => setState(() => _genero = v),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
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
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration:
                            _inputDecoration('Fecha de nacimiento'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fechaNacimiento == null
                                  ? 'Seleccionar fecha'
                                  : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/'
                                      '${_fechaNacimiento!.month.toString().padLeft(2, '0')}/'
                                      '${_fechaNacimiento!.year}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _fechaNacimiento == null
                                    ? theme.secondaryText
                                    : theme.primaryText,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_edadCalculada != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBE5A1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$_edadCalculada a\u00f1os',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF265294),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Icon(Icons.calendar_today,
                                    size: 18, color: theme.secondaryText),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<ColegiosRecord>>(
                      stream: queryColegiosRecord(),
                      builder: (context, snap) {
                        if (snap.data != null) _colegios = snap.data!;
                        final ubicacion =
                            ubicacionDeColegio(_colegios, _colegioSeleccionado);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAutocompleteField(
                              label: 'Colegio',
                              hint: 'Seleccionar colegio',
                              opciones: nombresDeColegios(_colegios),
                              valor: _colegioSeleccionado,
                              onChanged: (v) =>
                                  setState(() => _colegioSeleccionado = v),
                            ),
                            const SizedBox(height: 12),
                            // Municipio y barrio salen del colegio.
                            UbicacionColegioReadonly(
                              municipio: ubicacion?.municipio ?? '',
                              barrio: ubicacion?.barrio ?? '',
                              colegioElegido:
                                  (_colegioSeleccionado ?? '').isNotEmpty,
                              compacto: true,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Datos del acudiente',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _acudienteNombre,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration:
                          _inputDecoration('Nombre del acudiente'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _acudienteTelefono,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration:
                          _inputDecoration('Tel\u00e9fono del acudiente'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _acudienteCorreo,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration:
                          _inputDecoration('Email del acudiente'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _epsSeleccionada,
                      isExpanded: true,
                      decoration: _inputDecoration('EPS'),
                      hint: Text(
                        'Seleccionar EPS',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: theme.secondaryText),
                      ),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: theme.primaryText),
                      items: kListaEPS
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _epsSeleccionada = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Bottom action
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              border: Border(top: BorderSide(color: theme.alternate)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _guardando ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Cancelar',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF265294),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Registrar',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 14)),
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
