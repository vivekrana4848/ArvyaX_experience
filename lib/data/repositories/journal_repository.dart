import '../datasources/journal_local_datasource.dart';
import '../models/journal_entry_model.dart';

/// Repository contract for journal persistence.
abstract class JournalRepository {
  Future<int> saveEntry(JournalEntryModel entry);
  Future<List<JournalEntryModel>> getAllEntries();
  Future<int> deleteEntry(int id);
}

/// Implementation backed by the SQLite datasource.
class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDatasource _datasource;

  JournalRepositoryImpl({JournalLocalDatasource? datasource})
      : _datasource = datasource ?? JournalLocalDatasourceImpl();

  @override
  Future<int> saveEntry(JournalEntryModel entry) =>
      _datasource.saveEntry(entry);

  @override
  Future<List<JournalEntryModel>> getAllEntries() =>
      _datasource.getAllEntries();

  @override
  Future<int> deleteEntry(int id) => _datasource.deleteEntry(id);
}
