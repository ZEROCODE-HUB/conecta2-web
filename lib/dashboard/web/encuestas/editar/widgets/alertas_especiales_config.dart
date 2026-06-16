import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';

import '../editar_encuesta_model.dart';

/// CRQ/SRQ special alerts configuration. Lets the editor define
/// named rules such as "Puntaje igual a N" or "Al menos dos en Sí"
/// over a chosen subset of question numbers.
class AlertasEspecialesConfig extends StatelessWidget {
  final EditarEncuestaModel model;
  final DocumentReference encuestaID;
  final VoidCallback onUpdate;

  const AlertasEspecialesConfig({
    super.key,
    required this.model,
    required this.encuestaID,
    required this.onUpdate,
  });

  static const List<String> _condiciones = [
    'Todas en Sí',
    'Al menos una en Sí',
    'Al menos dos en Sí',
    'Todas en No',
    'Al menos una en No',
    'Al menos dos en No',
    'Puntaje igual a',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EncuestasRecord>(
      stream: EncuestasRecord.getDocument(encuestaID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final encuesta = snapshot.data!;
        if (encuesta.categoria != 'CRQ / SRQ' &&
            encuesta.categoria != 'CRQ' &&
            encuesta.categoria != 'SRQ') {
          return const SizedBox.shrink();
        }

        final tema = FlutterFlowTheme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 50.0,
                color: Color(0x26000000),
                offset: Offset(20.0, 20.0),
              )
            ],
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 12.0, 0.0, 15.0),
                child: Text(
                  'Alertas Especiales CRQ/SRQ',
                  style: tema.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              TextFormField(
                controller: model.alertaEspecialNombreController,
                focusNode: model.alertaEspecialNombreFocus,
                decoration: InputDecoration(
                  hintText: 'Nombre de la alerta',
                  filled: true,
                  fillColor: tema.primaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: FlutterFlowDropDown<String>(
                  controller: model.alertaEspecialCondicionController ??=
                      FormFieldController<String>(null),
                  options: _condiciones,
                  onChanged: (val) {
                    model.alertaEspecialCondicionValue = val;
                    onUpdate();
                  },
                  width: double.infinity,
                  height: 44.0,
                  textStyle: tema.bodyMedium,
                  hintText: 'Condición...',
                  fillColor: tema.secondaryBackground,
                  elevation: 2.0,
                  borderColor: Colors.transparent,
                  borderWidth: 0.0,
                  borderRadius: 8.0,
                  margin: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 0.0, 12.0, 0.0),
                  hidesUnderline: true,
                  isSearchable: false,
                  isMultiSelect: false,
                ),
              ),
              if (model.alertaEspecialCondicionValue == 'Puntaje igual a')
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 10.0, 0.0, 0.0),
                  child: TextFormField(
                    controller: model.alertaEspecialPuntajeController,
                    focusNode: model.alertaEspecialPuntajeFocus,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Puntaje',
                      filled: true,
                      fillColor: tema.primaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: TextFormField(
                  controller: model.alertaEspecialPreguntasController,
                  focusNode: model.alertaEspecialPreguntasFocus,
                  decoration: InputDecoration(
                    hintText: 'Números de pregunta (ej: 1, 2, 11)',
                    filled: true,
                    fillColor: tema.primaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () => _agregarAlerta(context),
                  text: 'Agregar alerta especial',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 40.0,
                    color: const Color(0xFF265294),
                    textStyle: tema.titleSmall.override(color: Colors.white),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              if (encuesta.alertasEspeciales.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 12.0, 0.0, 0.0),
                  child: _buildListaGuardadas(context, encuesta),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _agregarAlerta(BuildContext context) async {
    final nombre = model.alertaEspecialNombreController.text.trim();
    final condicion = model.alertaEspecialCondicionValue;
    if (nombre.isEmpty || condicion == null) return;

    final preguntasParsed = model.alertaEspecialPreguntasController.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();

    final nueva = createAlertaEspecialStruct(
      nombre: nombre,
      condicion: condicion,
      puntaje: int.tryParse(model.alertaEspecialPuntajeController.text) ?? 0,
      clearUnsetFields: false,
    );
    nueva.preguntas = preguntasParsed;

    await encuestaID.update({
      ...mapToFirestore({
        'alertasEspeciales': FieldValue.arrayUnion([
          getAlertaEspecialFirestoreData(nueva, true),
        ]),
      }),
    });

    model.alertaEspecialNombreController.clear();
    model.alertaEspecialCondicionController?.value = null;
    model.alertaEspecialCondicionValue = null;
    model.alertaEspecialPuntajeController.clear();
    model.alertaEspecialPreguntasController.clear();
    onUpdate();
  }

  Widget _buildListaGuardadas(BuildContext context, EncuestasRecord encuesta) {
    final tema = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas especiales guardadas',
          style: tema.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w500),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.0,
          ),
        ),
        for (final alerta in encuesta.alertasEspeciales)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: tema.primaryBackground,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.nombre,
                        style: tema.bodyMedium.override(
                          font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        alerta.condicion +
                            (alerta.condicion == 'Puntaje igual a'
                                ? ': ${alerta.puntaje}'
                                : ''),
                        style: tema.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20.0),
                  onPressed: () async {
                    await encuestaID.update({
                      ...mapToFirestore({
                        'alertasEspeciales': FieldValue.arrayRemove([
                          getAlertaEspecialFirestoreData(
                            updateAlertaEspecialStruct(alerta,
                                clearUnsetFields: false),
                            true,
                          ),
                        ]),
                      }),
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
