import 'dart:ui';

/// Central color palette for ArvyaX — dark glassmorphism theme.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────
  static const background = Color(0xFF0B0F1A);
  static const surfaceDark = Color(0xFF111827);
  static const cardSurface = Color(0xFF141B2D);

  // ── Glass ─────────────────────────────────────────────────────
  static const glassWhite = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const glassHighlight = Color(0x0DFFFFFF);

  // ── Accent Gradient: Purple → Blue ────────────────────────────
  static const accentPurple = Color(0xFF7C3AED);
  static const accentBlue = Color(0xFF2563EB);
  static const accentPurpleLight = Color(0xFF9F67FF);
  static const accentBlueLight = Color(0xFF60A5FA);
  static const accentGlow = Color(0x337C3AED);

  // ── Text ──────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFEAEAF0);
  static const textSecondary = Color(0xFFAAABBF);
  static const textMuted = Color(0xFF5A5B6E);
  static const textOnAccent = Color(0xFFFFFFFF);

  // ── Tag Colors ────────────────────────────────────────────────
  static const tagFocus = Color(0xFF2563EB);
  static const tagCalm = Color(0xFF059669);
  static const tagSleep = Color(0xFF7C3AED);
  static const tagReset = Color(0xFFD97706);

  // ── Mood Colors ───────────────────────────────────────────────
  static const moodCalm = Color(0xFF06B6D4);
  static const moodGrounded = Color(0xFF10B981);
  static const moodEnergized = Color(0xFFF59E0B);
  static const moodSleepy = Color(0xFF8B5CF6);

  // ── Misc ──────────────────────────────────────────────────────
  static const divider = Color(0x1AFFFFFF);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);

  // ── Gradient helpers ──────────────────────────────────────────
  static const accentGradient = [accentPurple, accentBlue];
  static const backgroundGradient = [Color(0xFF0B0F1A), Color(0xFF0F1626)];
  static const playerGradient = [
    Color(0xFF1A0B2E),
    Color(0xFF0B1440),
    Color(0xFF0B0F1A),
  ];
}
