import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/analytics.dart';
import '../../../core/utils/date_fmt.dart';
import '../../../domain/entities/emotion_entry.dart';
import '../../../widgets/error_view.dart';
import '../../auth/state/auth_controller.dart';
import '../state/history_controller.dart';
import '../state/history_state.dart';

class HistoryScreen extends HookConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider).valueOrNull;

    useEffect(() {
      controller.load();
      ref.read(analyticsServiceProvider).logEvent('history_viewed');
      return null;
    }, const []);

    final entries = state.filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion history'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.load(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ErrorView(
                    message: state.errorMessage!,
                    onRetry: () => controller.load(forceRefresh: true),
                  ),
                ),
              HistoryFilters(
                selectedRange: state.range,
                selectedEmotions: state.filteredEmotions,
                onRangeChanged: controller.changeRange,
                onEmotionToggle: controller.toggleEmotion,
              ),
              const SizedBox(height: 16),
              EmotionBarChart(entries: entries),
              const SizedBox(height: 24),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      const Icon(Icons.sentiment_neutral, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No history yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authState?.user == null
                            ? 'Sign in to start building your emotional journey.'
                            : 'Analyze emotions and we will build your history here.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _EmotionChip(emotion: entry.emotion),
                    title: Text(
                      entry.emotion[0].toUpperCase() +
                          entry.emotion.substring(1).toLowerCase(),
                    ),
                    subtitle: Text(
                      '${DateFmt.relative(entry.capturedAt)} • ${DateFmt.time(entry.capturedAt)}',
                    ),
                    trailing: Text('${(entry.confidence * 100).round()}%'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

class HistoryFilters extends StatelessWidget {
  const HistoryFilters({
    super.key,
    required this.selectedRange,
    required this.selectedEmotions,
    required this.onRangeChanged,
    required this.onEmotionToggle,
  });

  final HistoryRange selectedRange;
  final Set<String> selectedEmotions;
  final ValueChanged<HistoryRange> onRangeChanged;
  final ValueChanged<String> onEmotionToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          children: HistoryRange.values.map((range) {
            final label = switch (range) {
              HistoryRange.week => '7 days',
              HistoryRange.month => '30 days',
              HistoryRange.all => 'All time',
            };
            final selected = range == selectedRange;
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onRangeChanged(range),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: AppTheme.emotionColors.entries.map((entry) {
            final selected = selectedEmotions.contains(entry.key);
            return FilterChip(
              label: Text(entry.key.toLowerCase()),
              selected: selected,
              onSelected: (_) => onEmotionToggle(entry.key),
              backgroundColor: entry.value.withOpacity(0.2),
              selectedColor: entry.value.withOpacity(0.6),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class EmotionBarChart extends StatelessWidget {
  const EmotionBarChart({super.key, required this.entries});

  final List<EmotionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final emotion = entry.emotion.toUpperCase();
      counts.update(emotion, (value) => value + 1, ifAbsent: () => 1);
    }

    if (counts.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        ),
        child: Text(
          'No emotion data yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sorted.first.value;

    return SizedBox(
      height: 220,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxBarHeight = constraints.maxHeight - 40;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sorted.map((entry) {
              final normalized = entry.value / maxValue;
              final height = (normalized * maxBarHeight).clamp(12.0, maxBarHeight);
              final color = AppTheme.emotionColors[entry.key] ??
                  Theme.of(context).colorScheme.secondary;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        height: height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color.withOpacity(0.85),
                              color.withOpacity(0.45),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${entry.value}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.black87),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key.toLowerCase(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({required this.emotion});

  final String emotion;

  @override
  Widget build(BuildContext context) {
    final normalized = emotion.toUpperCase();
    final color = AppTheme.emotionColors[normalized] ??
        Theme.of(context).colorScheme.secondary;
    final label = normalized.isEmpty ? '?' : normalized.substring(0, 1);
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
