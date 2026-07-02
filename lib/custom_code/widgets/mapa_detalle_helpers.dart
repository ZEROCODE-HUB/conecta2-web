part of 'mapa_instituciones_educativas.dart';

extension _MapaInstitucionesHelpers on _MapaInstitucionesEducativasState {
  // MÉTODO ACTUALIZADO: Mostrar detalle de institución
  void _mostrarDetalleInstitucion(Map<String, dynamic> institucion) {
    setState(() {
      isDialogOpen = true;
    });

    Color darkYellow = Color(0xFFF6BD33);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getInstitucionStats(institucion['nombre']),
              builder: (context, snapshot) {
                final stats = snapshot.data ??
                    {
                      'totalUsuarios': 0,
                      'respuestasPorTamizaje': {},
                      'tamizajesRespondidos': [],
                    };
                final respuestasPorTamizaje =
                    stats['respuestasPorTamizaje'] as Map<String, int>;
                final tamizajesRespondidos =
                    stats['tamizajesRespondidos'] as List<dynamic>;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CONECTA2',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkYellow,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.close, color: Colors.grey[600]),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  setState(() {
                                    isDialogOpen = false;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(height: 1, thickness: 1),
                        ],
                      ),
                    ),
                    // Content
                    Flexible(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        darkYellow),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando estadísticas...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre de la institución
                                  Text(
                                    institucion['nombre'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  // Dirección
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${institucion['direccion']}, ${institucion['barrio']}, ${institucion['municipio']}, Colombia',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),

                                  // Total de adolescentes
                                  Text(
                                    'Total de adolescentes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: darkYellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: darkYellow.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${stats['totalUsuarios']}',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: darkYellow,
                                          ),
                                        ),
                                        Text(
                                          'Estudiantes',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  // Tamizajes respondidos
                                  Text(
                                    'Tamizajes respondidos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  if (tamizajesRespondidos.isEmpty)
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'No hay tamizajes respondidos por estudiantes de esta institución',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ...tamizajesRespondidos
                                        .map((nombreTamizaje) {
                                      final respuestas = respuestasPorTamizaje[
                                              nombreTamizaje] ??
                                          0;
                                      final porcentaje =
                                          stats['totalUsuarios'] > 0
                                              ? (respuestas /
                                                      stats['totalUsuarios'] *
                                                      100)
                                                  .clamp(0, 100)
                                                  .toStringAsFixed(1)
                                              : '0.0';

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.assignment_turned_in,
                                                  size: 18,
                                                  color: darkYellow,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    nombreTamizaje,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '$respuestas respuestas',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkYellow,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: darkYellow
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  // child: Text(
                                                  //   '$porcentaje%',
                                                  //   style: TextStyle(
                                                  //     fontSize: 13,
                                                  //     fontWeight:
                                                  //         FontWeight.w600,
                                                  //     color: darkYellow,
                                                  //   ),
                                                  // ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),

                                  SizedBox(height: 20),

                                  // Información adicional
                                  Container(
                                    padding: EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoItem(
                                            'Tipo',
                                            institucion['tipo'] ??
                                                'DESCONOCIDO'),
                                        SizedBox(height: 8),
                                        _buildInfoItem(
                                            'Código DANE',
                                            institucion['codigo'] ??
                                                'Sin código'),
                                        SizedBox(height: 8),
                                        _buildInfoItem(
                                            'Barrio',
                                            institucion['barrio'] ??
                                                'Sin barrio'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).then((value) {
      setState(() {
        isDialogOpen = false;
      });
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
