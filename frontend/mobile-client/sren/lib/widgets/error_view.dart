import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
  });

  final String? title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.redAccent),
                  ),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (onRetry != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
