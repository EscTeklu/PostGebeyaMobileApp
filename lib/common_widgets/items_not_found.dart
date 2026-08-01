import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';

class ItemsNotFound extends StatelessWidget {
  const ItemsNotFound({this.text, super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              text ?? context.locale!.global_items_not_available,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
