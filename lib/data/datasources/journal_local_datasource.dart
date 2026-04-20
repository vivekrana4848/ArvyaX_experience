import '../../core/utils/database_helper.dart';
import '../models/journal_entry_model.dart';

/// Datasource for journal entries and session state via SQLite.
abstract class JournalLocalDatasource {
  Future<int> saveEntry(JournalEntryModel entry);
  Future<List<JournalEntryModel>> getAllEntries();
  Future<int> deleteEntry(int id);
}

class JournalLocalDatasourceImpl implements JournalLocalDatasource {
  final DatabaseHelper _db;

  JournalLocalDatasourceImpl({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  @override
  Future<int> saveEntry(JournalEntryModel entry) async {
    return _db.insertJournalEntry(entry.toMap());
  }

  @override
  Future<List<JournalEntryModel>> getAllEntries() async {
    final rows = await _db.getAllJournalEntries();
    return rows.map(JournalEntryModel.fromMap).toList();
  }

  @override
  Future<int> deleteEntry(int id) async {
    return _db.deleteJournalEntry(id);
  }
}
