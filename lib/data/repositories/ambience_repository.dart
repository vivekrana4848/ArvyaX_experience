import '../datasources/ambience_local_datasource.dart';
import '../models/ambience_model.dart';

/// Repository contract for ambience data.
abstract class AmbienceRepository {
  Future<List<AmbienceModel>> getAmbiences();
}

/// Implementation backed by the local JSON asset datasource.
class AmbienceRepositoryImpl implements AmbienceRepository {
  final AmbienceLocalDatasource _datasource;

  AmbienceRepositoryImpl({AmbienceLocalDatasource? datasource})
      : _datasource = datasource ?? AmbienceLocalDatasourceImpl();

  @override
  Future<List<AmbienceModel>> getAmbiences() => _datasource.getAmbiences();
}
