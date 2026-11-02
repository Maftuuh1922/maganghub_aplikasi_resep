import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../logic/app_state.dart';
import 'glass.dart';

const double kSearchBarHorizontalMargin = 16;
const double kSearchIconSize = 20;
const double kSearchIconTextGap = 10;
const double kSearchTextSize = 15;
const Color kSearchHintColor = Color(0x8CFFFFFF);

class BottomDock extends StatelessWidget {
  final TextEditingController controller;
  final AppState state;

  const BottomDock({
    super.key,
    required this.controller,
    required this.state,
  });

  @override
  Widget build(BuildContext context) => GlassSearchBar(
        key: const Key('bottom-search-pill'),
        controller: controller,
        onChanged: state.updateSearch,
      );
}

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => FloatingGlass(
        height: kFloatingBarHeight,
        radius: BorderRadius.circular(kFloatingBarHeight / 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSearchBarHorizontalMargin,
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.search,
                size: kSearchIconSize,
                color: kSearchHintColor,
              ),
              const SizedBox(width: kSearchIconTextGap),
              Expanded(
                child: TextField(
                  key: const Key('bottom-search-field'),
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: kSearchTextSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari resep...',
                    hintStyle: TextStyle(
                      fontSize: kSearchTextSize,
                      fontWeight: FontWeight.w500,
                      color: kSearchHintColor,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
