import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FloatingNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const FloatingNav(
      {super.key, required this.selected, required this.onChanged});

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 120) return;
    final next = velocity < 0 ? 1 : 0;
    if (next != selected) onChanged(next);
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: _handleSwipe,
            child: Container(
              key: const Key('floating-nav-pill'),
              height: 68,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.34),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Stack(children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: selected * 155,
                  top: 0,
                  bottom: 0,
                  width: 155,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: mint,
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                ),
                Row(children: [
                  Expanded(
                    child: _NavItem(
                      icon: CupertinoIcons.house_fill,
                      label: 'Home',
                      active: selected == 0,
                      onTap: () => onChanged(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: CupertinoIcons.heart_fill,
                      label: 'Saved',
                      active: selected == 1,
                      onTap: () => onChanged(1),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Center(
            key: Key('nav-content-$label'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: active ? bg : muted),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? bg : muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
