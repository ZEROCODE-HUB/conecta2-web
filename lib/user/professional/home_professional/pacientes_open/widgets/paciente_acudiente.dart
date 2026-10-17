import '/auth/correo_registrado.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Button + bottom-sheet flow to edit the acudiente of a patient. The button
/// itself is rendered via [EditAcudienteButton]; the dialog is shown by
/// [showEditAcudienteDialog].
class EditAcudienteButton extends StatelessWidget {
  const EditAcudienteButton({super.key, required this.user, this.onSaved});

  final UsersRecord user;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await showEditAcudienteDialog(context, user);
          onSaved?.call();
        },
        child: Container(
          width: double.infinity,
          height: 40.0,
          decoration: BoxDecoration(
            color: const Color(0xFF265294),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, color: Colors.white, size: 18.0),
              const SizedBox(width: 8.0),
              Text(
                'Editar acudiente',
                style: bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontStyle: bodyMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: bodyMedium.fontStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showEditAcudienteDialog(
  BuildContext context,
  UsersRecord userRecord,
) async {
  final nombreController =
      TextEditingController(text: userRecord.acudiente.nombre);
  final correoController =
      TextEditingController(text: userRecord.acudiente.correo);
  final telefonoController =
      TextEditingController(text: userRecord.acudiente.telefono);
  final parentescoController =
      TextEditingController(text: userRecord.acudiente.parentesco);

  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, 'Editar Acudiente'),
              const SizedBox(height: 16.0),
              _labeledField(
                context,
                label: 'Nombre',
                controller: nombreController,
                hint: 'Nombre del acudiente',
              ),
              const SizedBox(height: 12.0),
              _labeledField(
                context,
                label: 'Correo',
                controller: correoController,
                hint: 'Correo del acudiente',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12.0),
              _labeledField(
                context,
                label: 'Telefono',
                controller: telefonoController,
                hint: 'Telefono del acudiente',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12.0),
              _labeledField(
                context,
                label: 'Parentesco',
                controller: parentescoController,
                hint: 'Parentesco',
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: _sheetButton(
                      context,
                      label: 'Cancelar',
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      onTap: () => Navigator.pop(sheetContext),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _sheetButton(
                      context,
                      label: 'Guardar',
                      color: const Color(0xFF265294),
                      textColor: Colors.white,
                      onTap: () async {
                        // Correo en minúsculas: "Mis Adolescentes" del
                        // acudiente lo busca con su correo de acceso (Auth).
                        DocumentReference? parentRef =
                            userRecord.acudiente.ref;
                        final correoVal =
                            normalizarCorreo(correoController.text);
                        if (correoVal !=
                            normalizarCorreo(userRecord.acudiente.correo)) {
                          // Correo nuevo: la ref es la de su cuenta o
                          // ninguna, nunca la del acudiente anterior.
                          parentRef = null;
                          if (correoVal.isNotEmpty) {
                            final perfil = await perfilConCorreo(correoVal);
                            if (perfil != null &&
                                (perfil.rol == 'Acudiente' ||
                                    perfil.rol == 'Padre')) {
                              parentRef = perfil.reference;
                            }
                          }
                        }

                        await userRecord.reference.update(
                          createUsersRecordData(
                            acudiente: createAcudienteStruct(
                              nombre: nombreController.text.trim(),
                              correo: correoVal,
                              telefono: telefonoController.text.trim(),
                              parentesco: parentescoController.text.trim(),
                              ref: parentRef,
                              // Con clearUnsetFields: false un ref null no se
                              // escribe: hay que borrar el anterior.
                              fieldValues: parentRef == null
                                  ? {'ref': FieldValue.delete()}
                                  : const {},
                              clearUnsetFields: false,
                            ),
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      );
    },
  );
}

Widget _title(BuildContext context, String text) {
  final titleMedium = FlutterFlowTheme.of(context).titleMedium;
  return Text(
    text,
    style: titleMedium.override(
      font: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontStyle: titleMedium.fontStyle,
      ),
      letterSpacing: 0.0,
      fontWeight: FontWeight.w600,
      fontStyle: titleMedium.fontStyle,
    ),
  );
}

Widget _labeledField(
  BuildContext context, {
  required String label,
  required TextEditingController controller,
  required String hint,
  TextInputType? keyboardType,
}) {
  final bodySmall = FlutterFlowTheme.of(context).bodySmall;
  final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: bodySmall.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontStyle: bodySmall.fontStyle,
          ),
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
          fontStyle: bodySmall.fontStyle,
        ),
      ),
      const SizedBox(height: 4.0),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontStyle: bodyMedium.fontStyle,
          ),
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
          fontStyle: bodyMedium.fontStyle,
        ),
      ),
    ],
  );
}

Widget _sheetButton(
  BuildContext context, {
  required String label,
  required Color color,
  required VoidCallback onTap,
  Color? textColor,
}) {
  final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 44.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          label,
          style: bodyMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontStyle: bodyMedium.fontStyle,
            ),
            color: textColor,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
            fontStyle: bodyMedium.fontStyle,
          ),
        ),
      ),
    ),
  );
}
