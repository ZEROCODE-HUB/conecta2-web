// Aggregates tamizaje Respuestas into per-type stats for the admin dashboard.
//
// Pure domain logic (nivel classification, gender/age normalization, bucket
// mapping) lives in `classification.dart` so it can be unit-tested without
// Firebase. This file keeps the impure parts: fetching documents and
// aggregating the classified responses.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import 'classification.dart';

// Re-export pure helpers so widgets can keep importing a single file.
export 'classification.dart';

/// Canonical tamizaje types handled by the statistics screen.
enum TamizajeTipo {
  todas,
  autoestima,
  ansiedad,
  cdi,
  beck,
  crq,
  srq,
  sustancias,
}

extension TamizajeTipoX on TamizajeTipo {
  String get label {
    switch (this) {
      case TamizajeTipo.todas:
        return 'Todas';
      case TamizajeTipo.autoestima:
        return 'Autoestima';
      case TamizajeTipo.ansiedad:
        return 'Ansiedad';
      case TamizajeTipo.cdi:
        return 'CDI';
      case TamizajeTipo.beck:
        return 'Beck';
      case TamizajeTipo.crq:
        return 'CRQ';
      case TamizajeTipo.srq:
        return 'SRQ';
      case TamizajeTipo.sustancias:
        return 'Sustancias';
    }
  }

  /// Labels for the level distribution axis (ordered low -> critical).
  List<String> get niveles {
    switch (this) {
      case TamizajeTipo.autoestima:
        return const ['Baja', 'Media', 'Elevada'];
      case TamizajeTipo.ansiedad:
        return const ['Sin sintomatología', 'Leve', 'Moderado', 'Severo'];
      case TamizajeTipo.cdi:
        return const ['Sin sintomatología', 'Leve', 'Severo'];
      case TamizajeTipo.beck:
        return const ['Mínima', 'Leve', 'Moderada', 'Grave'];
      case TamizajeTipo.crq:
        return const ['Sin alerta', 'Subescala 1', 'Subescala 2'];
      case TamizajeTipo.srq:
        return const ['Sin alerta', 'Subescala 1', 'Subescala 2'];
      case TamizajeTipo.sustancias:
        return const ['Sin alerta', 'Moderada', 'Severo'];
      case TamizajeTipo.todas:
        return const ['Sin alerta', 'Moderada', 'Severo', 'Grave'];
    }
  }
}

bool _matchesTipo(TamizajeTipo tipo, String titulo) {
  if (tipo == TamizajeTipo.todas) return true;
  final key = tipoKeyFromTitulo(titulo);
  final isLegacy = titulo.toLowerCase().contains('crq / srq') ||
      titulo.toLowerCase().contains('crq/srq');
  switch (tipo) {
    case TamizajeTipo.autoestima:
      return key == 'autoestima';
    case TamizajeTipo.ansiedad:
      return key == 'ansiedad';
    case TamizajeTipo.cdi:
      return key == 'cdi';
    case TamizajeTipo.beck:
      return key == 'bdi';
    case TamizajeTipo.crq:
      return key == 'crq' || isLegacy;
    case TamizajeTipo.srq:
      return key == 'srq' || isLegacy;
    case TamizajeTipo.sustancias:
      return key == 'sustancias';
    case TamizajeTipo.todas:
      return true;
  }
}

TamizajeTipo _resolveTipoForTitulo(String titulo) {
  final key = tipoKeyFromTitulo(titulo);
  switch (key) {
    case 'autoestima':
      return TamizajeTipo.autoestima;
    case 'ansiedad':
      return TamizajeTipo.ansiedad;
    case 'cdi':
      return TamizajeTipo.cdi;
    case 'bdi':
      return TamizajeTipo.beck;
    case 'crq':
      return TamizajeTipo.crq;
    case 'srq':
      return TamizajeTipo.srq;
    case 'sustancias':
      return TamizajeTipo.sustancias;
    default:
      if (titulo.toLowerCase().contains('crq') &&
          titulo.toLowerCase().contains('srq')) {
        return TamizajeTipo.srq;
      }
      return TamizajeTipo.todas;
  }
}

