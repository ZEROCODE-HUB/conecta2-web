import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'footer_professionals_model.dart';
export 'footer_professionals_model.dart';

class FooterProfessionalsWidget extends StatefulWidget {
  const FooterProfessionalsWidget({
    super.key,
    required this.active,
  });

  final int? active;

  @override
  State<FooterProfessionalsWidget> createState() =>
      _FooterProfessionalsWidgetState();
}

class _FooterProfessionalsWidgetState extends State<FooterProfessionalsWidget> {
  late FooterProfessionalsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FooterProfessionalsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Con el teclado abierto el menú queda detrás, en su sitio: no se
    // muestra encima del teclado. Vuelve al cerrarlo.
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      height: 75.0,
      decoration: BoxDecoration(
        color: Color(0xFF265294),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Pacientes
          _boton(
            indice: 1,
            ruta: PacientesWidget.routeName,
            icono: 'assets/images/User.png',
            iconoActivo: 'assets/images/User.png',
            png: true,
          ),
          // 2. Recordatorios (seguimientos)
          _boton(
            indice: 2,
            ruta: RecordatoriosWidget.routeName,
            icono: 'assets/images/Alarm_Clock.svg',
            iconoActivo: 'assets/images/Alarm_ClockGray.svg',
          ),
          // 3. Tamizajes manuales (botón central)
          _boton(
            indice: 3,
            ruta: TamizajesProWidget.routeName,
            icono: 'assets/images/TabletGray.svg',
            iconoActivo: 'assets/images/Tablet.svg',
            tamano: 50.0,
          ),
          // 4. Modelos de tamizajes (solo lectura)
          _boton(
            indice: 4,
            ruta: ModelosTamizajesWidget.routeName,
            icono: 'assets/images/DocumentGrey.svg',
            iconoActivo: 'assets/images/Document_2.svg',
          ),
          // 5. Contenidos / Literatura
          _boton(
            indice: 5,
            ruta: LiteraturaProWidget.routeName,
            icono: 'assets/images/BookGrey.svg',
            iconoActivo: 'assets/images/Book.svg',
          ),
        ],
      ),
    );
  }

  /// Botón del menú. Los iconos "activos" son los amarillos; navega con
  /// goNamed para que el menú no apile pantallas.
  Widget _boton({
    required int indice,
    required String ruta,
    required String icono,
    required String iconoActivo,
    double tamano = 30.0,
    bool png = false,
  }) {
    final asset = widget.active == indice ? iconoActivo : icono;
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (widget.active == indice) return;
        context.goNamed(
          ruta,
          extra: <String, dynamic>{
            '__transition_info__': TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 0),
            ),
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: png
            ? Image.asset(asset,
                width: tamano, height: tamano, fit: BoxFit.contain)
            : SvgPicture.asset(asset,
                width: tamano, height: tamano, fit: BoxFit.cover),
      ),
    );
  }
}
