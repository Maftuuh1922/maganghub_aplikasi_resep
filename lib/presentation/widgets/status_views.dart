import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const ErrorView({super.key, required this.message, required this.retry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(children: [
            const Icon(CupertinoIcons.wifi_slash, size: 44, color: muted),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: retry,
              style: FilledButton.styleFrom(
                  backgroundColor: mint, foregroundColor: bg),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
}

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView({super.key, this.message = 'No recipes found'});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(children: [
            const Icon(CupertinoIcons.book_fill, size: 42, color: muted),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted)),
          ]),
        ),
      );
}