/// A single classified response, ready to be aggregated.
class ClassifiedResponse {
  final String nivel; // maps to one of TamizajeTipo.niveles entries
  final String genero; // Masculino | Femenino | Otro
  final int? edad;
  final TamizajeTipo tipo;

  ClassifiedResponse({
    required this.nivel,
    required this.genero,
    required this.edad,
    required this.tipo,
  });

  String get rangoEdad => rangoEdadFromEdad(edad);
}

/// Aggregated counts returned to the chart widgets.
class StatsAggregates {
  final TamizajeTipo tipo;
  final int total;
  final List<String> niveles;
  final Map<String, Map<String, int>> porGenero; // genero -> nivel -> count
  final Map<String, Map<String, int>> porEdad; // rango -> nivel -> count
  final Map<String, int> distribucion; // nivel -> count
  final String categoria;

  StatsAggregates({
    required this.tipo,
    required this.total,
    required this.niveles,
    required this.porGenero,
    required this.porEdad,
    required this.distribucion,
    required this.categoria,
  });

  static StatsAggregates empty(TamizajeTipo tipo) => StatsAggregates(
        tipo: tipo,
        total: 0,
        niveles: tipo.niveles,
        porGenero: const {},
        porEdad: const {},
        distribucion: const {},
        categoria: categoriaForTipo(tipo) ?? '',
      );
}

/// Returns the encuesta categoria string for a given [TamizajeTipo].
/// Returns `null` for [TamizajeTipo.todas].
String? categoriaForTipo(TamizajeTipo tipo) {
  switch (tipo) {
    case TamizajeTipo.autoestima:
      return 'Escala autoestima';
    case TamizajeTipo.ansiedad:
      return 'Ansiedad';
    case TamizajeTipo.cdi:
      return 'CDI';
    case TamizajeTipo.beck:
      return 'Depresión Beck';
    case TamizajeTipo.crq:
      return 'CRQ';
    case TamizajeTipo.srq:
      return 'SRQ';
    case TamizajeTipo.sustancias:
      return 'Consumo de SPA';
    case TamizajeTipo.todas:
      return null;
  }
}

/// Loads published encuestas for the selector. When [tipo] is [TamizajeTipo.todas],
/// returns every tamizaje; otherwise filters by family (Autoestima, CDI, etc.).
Future<List<String>> loadEncuestasByTipo(
  TamizajeTipo tipo,
) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('Encuestas')
        .where('tipo', isEqualTo: 'Tamizajes')
        .where('Publicado', isEqualTo: true)
        .get()
        .timeout(const Duration(seconds: 10));
    final rawDocs = snap.docs;
    final filteredDocs = tipo == TamizajeTipo.todas
        ? rawDocs
        : rawDocs.where((d) {
            final titulo = (d.data()['titulo'] ?? '').toString();
            return _matchesTipo(tipo, titulo);
          });
    final setTitulos = filteredDocs
        .map((d) => (d.data()['titulo'] ?? '').toString())
        .where((t) => t.isNotEmpty)
        .toSet();
    final list = setTitulos.toList();
    list.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    return list;
  } catch (_) {
    return [];
  }
}

