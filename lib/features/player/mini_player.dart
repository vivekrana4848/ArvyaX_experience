import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import 'player_controller.dart';
import 'session_player_screen.dart';

/// Persistent mini player bar shown at the bottom of any screen
/// when a session is active and the user has left the player screen.
///
/// Layout (top → bottom):
///   Row: [Thumbnail] [Title + remaining time] [Play/Pause button]
///   SizedBox(height: 6)
///   LinearProgressIndicator  ← progress bar is BELOW the content row
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playerControllerProvider);

    if (!session.isActive) return const SizedBox.shrink();

    final ambience = session.ambience!;

    return GestureDetector(
      // Tap anywhere on the card (except the play button) → open full player
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const SessionPlayerScreen(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0D30), Color(0xFF0B1440)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Content row ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 6),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Image.asset(
                        ambience.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.accentGradient,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + remaining time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 2),
                        Text(
                          DurationFormatter.format(session.secondsRemaining),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Play/Pause button — GestureDetector absorbs tap so
                  // it does NOT bubble up to the parent (navigation) detector.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref
                        .read(playerControllerProvider.notifier)
                        .togglePlay(),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: AppColors.accentGradient,
                        ),
                      ),
                      child: Icon(
                        session.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar — sits BELOW the content row ─────
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              child: LinearProgressIndicator(
                value: session.progressFraction,
                backgroundColor: AppColors.glassWhite,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accentPurple,
                ),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
