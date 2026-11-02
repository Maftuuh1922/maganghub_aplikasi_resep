import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class Header extends StatelessWidget {
  final double pageOffset;
  final int? selectedTab;
  final ValueChanged<int> onTabChanged;
  final bool hasNotification;
  final VoidCallback? onNotificationRead;

  const Header({
    super.key,
    this.pageOffset = 0,
    this.selectedTab,
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
              pageOffset: selectedTab?.toDouble() ?? pageOffset,
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
    final notifications = <_DemoNotification>[
      const _DemoNotification(
        title: 'Resep baru untuk dicoba',
        message: 'Spicy Arrabiata Penne siap menemani hari ini.',
        icon: Icons.restaurant_rounded,
      ),
      const _DemoNotification(
        title: 'Inspirasi hari ini',
        message: 'Jelajahi kategori dan temukan menu favoritmu.',
        icon: Icons.lightbulb_outline_rounded,
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (notifications.isNotEmpty)
                      TextButton.icon(
                        key: const Key('notification-clear-all'),
                        onPressed: () => setModalState(notifications.clear),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 19),
                        label: const Text('Hapus semua'),
                        style: TextButton.styleFrom(foregroundColor: muted),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 38, color: muted),
                        SizedBox(height: 10),
                        Text(
                          'Semua notifikasi sudah dibersihkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(notifications.length, (index) {
                    final item = notifications[index];
                    return Container(
                      key: Key('notification-card-$index'),
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.fromLTRB(13, 11, 5, 11),
                      decoration: BoxDecoration(
                        color: surface2.withOpacity(.62),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: mint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, color: bg, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: readingText,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: Key('notification-delete-$index'),
                            tooltip: 'Hapus notifikasi',
                            onPressed: () => setModalState(
                              () => notifications.removeAt(index),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 19),
                            color: muted,
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
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
            Text(
              'Pantom Meals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Recipe catalog powered by TheMealDB',
              style: TextStyle(color: muted),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SegmentedNav extends StatelessWidget {
  final double pageOffset;
  final ValueChanged<int> onChanged;

  const _SegmentedNav({
    super.key,
    required this.pageOffset,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const segmentWidth = 84.0;
    final offset = pageOffset.clamp(0.0, 1.0);
    return Container(
      width: 176,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            left: segmentWidth * offset,
            top: 0,
            width: segmentWidth,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          Row(children: [
            _Segment(
              key: const Key('top-nav-home'),
              icon: offset < .5
                  ? Icons.restaurant_menu_rounded
                  : Icons.restaurant_menu_outlined,
              selected: offset < .5,
              onTap: () => onChanged(0),
            ),
            _Segment(
              key: const Key('top-nav-saved'),
              icon: offset >= .5
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              selected: offset >= .5,
              onTap: () => onChanged(1),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 24, color: selected ? bg : muted),
          ),
        ),
      );
}

class _ActionPill extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback onNotification;
  final VoidCallback onMore;

  const _ActionPill({
    required this.hasNotification,
    required this.onNotification,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(children: [
          Stack(children: [
            IconButton(
              key: const Key('top-notification-button'),
              tooltip: 'Notifications',
              onPressed: onNotification,
              icon: const Icon(Icons.notifications_none_rounded, size: 24),
              color: Colors.white,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
            if (hasNotification)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ]),
          IconButton(
            key: const Key('top-more-button'),
            tooltip: 'More',
            onPressed: onMore,
            icon: const Icon(Icons.more_horiz_rounded, size: 24),
            color: muted,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
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
          color: surface2,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

class _DemoNotification {
  final String title;
  final String message;
  final IconData icon;

  const _DemoNotification({
    required this.title,
    required this.message,
    required this.icon,
  });
}
