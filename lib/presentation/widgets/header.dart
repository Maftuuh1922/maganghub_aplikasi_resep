import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Row(children: [
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