/// Fetches and classifies all Respuestas for a given tamizaje type.
Future<StatsAggregates> loadStats(
  TamizajeTipo tipo, {
  String? colegio,
  DateTimeRange? rango,
  String? tituloEncuesta,
  String? nivelAlerta,
  DocumentReference? profesionalRef,
}) async {
  final responses = <ClassifiedResponse>[];
  final userCache = <String, Map<String, dynamic>>{};
  final nivelesEje = tipo.niveles;

  try {
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs;

    if (profesionalRef != null) {
      final patientsSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('Profesionales.Ref', isEqualTo: profesionalRef)
          .get()
          .timeout(const Duration(seconds: 15));

      final patients = patientsSnap.docs
          .where((d) => d.data()['rol'] == 'Adolescente')
          .toList();
      if (patients.isEmpty) {
        return StatsAggregates.empty(tipo);
      }

      for (var p in patients) {
        userCache[p.reference.path] = p.data();
      }

      final patientRefs = patients.map((p) => p.reference).toList();
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocsList = [];

      const chunkSize = 30;
      final chunks = <List<DocumentReference>>[];
      for (var i = 0; i < patientRefs.length; i += chunkSize) {
        chunks.add(patientRefs.sublist(
          i,
          i + chunkSize > patientRefs.length
              ? patientRefs.length
              : i + chunkSize,
        ));
      }

      final queryTasks = chunks.map((chunk) {
        return FirebaseFirestore.instance
            .collectionGroup('Respuestas')
            .where('User_respuesta', whereIn: chunk)
            .get();
      });

      final queryResults = await Future.wait(queryTasks);
      for (var res in queryResults) {
        allDocsList.addAll(res.docs);
      }
      allDocs = allDocsList;
    } else {
      final snap = await FirebaseFirestore.instance
          .collectionGroup('Respuestas')
          .get()
          .timeout(const Duration(seconds: 20));
      allDocs = snap.docs;
    }

    final filteredDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final doc in allDocs) {
      final data = doc.data();
      final titulo = (data['Titlo'] ?? data['titlo'] ?? '').toString();
      if (titulo.isEmpty) continue;
      if (!_matchesTipo(tipo, titulo)) continue;
      if (tituloEncuesta != null &&
          tituloEncuesta.isNotEmpty &&
          titulo != tituloEncuesta) continue;
      if ((data['invalidado'] as bool?) == true) continue;
      if (rango != null) {
        final fecha = _fechaFromDoc(data);
        if (fecha == null) continue;
        if (fecha.isBefore(rango.start)) continue;
        final endInclusive = rango.end.add(const Duration(days: 1));
        if (!fecha.isBefore(endInclusive)) continue;
      }
      filteredDocs.add(doc);
    }

    final uniqueUserRefs = filteredDocs
        .map((doc) => doc.data()['User_respuesta'])
        .whereType<DocumentReference>()
        .toSet();

    await Future.wait(uniqueUserRefs.map((ref) => _fetchUser(ref, userCache)));

    for (final doc in filteredDocs) {
      final data = doc.data();
      final titulo = (data['Titlo'] ?? data['titlo'] ?? '').toString();
      final userRef = data['User_respuesta'];
      if (userRef is! DocumentReference) continue;

      final userData = await _fetchUser(userRef, userCache);
      if (userData == null) continue;

      if (colegio != null && colegio.isNotEmpty) {
        final uc = (userData['colegio'] ?? '').toString();
        if (uc != colegio) continue;
      }

      final items = <Map<String, dynamic>>[];
      final test = data['test'];
      if (test is List) {
        for (final e in test) {
          if (e is Map) items.add(Map<String, dynamic>.from(e));
        }
      }
      final respusta = data['Respusta'];
      if (respusta is List) {
        for (final e in respusta) {
          if (e is Map) items.add(Map<String, dynamic>.from(e));
        }
      }
      if (items.isEmpty) continue;

      final nivel = classifyNivel(
        titulo,
        items,
        puntajeTotal: data['puntajeTotal'] as num?,
        alertasEspeciales: (data['alertasEspeciales'] as List?)
            ?.map((e) => e.toString())
            .toList(),
      );
      final bucket = mapNivelToBucket(nivel, nivelesEje);
      if (nivelAlerta != null &&
          nivelAlerta.isNotEmpty &&
          bucket != nivelAlerta) {
        continue;
      }

      responses.add(ClassifiedResponse(
        nivel: nivel,
        genero: normalizeGenero(userData['genero']?.toString()),
        edad: _edadFromUser(userData),
        tipo: _resolveTipoForTitulo(titulo),
      ));
    }
  } catch (e) {
    return StatsAggregates.empty(tipo);
  }

  return _aggregate(tipo, responses);
}

