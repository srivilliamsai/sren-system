import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/prefs_keys.dart';
import '../../../core/di/locator.dart';
import '../../../core/errors/app_exception.dart';
import 'settings_state.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(
    preferences: ref.watch(sharedPreferencesProvider),
    dio: ref.watch(dioProvider),
  ),
);

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController({
    required SharedPreferences preferences,
    required Dio dio,
  })  : _preferences = preferences,
        _dio = dio,
        super(SettingsState(
          analyticsEnabled:
              preferences.getBool(PrefsKeys.analyticsEnabled) ?? true,
          sentryEnabled:
              preferences.getBool(PrefsKeys.sentryEnabled) ?? AppConfig.enableSentry,
        ));

  final SharedPreferences _preferences;
  final Dio _dio;

  void toggleAnalytics(bool value) {
    state = state.copyWith(analyticsEnabled: value);
    _preferences.setBool(PrefsKeys.analyticsEnabled, value);
  }

  void toggleSentry(bool value) {
    state = state.copyWith(sentryEnabled: value);
    _preferences.setBool(PrefsKeys.sentryEnabled, value);
  }

  Future<void> runHealthCheck() async {
    state = state.copyWith(isCheckingHealth: true, healthStatus: null);
    try {
      final response = await _dio.get<dynamic>('/actuator/health');
      final status = response.data is Map<String, dynamic>
          ? (response.data['status']?.toString() ?? 'unknown')
          : 'unknown';
      state = state.copyWith(
        healthStatus: 'Server status: $status',
        lastHealthCheck: DateTime.now(),
        isCheckingHealth: false,
      );
    } on DioException catch (error) {
      final message = NetworkException.fromDioError(error).message;
      state = state.copyWith(
        healthStatus: 'Health check failed: $message',
        lastHealthCheck: DateTime.now(),
        isCheckingHealth: false,
      );
    } catch (error) {
      state = state.copyWith(
        healthStatus: 'Unexpected error: $error',
        lastHealthCheck: DateTime.now(),
        isCheckingHealth: false,
      );
    }
  }
}
