import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';


/// Texto de un contenido (artículo) en la app móvil.
///
/// Es un WebView —conserva el formato del HTML (pegado de Word o del
/// editor)— que toma la **altura real del documento**: sin scroll propio,
/// sin cortes y sin espacio en blanco al final. El desplazamiento lo hace la
/// página que lo contiene. Antes cada pantalla usaba un WebView de altura
/// fija (2500 px o la de la pantalla) con scroll interno.
///
/// [html] se muestra tal cual; solo se le agrega el script que mide la
/// altura (y, si [agregarViewport], la etiqueta viewport para que en el
/// teléfono la altura medida coincida con la de Flutter).
class ContenidoHtmlView extends StatefulWidget {
  const ContenidoHtmlView({
    super.key,
    required this.html,
    this.agregarViewport = true,
  });

  final String html;

  /// `false` cuando [html] ya es un documento completo con su viewport.
  final bool agregarViewport;

  @override
  State<ContenidoHtmlView> createState() => _ContenidoHtmlViewState();
}

/// Nombre del canal JS → Dart con la altura del documento.
const _kCanalAltura = 'alturaContenido';
const _kAlturaInicial = 300.0;
const _kAlturaMaxima = 20000.0;

/// Script que mide dónde termina el contenido (marcador al final del body)
/// y lo envía a Dart al cargar, cuando cambia el tamaño (imágenes, fuentes)
/// y con unos reintentos (en la web el canal se conecta tras cargar).
const _kScriptAltura = '''
<div id="fin-contenido-c2" style="height:1px;clear:both"></div>
<script>
(function () {
  var ultima = 0;
  function medir() {
    var fin = document.getElementById('fin-contenido-c2');
    var h = fin
      ? Math.ceil(fin.getBoundingClientRect().bottom + (window.scrollY || 0))
      : document.body.scrollHeight;
    if (!h || h === ultima) return;
    var canal = window.$_kCanalAltura;
    if (!canal) return;
    ultima = h;
    if (typeof canal.postMessage === 'function') {
      canal.postMessage(String(h));
    } else if (typeof canal === 'function') {
      canal(String(h));
    }
  }
  window.addEventListener('load', medir);
  if (window.ResizeObserver) {
    new ResizeObserver(medir).observe(document.body);
  }
  [0, 300, 1000, 2500, 5000].forEach(function (ms) { setTimeout(medir, ms); });
})();
</script>
''';

/// Sin barra de scroll propia: la altura es la del contenido.
const _kEstiloSinScroll =
    '<style>html,body{overflow:hidden !important;}</style>';

const _kViewport =
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">';

/// HTML final: el original + estilo sin scroll + script de altura.
String documentoConAltura(String html, {required bool agregarViewport}) {
  final cabecera = '${agregarViewport ? _kViewport : ''}$_kEstiloSinScroll';
  final cierreBody = html.toLowerCase().lastIndexOf('</body>');
  if (cierreBody == -1) {
    // Fragmento (p. ej. HTML pegado de Word): se envuelve tal cual.
    return '$cabecera\n$html\n$_kScriptAltura';
  }
  final cierreHead = html.toLowerCase().indexOf('</head>');
  var doc = html;
  var fin = cierreBody;
  if (cierreHead != -1) {
    doc = doc.replaceRange(cierreHead, cierreHead, cabecera);
    fin += cabecera.length;
  }
  return doc.replaceRange(fin, fin, _kScriptAltura);
}

class _ContenidoHtmlViewState extends State<ContenidoHtmlView> {
  double _altura = _kAlturaInicial;

  void _recibirAltura(Object? mensaje) {
    final h = double.tryParse(mensaje.toString());
    if (h == null || h <= 0) return;
    final nueva = math.min(h, _kAlturaMaxima);
    if ((nueva - _altura).abs() < 1) return;
    if (mounted) setState(() => _altura = nueva);
  }

  @override
  Widget build(BuildContext context) {
    final contenido = documentoConAltura(
      widget.html,
      agregarViewport: widget.agregarViewport,
    );
    return LayoutBuilder(
      builder: (context, constraints) => WebViewX(
        // Solo se recarga si cambia el texto, no al cambiar la altura.
        key: ValueKey(contenido.hashCode),
        width: constraints.maxWidth,
        height: _altura,
        ignoreAllGestures: false,
        initialContent: contenido,
        initialSourceType: SourceType.html,
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy:
            AutoMediaPlaybackPolicy.requireUserActionForAllMediaTypes,
        dartCallBacks: {
          DartCallback(
            name: _kCanalAltura,
            callBack: (msg) => _recibirAltura(msg),
          ),
        },
        // Los enlaces del artículo se abren fuera de la app.
        navigationDelegate: (request) async {
          final url = request.content.source;
          if (url.startsWith('http://') || url.startsWith('https://')) {
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        webSpecificParams: const WebSpecificParams(
          webAllowFullscreenContent: true,
        ),
        mobileSpecificParams: MobileSpecificParams(
          debuggingEnabled: false,
          gestureNavigationEnabled: false,
          // Sin reconocedores de arrastre: el scroll es el de la página.
          mobileGestureRecognizers: const {},
          androidEnableHybridComposition: true,
        ),
      ),
    );
  }
}