Future<Map<String, dynamic>?> _fetchUser(
  DocumentReference ref,
  Map<String, Map<String, dynamic>> cache,
) async {
  final key = ref.path;
  if (cache.containsKey(key)) return cache[key];
  try {
    final snap = await ref.get().timeout(const Duration(seconds: 6));
    final data = snap.data();
    if (data is Map<String, dynamic>) {
      cache[key] = data;
      return data;
    }
  } catch (_) {}
  cache[key] = {};
  return null;
}

DateTime? _fechaFromDoc(Map<String, dynamic> data) {
  final f = data['Fecha'] ?? data['fecha'];
  if (f is Timestamp) return f.toDate();
  if (f is DateTime) return f;
  return null;
}

int? _edadFromUser(Map<String, dynamic> user) {
  final fn = user['fecha_nacimiento'];
  DateTime? birth;
  if (fn is Timestamp) birth = fn.toDate();
  if (fn is DateTime) birth = fn;
  if (birth == null) return null;
  final now = DateTime.now();
  int age = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    age--;
  }
  if (age < 0 || age > 120) return null;
  return age;
}

StatsAggregates _aggregate(
  TamizajeTipo tipo,
  List<ClassifiedResponse> items,
) {
  final niveles = tipo.niveles;
  final rangos = [...kRangosEdad, kRangoEdadFallback];

  final porGenero = <String, Map<String, int>>{
    for (final g in kGeneros) g: {for (final n in niveles) n: 0},
  };
  final porEdad = <String, Map<String, int>>{
    for (final r in rangos) r: {for (final n in niveles) n: 0},
  };
  final distribucion = <String, int>{for (final n in niveles) n: 0};

  for (final r in items) {
    final nivel = mapNivelToBucket(r.nivel, niveles);
    porGenero[r.genero]![nivel] = (porGenero[r.genero]![nivel] ?? 0) + 1;
    final rango = r.rangoEdad;
    porEdad[rango]![nivel] = (porEdad[rango]![nivel] ?? 0) + 1;
    distribucion[nivel] = (distribucion[nivel] ?? 0) + 1;
  }

  return StatsAggregates(
    tipo: tipo,
    total: items.length,
    niveles: niveles,
    porGenero: porGenero,
    porEdad: porEdad,
    distribucion: distribucion,
    categoria: categoriaForTipo(tipo) ?? '',
  );
}

/// Palette for alert levels as defined in the UX spec.
class StatsColors {
  static const verde = 0xFF34A853; // low
  static const amarillo = 0xFFF2B01C; // moderate
  static const rojo = 0xFFE5343D; // severe
  static const rojoOscuro = 0xFFB42318; // grave
  static const gris = 0xFF9AA0A6; // fallback

  static int forNivel(String nivel) {
    final n = nivel.toLowerCase();
    if (n.contains('grave') || n.contains('crítica') || n.contains('critica')) {
      return rojoOscuro;
    }
    if (n.contains('severo') ||
        n.contains('severa') ||
        n.contains('alto') ||
        n.contains('alta') ||
        n.contains('subescala 2')) {
      return rojo;
    }
    if (n.contains('moderada') ||
        n.contains('moderado') ||
        n.contains('media') ||
        n.contains('leve') ||
        n.contains('subescala 1')) {
      return amarillo;
    }
    // Rosemberg (autoestima): "Elevada" es resultado favorable; "Baja" es
    // baja autoestima (alerta). Deben colorearse distinto — no agrupar con `baja`.
    if (n.contains('elevada')) {
      return verde;
    }
    if (n.contains('baja')) {
      return rojo;
    }
    if (n.contains('mínima') || n.contains('minima') || n.contains('sin')) {
      return verde;
    }
    return gris;
  }
}
