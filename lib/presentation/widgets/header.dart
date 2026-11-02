import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class Header extends StatelessWidget {
  const Header({super.key});

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
                    color: surface2, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 22),
            const Row(children: [
              Icon(CupertinoIcons.bell, color: mint),
              SizedBox(width: 10),
              Text('Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 26),
            const Icon(CupertinoIcons.bell_slash, size: 38, color: muted),
            const SizedBox(height: 12),
            const Text("You're all caught up",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('New recipe updates will show up here.',
                textAlign: TextAlign.center, style: TextStyle(color: muted)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: mint, borderRadius: BorderRadius.circular(15)),
              child: const Icon(CupertinoIcons.book_fill, color: bg, size: 21)),
          const SizedBox(width: 12),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Pantom',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text('MEALS',
                    style: TextStyle(
                        color: mint,
                        fontSize: 11,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.bold)),
              ])),
          Container(
            decoration: BoxDecoration(
                color: surface, borderRadius: BorderRadius.circular(14)),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () => _showNotifications(context),
              icon: const Icon(CupertinoIcons.bell),
            ),
          ),
        ]),
      );
}
