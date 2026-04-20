import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../data/models/ambience_model.dart';
import 'tag_chip.dart';

/// Grid card for an ambience item on the home screen.
class AmbienceCard extends StatelessWidget {
  final AmbienceModel ambience;
  final VoidCallback onTap;

  const AmbienceCard({
    super.key,
    required this.ambience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.cardSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ThumbnailImage(imageAsset: ambience.imageAsset),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0B0F1A),
                        ],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Tag chip top-right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: TagChip(tag: ambience.tag, compact: true),
                  ),
                ],
              ),
            ),

            // ── Info ────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ambience.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DurationFormatter.toLabel(ambience.duration),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  final String imageAsset;

  const _ThumbnailImage({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _PlaceholderGradient();
      },
    );
  }
}

class _PlaceholderGradient extends StatelessWidget {
  const _PlaceholderGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0B2E), Color(0xFF0B1440)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.landscape_outlined,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );
  }
}
