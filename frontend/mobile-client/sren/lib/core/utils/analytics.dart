import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/prefs_keys.dart';

class AnalyticsService {
  AnalyticsService(this._preferences);

  final SharedPreferences _preferences;

  bool get isEnabled =>
      _preferences.getBool(PrefsKeys.analyticsEnabled) ?? true;

  void logEvent(String name, [Map<String, dynamic>? parameters]) {
    if (!isEnabled) {
      return;
    }
    final payload = parameters == null || parameters.isEmpty
        ? ''
        : jsonEncode(parameters);
    debugPrint('[analytics] $name $payload');
  }
}
