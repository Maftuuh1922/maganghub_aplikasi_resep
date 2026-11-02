import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class Header extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final bool hasNotification;
  final VoidCallback? onNotificationRead;

  const Header({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.hasNotification = false,
    this.onNotificationRead,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SegmentedNav(
              key: const Key('top-left-network-nav'),
              selectedTab: selectedTab,
              onChanged: onTabChanged,
            ),
            _ActionPill(
              hasNotification: hasNotification,
              onNotification: () => _showNotifications(context),
              onMore: () => _showMore(context),
            ),
          ],
        ),
      );

  void _showNotifications(BuildContext context) {
    onNotificationRead?.call();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const _SheetHandle(),
            const SizedBox(height: 22),
            const Row(children: [
              Icon(Icons.notifications_none_rounded, color: mint),
              SizedBox(width: 10),
              Text('Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))
            ]),
            const SizedBox(height: 26),
            const Icon(Icons.notifications_off_outlined,
                size: 38, color: muted),
            const SizedBox(height: 12),
            const Text("You're all caught up",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Favorite updates will show up here.',
                textAlign: TextAlign.center, style: TextStyle(color: muted)),
          ]),
        ),
      ),
    );
  }

  void _showMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 18, 24, 30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _SheetHandle(),
            SizedBox(height: 20),
            Text('Pantom Meals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Recipe catalog powered by TheMealDB',
                style: TextStyle(color: muted)),
          ]),
        ),
      ),
    );
  }
}

class _SegmentedNav extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onChanged;
  const _SegmentedNav({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 176,
        height: 56,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: surface2, borderRadius: BorderRadius.circular(30)),
        child: Stack(children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment:
                selectedTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
                width: 84,
                height: 48,
                decoration: BoxDecoration(
                    color: mint, borderRadius: BorderRadius.circular(26))),
          ),
          Row(children: [
            _Segment(
                key: const Key('top-nav-home'),
                icon: selectedTab == 0
                    ? Icons.restaurant_menu_rounded
                    : Icons.restaurant_menu_outlined,
                selected: selectedTab == 0,
                onTap: () => onChanged(0)),
            _Segment(
                key: const Key('top-nav-saved'),
                icon: selectedTab == 1
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                selected: selectedTab == 1,
                onTap: () => onChanged(1)),
          ]),
        ]),
      );
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Segment(
      {super.key,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child:
              Center(child: Icon(icon, size: 24, color: selected ? bg : muted)),
        ),
      );
}

class _ActionPill extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback onNotification;
  final VoidCallback onMore;
  const _ActionPill(
      {required this.hasNotification,
      required this.onNotification,
      required this.onMore});

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: surface2, borderRadius: BorderRadius.circular(30)),
        child: Row(children: [
          Stack(children: [
            IconButton(
                key: const Key('top-notification-button'),
                tooltip: 'Notifications',
                onPressed: onNotification,
                icon: const Icon(Icons.notifications_none_rounded, size: 24),
                color: Colors.white,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48)),
            if (hasNotification)
              Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: mint, shape: BoxShape.circle))),
          ]),
          IconButton(
              key: const Key('top-more-button'),
              tooltip: 'More',
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz_rounded, size: 24),
              color: muted,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48)),
        ]),
      );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
          color: surface2, borderRadius: BorderRadius.circular(4)));
}
