import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

class SrenApp extends ConsumerWidget {
  const SrenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'SREN',
      theme: AppTheme.dark(),
      builder: DevicePreview.appBuilder,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
