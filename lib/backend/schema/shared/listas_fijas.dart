/// Listas fijas compartidas a lo largo de la app.
///
/// Centralizadas aquí para evitar duplicación cuando un mismo catálogo
/// se usa en varios formularios (registro, wizards, edición de perfil, etc.).

/// Opciones de género de los formularios de alta. Deben coincidir con las
/// categorías de las gráficas (`kGeneros` en
/// `components/admin_estadsticas/helpers/classification.dart`).
const List<String> kListaGeneros = ['Masculino', 'Femenino', 'Otro'];

/// Catálogo de EPS (Entidades Promotoras de Salud) disponibles para
/// seleccionar en formularios de registro y actualización de adolescentes.
///
/// Originalmente estaba inline en
/// `lib/user/registration/register_continue2/register_continue2_form2.dart`.
const List<String> kListaEPS = [
  'ACOPI',
  'AMBUQ',
  'ANAWAYU',
  'CAJACOPI',
  'COMFACHOCO',
  'COMFACOR',
  'COMFAMILIAR',
  'COMPENSAR',
  'COOSALUD',
  'DUSAKAWI A.R.S.I.',
  'FAMILIAR',
  'FAMISANAR',
  'FERROCARRILES',
  'MALLAMAS EPSI',
  'MUTUAL SER',
  'NUEVA EPS',
  'SALUD TOTAL',
  'SAVIA SALUD',
  'SURA',
  'NO AFILIADO',
  'SIN EPS REGISTRADA',
];
