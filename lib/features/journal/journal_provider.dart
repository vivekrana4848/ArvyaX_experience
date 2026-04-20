import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journal_entry_model.dart';
import '../../data/repositories/journal_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl();
});

// ── Journal state ─────────────────────────────────────────────────────────────

class JournalNotifier extends AsyncNotifier<List<JournalEntryModel>> {
  @override
  Future<List<JournalEntryModel>> build() async {
    final repo = ref.read(journalRepositoryProvider);
    return repo.getAllEntries();
  }

  Future<void> addEntry(JournalEntryModel entry) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.saveEntry(entry);
    // Reload from DB for consistency
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.getAllEntries());
  }

  Future<void> deleteEntry(int id) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.deleteEntry(id);
    state = await AsyncValue.guard(
      () => ref.read(journalRepositoryProvider).getAllEntries(),
    );
  }
}

final journalNotifierProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntryModel>>(
  JournalNotifier.new,
);
