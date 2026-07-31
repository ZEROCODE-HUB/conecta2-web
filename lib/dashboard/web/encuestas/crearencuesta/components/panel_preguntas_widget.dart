import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '../crearencuesta_model.dart';
import '../pregunta_card_widget.dart';
import '/dashboard/web/encuestas/model/emptytest/emptytest_widget.dart';

class PanelPreguntasWidget extends StatelessWidget {
  final CrearencuestaModel model;
  final VoidCallback onUpdate;

  const PanelPreguntasWidget({
    super.key,
    required this.model,
    required this.onUpdate,
  });



  @override
  Widget build(BuildContext context) {
    final preguntas = model.preguntasBuffer;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPreguntasList(preguntas),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreguntasList(List<PreguntasEncuestaStruct> preguntas) {
    if (preguntas.isEmpty) {
      return const Center(child: EmptytestWidget());
    }
    final placeholder = EncuestasRecord.getDocumentFromData(
      createEncuestasRecordData(categoria: model.categoria),
      EncuestasRecord.collection.doc('__buffer__'),
    );
    return ListView.builder(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      itemCount: preguntas.length,
      itemBuilder: (context, index) {
        return PreguntaCard(
          pregunta: preguntas[index],
          encuestasRecord: placeholder,
          index: index,
          categoria: model.categoria,
          onDelete: () {
            model.removeAtIndexFromPreguntasBuffer(index);
            onUpdate();
          },
          onEdit: (updatedPregunta) {
            model.preguntasBuffer[index] = updatedPregunta;
            onUpdate();
          },
        );
      },
    );
  }
}
