class SettingsState {
  const SettingsState({
    required this.analyticsEnabled,
    required this.sentryEnabled,
    this.lastHealthCheck,
    this.healthStatus,
    this.isCheckingHealth = false,
  });

  final bool analyticsEnabled;
  final bool sentryEnabled;
  final DateTime? lastHealthCheck;
  final String? healthStatus;
  final bool isCheckingHealth;

  SettingsState copyWith({
    bool? analyticsEnabled,
    bool? sentryEnabled,
    DateTime? lastHealthCheck,
    String? healthStatus,
    bool? isCheckingHealth,
  }) {
    return SettingsState(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      sentryEnabled: sentryEnabled ?? this.sentryEnabled,
      lastHealthCheck: lastHealthCheck ?? this.lastHealthCheck,
      healthStatus: healthStatus ?? this.healthStatus,
      isCheckingHealth: isCheckingHealth ?? this.isCheckingHealth,
    );
  }

  static const defaultState = SettingsState(
    analyticsEnabled: true,
    sentryEnabled: false,
  );
}
