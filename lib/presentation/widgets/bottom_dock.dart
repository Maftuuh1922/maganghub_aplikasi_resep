import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../logic/app_state.dart';
import 'glass.dart';

class BottomDock extends StatelessWidget {
  final TextEditingController controller;
  final AppState state;
  const BottomDock({
    super.key,
    required this.controller,
    required this.state,
  });

  @override
  Widget build(BuildContext context) => Glass(
        key: const Key('bottom-search-pill'),
        radius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: TextField(
          key: const Key('bottom-search-field'),
          controller: controller,
          onChanged: state.updateSearch,
          decoration: const InputDecoration(
            hintText: 'Cari resep...',
            prefixIcon: const Icon(CupertinoIcons.search),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 52,
              minHeight: 58,
            ),
            isDense: true,
            constraints: const BoxConstraints(minHeight: 58),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
          ),
        ),
      );
}
