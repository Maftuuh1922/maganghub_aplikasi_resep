import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class Header extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const Header({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  void _openNavigation(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Navigate',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            _NavigationChoice(
              icon: CupertinoIcons.house_fill,
              label: 'Home',
              selected: selectedTab == 0,
              onTap: () {
                Navigator.pop(context);
                onTabChanged(0);
              },
            ),
            const SizedBox(height: 8),
            _NavigationChoice(
              icon: CupertinoIcons.heart_fill,
              label: 'Saved recipes',
              selected: selectedTab == 1,
              onTap: () {
                Navigator.pop(context);
                onTabChanged(1);
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Row(children: [
          GestureDetector(
            onTap: () => _openNavigation(context),
            child: Container(
              key: const Key('top-left-network-nav'),
              width: 58,
              height: 46,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const _NetworkIcon(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(CupertinoIcons.book_fill, color: bg, size: 21),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pantom',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('MEALS',
                  style: TextStyle(
                      color: mint,
                      fontSize: 11,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ]),
      );
}

class _NavigationChoice extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? mint : surface2,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Icon(icon, color: selected ? bg : muted),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: selected ? bg : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ),
        ),
      );
}

class _NetworkIcon extends StatelessWidget {
  const _NetworkIcon();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 9,
            child: Icon(
              CupertinoIcons.chat_bubble_2_fill,
              size: 21,
              color: Colors.white,
            ),
          ),
          CustomPaint(size: const Size(28, 28), painter: _NetworkPainter()),
        ],
      );
}

class _NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withOpacity(.92)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = Colors.white;
    final points = <Offset>[
      Offset(size.width * .48, size.height * .18),
      Offset(size.width * .80, size.height * .36),
      Offset(size.width * .70, size.height * .78),
      Offset(size.width * .36, size.height * .80),
      Offset(size.width * .22, size.height * .48),
    ];
    for (var index = 0; index < points.length; index++) {
      canvas.drawLine(points[index], points[(index + 1) % points.length], line);
    }
    for (final point in points) {
      canvas.drawCircle(point, 2.4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
