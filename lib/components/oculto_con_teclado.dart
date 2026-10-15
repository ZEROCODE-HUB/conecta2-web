import 'package:flutter/material.dart';

/// Oculta [child] mientras el teclado está abierto, para que un menú fijo
/// quede detrás del teclado, en su sitio, en lugar de subir con él.
///
/// Lee los insets reales de la ventana (`View.of`) y no `MediaQuery`: dentro
/// del body de un `Scaffold` con `resizeToAvoidBottomInset` (el valor por
/// defecto), `MediaQuery.viewInsetsOf(context).bottom` siempre vale 0 porque
/// el `Scaffold` recorta ese inset.
class OcultoConTeclado extends StatefulWidget {
  const OcultoConTeclado({super.key, required this.child});

  final Widget child;

  @override
  State<OcultoConTeclado> createState() => _OcultoConTecladoState();
}

class _OcultoConTecladoState extends State<OcultoConTeclado>
    with WidgetsBindingObserver {
  bool? _tecladoAbierto;

  bool _leerTeclado() => View.of(context).viewInsets.bottom > 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final abierto = _leerTeclado();
    if (abierto != _tecladoAbierto) {
      setState(() => _tecladoAbierto = abierto);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tecladoAbierto ??= _leerTeclado();
    return _tecladoAbierto! ? const SizedBox.shrink() : widget.child;
  }
}
