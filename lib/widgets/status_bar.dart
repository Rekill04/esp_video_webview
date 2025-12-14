import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.text, required this.progress});

  final String text;
  final int? progress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 45,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(text)),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                      value: (progress!.clamp(0, 100)) / 100.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
