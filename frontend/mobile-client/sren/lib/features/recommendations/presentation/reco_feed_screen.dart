import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/analytics.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/reco_card.dart';
import '../../../widgets/shimmer_skel.dart';
import '../../auth/state/auth_controller.dart';
import '../state/recommendations_controller.dart';
import '../state/recommendations_state.dart';

class RecommendationsFeedScreen extends HookConsumerWidget {
  const RecommendationsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationsControllerProvider);
    final controller = ref.read(recommendationsControllerProvider.notifier);
    final user = ref.watch(authControllerProvider).valueOrNull?.user;

    useEffect(() {
      controller.loadCached();
      return null;
    }, const []);

    Future<void> refresh() async {
      await controller.refresh();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('For you'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ErrorView(
                    message: state.errorMessage!,
                    onRetry: controller.refresh,
                  ),
                ),
              if (state.items.isEmpty && state.isLoading)
                ...List.generate(3, (_) => const ShimmerSkeleton())
              else if (state.items.isEmpty)
                _EmptyRecommendations(
                  hasEmotion: state.emotion != null,
                  onAnalyze: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analyze your mood to get recommendations.'),
                    ),
                  ),
                )
              else
                ...state.items.map(
                  (recommendation) => RecommendationCard(
                    recommendation: recommendation,
                    onTap: () => ref
                        .read(analyticsServiceProvider)
                        .logEvent('recommendation_opened', {
                      'type': recommendation.contentType.name,
                      'emotion': recommendation.emotion,
                    }),
                  ),
                ),
              if (user != null && state.emotion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'Recommendations curated for ${state.emotion!.toLowerCase()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
    );
  }
}

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations({
    required this.hasEmotion,
    required this.onAnalyze,
  });

  final bool hasEmotion;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, size: 64),
          const SizedBox(height: 16),
          Text(
            hasEmotion ? 'No content yet' : 'Let\'s start with an analysis',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasEmotion
                ? 'We will surface new recommendations as you analyze more.'
                : 'Capture or upload a photo to analyze your emotions and unlock personalized content.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onAnalyze,
            child: const Text('Analyze now'),
          ),
        ],
      ),
    );
  }
}
