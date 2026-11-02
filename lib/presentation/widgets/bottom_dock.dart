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
          color: surface,
          borderRadius: BorderRadius.circular(20),
          child: TextField(
            key: const Key('bottom-search-field'),
            controller: controller,
            onChanged: state.updateSearch,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(CupertinoIcons.search),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      );
}
