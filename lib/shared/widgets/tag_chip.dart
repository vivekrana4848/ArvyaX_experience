import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable tag chip with color keyed to tag name.
class TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  Color get _tagColor {
    switch (tag.toLowerCase()) {
      case 'focus':
        return AppColors.tagFocus;
      case 'calm':
        return AppColors.tagCalm;
      case 'sleep':
        return AppColors.tagSleep;
      case 'reset':
        return AppColors.tagReset;
      default:
        return AppColors.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tagColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Row of filter chips for the home screen including an "All" option.
class TagFilterRow extends StatelessWidget {
  final String selectedTag;
  final ValueChanged<String> onTagSelected;

  const TagFilterRow({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
  });

  static const _tags = ['All', 'Focus', 'Calm', 'Sleep', 'Reset'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = _tags[index];
          final selected = selectedTag == tag;
          return TagChip(
            tag: tag,
            isSelected: selected,
            onTap: () => onTagSelected(tag),
          );
        },
      ),
    );
  }
}
