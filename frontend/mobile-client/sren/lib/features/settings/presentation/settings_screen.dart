import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/date_fmt.dart';
import '../state/settings_controller.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Experiments',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: state.analyticsEnabled,
            onChanged: controller.toggleAnalytics,
            title: const Text('Enable analytics events'),
            subtitle: const Text('Allow SREN to send lightweight usage events.'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: state.sentryEnabled,
            onChanged: controller.toggleSentry,
            title: const Text('Enable Sentry'),
            subtitle: const Text(
              'Forward critical crashes to Sentry when configured.',
            ),
          ),
          const Divider(height: 32),
          Text(
            'Diagnostics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('API base URL'),
            subtitle: Text(AppConfig.baseUrl),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Health check'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.healthStatus ?? 'Run a health check to verify connectivity.',
                ),
                if (state.lastHealthCheck != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Last check ${DateFmt.relative(state.lastHealthCheck!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            trailing: state.isCheckingHealth
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: controller.runHealthCheck,
                  ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mock mode'),
            subtitle: Text(
              AppConfig.mockMode
                  ? 'Camera calls replaced with gallery picker.'
                  : 'Using live camera feed.',
            ),
          ),
        ],
      ),
    );
  }
}
