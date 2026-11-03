import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

const double kHeaderBarHeight = 44;
const double kHeaderSegmentWidth = 52;
const double kHeaderIndicatorHeight = 40;
const double kHeaderIconSize = 22;
const double kHeaderTopSpacing = 8;
const double kHeaderTapTarget = 44;
const double kHeaderHorizontalMargin = 16;
const Color kHeaderIconColor = Color(0xBFFFFFFF);
const Color kHeaderIconShadowColor = Color(0x8A000000);

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
  Widget build(BuildContext context) => SafeArea(
        top: true,
        bottom: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.only(top: kHeaderTopSpacing),
          child: FloatingIconBar(
            key: const Key('floating-icon-bar'),
            pageOffset: selectedTab?.toDouble() ?? pageOffset,
            onTabChanged: onTabChanged,
            hasNotification: hasNotification,
            onNotification: () => _showNotifications(context),
            onMore: () => _showMore(context),
          ),
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

class FloatingIconBar extends StatelessWidget {
  final double pageOffset;
  final ValueChanged<int> onTabChanged;
  final bool hasNotification;
  final VoidCallback onNotification;
  final VoidCallback onMore;

  const FloatingIconBar({
    super.key,
    required this.pageOffset,
    required this.onTabChanged,
    required this.hasNotification,
    required this.onNotification,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final selected = pageOffset.round().clamp(0, 1).toInt();
    return SizedBox(
      height: kHeaderBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedIcons(
            key: const Key('top-left-network-nav'),
            icons: [
              selected == 0
                  ? Icons.restaurant_menu_rounded
                  : Icons.restaurant_menu_outlined,
              selected == 1
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ],
            selected: selected,
            onTap: onTabChanged,
          ),
          _HeaderActionIcons(
            hasNotification: hasNotification,
            onNotification: onNotification,
            onMore: onMore,
          ),
        ],
      ),
    );
  }
}

class SegmentedIcons extends StatelessWidget {
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onTap;

  const SegmentedIcons({
    super.key,
    required this.icons,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = icons.length;
    if (count == 0) return const SizedBox(height: kHeaderBarHeight);
    final activeIndex = selected.clamp(0, count - 1).toInt();
    final alignmentX = count == 1 ? 0.0 : -1 + 2 * activeIndex / (count - 1);

    return SizedBox(
      width: kHeaderSegmentWidth * count,
      height: kHeaderBarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment(alignmentX, 0),
            child: Container(
              width: kHeaderSegmentWidth,
              height: kHeaderIndicatorHeight,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(kHeaderIndicatorHeight / 2),
              ),
            ),
          ),
          Row(
            children: [
              for (var index = 0; index < count; index++)
                SizedBox(
                  key: Key(index == 0 ? 'top-nav-home' : 'top-nav-saved'),
                  width: kHeaderSegmentWidth,
                  height: kHeaderBarHeight,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Center(
                      child: Icon(
                        icons[index],
                        size: kHeaderIconSize,
                        color: index == activeIndex
                            ? Colors.black87
                            : kHeaderIconColor,
                        shadows: index == activeIndex
                            ? null
                            : const [
                                Shadow(
                                  color: kHeaderIconShadowColor,
                                  blurRadius: 8,
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionIcons extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback onNotification;
  final VoidCallback onMore;

  const _HeaderActionIcons({
    required this.hasNotification,
    required this.onNotification,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: kHeaderTapTarget * 2,
        height: kHeaderBarHeight,
        child: Row(
          children: [
            _HeaderIconButton(
              key: const Key('top-notification-button'),
              icon: Icons.notifications_none_rounded,
              onPressed: onNotification,
              hasBadge: hasNotification,
            ),
            _HeaderIconButton(
              key: const Key('top-more-button'),
              icon: Icons.more_horiz_rounded,
              onPressed: onMore,
            ),
          ],
        ),
      );
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool hasBadge;

  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: kHeaderTapTarget,
        height: kHeaderTapTarget,
        child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: icon == Icons.notifications_none_rounded
                  ? 'Notifications'
                  : 'More',
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: kHeaderTapTarget,
                height: kHeaderTapTarget,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: kHeaderIconColor,
                overlayColor: Colors.transparent,
                padding: EdgeInsets.zero,
                minimumSize: const Size(kHeaderTapTarget, kHeaderTapTarget),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                icon,
                size: kHeaderIconSize,
                color: kHeaderIconColor,
                shadows: const [
                  Shadow(
                    color: kHeaderIconShadowColor,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            if (hasBadge)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
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
