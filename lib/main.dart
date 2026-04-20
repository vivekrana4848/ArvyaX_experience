import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/utils/database_helper.dart';
import 'shared/theme/app_theme.dart';
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── System UI (native only) ──────────────────────────────────
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  // ── Background audio notification ────────────────────────
  // Skip on Web — just_audio_background only targets native platforms.
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.app.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    );
  }

  // ── Initialize SQLite ────────────────────────────────────────
  // On native: persists to disk.
  // On web:    uses sqflite's inMemoryDatabasePath (session-scoped).
  await DatabaseHelper.instance.database;

  runApp(
    const ProviderScope(
      child: ArvyaXApp(),
    ),
  );
}

class ArvyaXApp extends StatelessWidget {
  const ArvyaXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArvyaX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AppShell(),
    );
  }
}
