// Builders for the DataTable columns and rows.

import 'package:flutter/material.dart';

import '../data/substance_data.dart';
import 'table_header.dart';

List<DataColumn> buildDataColumns(
  List<Map<String, String>> ordenColumnas,
  Map<String, bool> columnasVisibles,
) {
  return ordenColumnas
      .where((columna) => columnasVisibles[columna['clave']] ?? true)
      .map((columna) => DataColumn(label: buildHeaderCell(columna['label']!)))
      .toList();
}

List<DataRow> buildDataRows({
  required List<Map<String, dynamic>> datos,
  required List<Map<String, String>> ordenColumnas,
  required Map<String, bool> columnasVisibles,
}) {
  return datos.map((data) {
    final celdas = <DataCell>[];

    for (var columna in ordenColumnas) {
      final clave = columna['clave']!;
      if (columnasVisibles[clave] ?? true) {
        final valor = data[clave]?.toString() ?? '';

        Widget cellContent = buildBodyCell(valor);
        if (clave.endsWith('_RIESGO')) {
          final color = obtenerColorRiesgoParaUI(valor);
          cellContent = Container(
            color: color,
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                valor,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        } else if (valor == 'Sí' || valor == 'No') {
          final color = valor == 'Sí'
              ? const Color(0xFFFFEBEE) // Rojo claro
              : const Color(0xFFF2FBFF); // Gris claro
          cellContent = Container(
            color: color,
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                valor,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      valor == 'Sí' ? const Color(0xFFB42318) : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        celdas.add(DataCell(cellContent));
      }
    }

    return DataRow(cells: celdas);
  }).toList();
}
