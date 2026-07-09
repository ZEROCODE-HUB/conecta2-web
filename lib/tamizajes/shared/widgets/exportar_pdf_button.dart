import '/backend/backend.dart';
import '/dashboard/web/tamizajes/listado_tamizajes/export_helper.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estilo visual del botón de exportar PDF.
enum ExportarPdfStyle { mobile, web }

/// Botón reutilizable para exportar resultados de un tamizaje a PDF.
class ExportarPdfButton extends StatefulWidget {
  const ExportarPdfButton({
    super.key,
    required this.respuesta,
    this.adolescente,
    this.style = ExportarPdfStyle.web,
  });

  final RespuestasRecord respuesta;
  final UsersRecord? adolescente;
  final ExportarPdfStyle style;

  @override
  State<ExportarPdfButton> createState() => _ExportarPdfButtonState();
}

class _ExportarPdfButtonState extends State<ExportarPdfButton> {
  bool _exportando = false;

  Future<void> _exportar() async {
    setState(() => _exportando = true);
    try {
      final preguntas = widget.respuesta.test
          .map((item) => PreguntaExport(
                numero: item.nPregunta,
                pregunta: item.pregunta,
                respuesta: respuestaTexto(item),
              ))
          .toList();

      await exportarResultadosPDF(
        titloTamizaje: widget.respuesta.titlo,
        nombrePaciente: widget.adolescente?.displayName ?? 'Paciente',
        fecha: formatDate(widget.respuesta.fecha),
        puntaje: widget.respuesta.puntajeTotal,
        notas: widget.respuesta.notasProfesional,
        preguntas: preguntas,
        invalidado: widget.respuesta.invalidado,
        hayIdeacionSuicida: hasIdeacion(widget.respuesta.test),
        respuesta: widget.respuesta,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == ExportarPdfStyle.mobile) return _buildMobile();
    return _buildWeb();
  }

  Widget _buildWeb() {
    return ElevatedButton.icon(
      onPressed: _exportando ? null : _exportar,
      icon: _exportando
          ? const SizedBox(
              width: 12.0,
              height: 12.0,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.picture_as_pdf_outlined, size: 14.0),
      label: const Text('Resultados'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kSuccess,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        textStyle: GoogleFonts.inter(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildMobile() {
    return GestureDetector(
      onTap: _exportando ? null : _exportar,
      child: Container(
        height: 40.0,
        decoration: BoxDecoration(
          color: kSuccess,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_exportando)
              const SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.picture_as_pdf_outlined,
                size: 18.0,
                color: Colors.white,
              ),
            const SizedBox(width: 6.0),
            Text(
              'Resultados PDF',
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
