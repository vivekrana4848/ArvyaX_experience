/// Utility functions for formatting durations throughout the app.
class DurationFormatter {
  DurationFormatter._();

  /// Formats total seconds into `MM:SS` string.
  /// e.g. 3600 → "60:00", 90 → "01:30"
  static String format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a [Duration] into `MM:SS`.
  static String fromDuration(Duration duration) {
    return format(duration.inSeconds);
  }

  /// Returns a human-readable label for session durations shown on cards.
  /// e.g. 1800 → "30 min", 3600 → "60 min"
  static String toLabel(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    return '$minutes min';
  }
}
