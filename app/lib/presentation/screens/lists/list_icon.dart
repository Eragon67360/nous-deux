import 'package:flutter/material.dart';

import 'package:nousdeux/domain/entities/shared_list_entity.dart';

IconData listIconData(ListIcon icon) => switch (icon) {
  ListIcon.list => Icons.checklist_rounded,
  ListIcon.cart => Icons.shopping_cart_outlined,
  ListIcon.star => Icons.star_outline_rounded,
  ListIcon.home => Icons.home_outlined,
  ListIcon.gift => Icons.card_giftcard_outlined,
};

/// The icon in a soft tinted tile, as on the lists screen.
class ListIconTile extends StatelessWidget {
  const ListIconTile(this.icon, {super.key, this.size = 40});

  final ListIcon icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(listIconData(icon), size: size * 0.5, color: scheme.primary),
    );
  }
}
