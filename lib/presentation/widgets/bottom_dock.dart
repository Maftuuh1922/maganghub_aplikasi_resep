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

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          key: const Key('bottom-search-pill'),
          color: surface.withOpacity(.88),
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: TextField(
            key: const Key('bottom-search-field'),
            controller: controller,
            onChanged: state.updateSearch,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(CupertinoIcons.search),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 52,
                minHeight: 58,
              ),
              filled: true,
              fillColor: surface.withOpacity(.88),
              isDense: true,
              constraints: const BoxConstraints(minHeight: 58),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: mint, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
            ),
          ),
        ),
      );
}
