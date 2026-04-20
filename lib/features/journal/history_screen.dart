import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/journal_entry_model.dart';
import '../../shared/widgets/glass_container.dart';
import 'history_detail_screen.dart';
import 'journal_entry_screen.dart';
import 'journal_provider.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(AppStrings.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const JournalEntryScreen()),
            ),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (entries) {
          if (entries.isEmpty) return _buildEmptyState(context);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _JournalCard(entry: entries[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentPurple.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.book_outlined,
                color: AppColors.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.historyEmpty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.historyEmptySub,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends ConsumerWidget {
  final JournalEntryModel entry;

  const _JournalCard({required this.entry});

  Color get _moodColor {
    switch (entry.mood) {
      case AppStrings.moodCalm:
        return AppColors.moodCalm;
      case AppStrings.moodGrounded:
        return AppColors.moodGrounded;
      case AppStrings.moodEnergized:
        return AppColors.moodEnergized;
      case AppStrings.moodSleepy:
        return AppColors.moodSleepy;
      default:
        return AppColors.accentPurple;
    }
  }

  String get _moodEmoji {
    switch (entry.mood) {
      case AppStrings.moodCalm:
        return '🌊';
      case AppStrings.moodGrounded:
        return '🌿';
      case AppStrings.moodEnergized:
        return '⚡';
      case AppStrings.moodSleepy:
        return '🌙';
      default:
        return '✦';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _moodColor;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryDetailScreen(entry: entry),
        ),
      ),
      child: GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Row(
              children: [
                // Mood badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_moodEmoji,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        entry.mood,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, h:mm a').format(entry.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Preview text ─────────────────────────────────
            Text(
              entry.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            // ── Ambience tag (if any) ─────────────────────────
            if (entry.ambienceTitle != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.music_note_outlined,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    entry.ambienceTitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
