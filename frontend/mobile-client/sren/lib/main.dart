import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/locator.dart';
import 'data/models/emotion_entry_model.dart';
import 'data/models/recommendation_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(EmotionEntryModelAdapter())
    ..registerAdapter(RecommendationModelAdapter());

  final sharedPrefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  Future<void> runAppWithProviders() async {
    final app = ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secureStorage),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const SrenApp(),
    );

    const enablePreview = bool.fromEnvironment('DEVICE_PREVIEW', defaultValue: false);
    if (!kReleaseMode && enablePreview) {
      runApp(
        DevicePreview(
          enabled: true,
          builder: (_) => app,
        ),
      );
    } else {
      runApp(app);
    }
  }

  if (AppConfig.enableSentry && AppConfig.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.sentryDsn;
        options.tracesSampleRate = 0.2;
      },
      appRunner: () => runAppWithProviders(),
    );
  } else {
    await runAppWithProviders();
  }
}
