import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../logic/app_state.dart';

class FavoriteToast extends StatefulWidget {
  final ToastNotice notice;
  const FavoriteToast({super.key, required this.notice});

  @override
  State<FavoriteToast> createState() => _FavoriteToastState();
}

class _FavoriteToastState extends State<FavoriteToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -.22),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: surface.withOpacity(.98),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: widget.notice.added
                          ? mint.withOpacity(.45)
                          : muted.withOpacity(.45),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.notice.added ? mint : surface2,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.notice.added
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        size: 17,
                        color: widget.notice.added ? bg : muted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.notice.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ]),
                ),
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
    final provider = Provider.of<AppState?>(context);
    if (provider == null) return const SizedBox.shrink();
    final notice = provider.toast;
    if (notice == null) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FavoriteToast(key: ValueKey(notice.id), notice: notice),
    );
  }
}
