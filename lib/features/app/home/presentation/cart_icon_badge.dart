import 'package:flutter/material.dart';

/// Icon badge showing the shopping cart items count
class ShoppingCartIconBadge extends StatelessWidget {
  const ShoppingCartIconBadge({super.key, required this.itemsCount});

  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '$itemsCount',
            textAlign: TextAlign.center,
            textScaler: TextScaler.noScaling,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
