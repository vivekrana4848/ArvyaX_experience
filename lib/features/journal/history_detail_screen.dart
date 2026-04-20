import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/journal_entry_model.dart';
import '../../shared/widgets/glass_container.dart';
import 'journal_provider.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final JournalEntryModel entry;

  const HistoryDetailScreen({super.key, required this.entry});

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reflection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textMuted),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Date & Mood banner ────────────────────────────
              GlowGlassContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mood icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.15),
                        border:
                            Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          _moodEmoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Expanded prevents text column from overflowing Row
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.mood,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('EEEE, MMMM d, y • h:mm a')
                                .format(entry.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Ambience tag ──────────────────────────────────
              if (entry.ambienceTitle != null) ...[
                GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note_rounded,
                          size: 14, color: AppColors.accentPurpleLight),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Session: ${entry.ambienceTitle}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accentPurpleLight,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Prompt label ──────────────────────────────────
              Text(
                '✦  ${AppStrings.journalPrompt}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // ── Full reflection text ──────────────────────────
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Text(
                  entry.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Reflection?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.accentPurpleLight)),
          ),
          TextButton(
            onPressed: () async {
              if (entry.id != null) {
                await ref
                    .read(journalNotifierProvider.notifier)
                    .deleteEntry(entry.id!);
              }
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Pop detail
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
