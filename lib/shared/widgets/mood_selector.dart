import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Horizontal mood selector with animated highlight.
class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const _moods = [
    _MoodOption(label: AppStrings.moodCalm, emoji: '🌊', color: AppColors.moodCalm),
    _MoodOption(label: AppStrings.moodGrounded, emoji: '🌿', color: AppColors.moodGrounded),
    _MoodOption(label: AppStrings.moodEnergized, emoji: '⚡', color: AppColors.moodEnergized),
    _MoodOption(label: AppStrings.moodSleepy, emoji: '🌙', color: AppColors.moodSleepy),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _moods.map((mood) {
        final isSelected = selectedMood == mood.label;
        return Expanded(
          child: GestureDetector(
            onTap: () => onMoodSelected(mood.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? mood.color.withValues(alpha: 0.2)
                    : AppColors.glassWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? mood.color
                      : AppColors.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? mood.color : AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodOption {
  final String label;
  final String emoji;
  final Color color;

  const _MoodOption({
    required this.label,
    required this.emoji,
    required this.color,
  });
}
