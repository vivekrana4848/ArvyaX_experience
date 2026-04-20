import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ambience_model.dart';

/// Loads ambience data from the bundled JSON asset.
abstract class AmbienceLocalDatasource {
  Future<List<AmbienceModel>> getAmbiences();
}

class AmbienceLocalDatasourceImpl implements AmbienceLocalDatasource {
  @override
  Future<List<AmbienceModel>> getAmbiences() async {
    final jsonString =
        await rootBundle.loadString('assets/data/ambiences.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> list = jsonMap['ambiences'] as List<dynamic>;
    return list
        .map((e) => AmbienceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
