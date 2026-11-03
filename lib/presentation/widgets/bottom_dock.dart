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
  Widget build(BuildContext context) => GlassSearchBar(
        controller: controller,
        onChanged: state.updateSearch,
      );
}

class GlassSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const GlassSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = kSearchBarBottomSpacing +
        media.padding.bottom +
        media.viewInsets.bottom;
    const radius = BorderRadius.all(Radius.circular(kSearchBarHeight / 2));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        kSearchBarHorizontalMargin,
        0,
        kSearchBarHorizontalMargin,
        bottomInset,
      ),
      child: FloatingGlass(
        key: const Key('bottom-search-pill'),
        height: kSearchBarHeight,
        radius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kSearchBarHorizontalMargin),
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
      ),
    );
  }
}
