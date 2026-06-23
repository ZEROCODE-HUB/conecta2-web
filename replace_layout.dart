import 'dart:io';

void main() {
  final file = File('lib/user/home/home_widget.dart');
  String content = file.readAsStringSync();

  // Pattern 1:
  // Replace the opening part of the Stack with a Row
  // and remove the extra Align around it.
  content = content.replaceAll(
      '''                                        Expanded(
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Stack(
                                              alignment: AlignmentDirectional(
                                                  1.0, 0.0),
                                              children: [''',
      '''                                        Expanded(
                                          child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [''');

  // Pattern 2: For ChicoRecurso (Card 1)
  content = content.replaceAll(
      '''                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/ChicoRecurso.png',
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.04, -0.76),
                                                  child: Container(
                                                    width: 150.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(),
                                                    child: Text(''',
      '''                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/ChicoRecurso.png',
                                                      width: 150.0,
                                                      height: 150.0,
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 15.0, 15.0),
                                                    child: Text(''');

  // Pattern 3: For ChicaRecurso2 (Card 2)
  content = content.replaceAll(
      '''                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/ChicaRecurso2.png',
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.63, -0.01),
                                                  child: Text(''',
      '''                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/ChicaRecurso2.png',
                                                      width: 150.0,
                                                      height: 150.0,
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 15.0, 15.0),
                                                    child: Text(''');

  // Pattern 4: Replace the end of the Text block for Card 1
  content = content.replaceAll(
      '''                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 10.0, 10.0, 0.0),''',
      '''                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 10.0, 10.0, 0.0),''');

  file.writeAsStringSync(content);
}
