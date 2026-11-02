import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../logic/app_state.dart';

class FavoriteToast extends StatelessWidget {
  final ToastNotice notice;
  const FavoriteToast({super.key, required this.notice});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                    offset: Offset(0, -16 * (1 - value)), child: child),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: surface.withOpacity(.97),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: notice.added
                          ? mint.withOpacity(.35)
                          : muted.withOpacity(.35)),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 18,
                        offset: Offset(0, 8))
                  ],
                ),
                child: Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: notice.added ? mint : surface2,
                        shape: BoxShape.circle),
                    child: Icon(
                        notice.added
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        size: 17,
                        color: notice.added ? bg : muted),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(notice.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          ),
        ),
      );
}

class FavoriteToastOverlay extends StatelessWidget {
  const FavoriteToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final notice =
        context.select<AppState, ToastNotice?>((state) => state.toast);
    if (notice == null) return const SizedBox.shrink();
    return Positioned(
        top: 0, left: 0, right: 0, child: FavoriteToast(notice: notice));
  }
}
