import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ambience_model.dart';
import '../../data/repositories/ambience_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final ambienceRepositoryProvider = Provider<AmbienceRepository>((ref) {
  return AmbienceRepositoryImpl();
});

// ── Raw ambience list (AsyncNotifier) ─────────────────────────────────────────

class AmbienceNotifier extends AsyncNotifier<List<AmbienceModel>> {
  @override
  Future<List<AmbienceModel>> build() async {
    final repo = ref.read(ambienceRepositoryProvider);
    return repo.getAmbiences();
  }
}

final ambienceNotifierProvider =
    AsyncNotifierProvider<AmbienceNotifier, List<AmbienceModel>>(
  AmbienceNotifier.new,
);

// ── Search query ──────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

// ── Selected tag filter ───────────────────────────────────────────────────────

final selectedTagProvider = StateProvider<String>((ref) => 'All');

// ── Filtered ambiences (derived) ──────────────────────────────────────────────

final filteredAmbiencesProvider = Provider<AsyncValue<List<AmbienceModel>>>(
  (ref) {
    final ambiencesAsync = ref.watch(ambienceNotifierProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
    final tag = ref.watch(selectedTagProvider);

    return ambiencesAsync.whenData((list) {
      return list.where((a) {
        final matchesQuery = query.isEmpty ||
            a.title.toLowerCase().contains(query) ||
            a.tag.toLowerCase().contains(query);
        final matchesTag = tag == 'All' || a.tag == tag;
        return matchesQuery && matchesTag;
      }).toList();
    });
  },
);
