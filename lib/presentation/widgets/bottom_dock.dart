import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../logic/app_state.dart';

class BottomDock extends StatelessWidget {
  final TextEditingController controller;
  final AppState state;
  const BottomDock({
    super.key,
    required this.controller,
    required this.state,
  });

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 22),
            const Row(children: [
              Icon(CupertinoIcons.bell, color: mint),
              SizedBox(width: 10),
              Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ]),
            const SizedBox(height: 26),
            const Icon(CupertinoIcons.bell_slash, size: 38, color: muted),
            const SizedBox(height: 12),
            const Text(
              "You're all caught up",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'New recipe updates will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Material(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            child: IconButton(
              key: const Key('bottom-notification-button'),
              tooltip: 'Notifications',
              onPressed: () => _showNotifications(context),
              icon: const Icon(CupertinoIcons.bell),
              color: muted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: const Key('bottom-search-field'),
              controller: controller,
              onChanged: state.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(CupertinoIcons.search),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ]),
      );
}
