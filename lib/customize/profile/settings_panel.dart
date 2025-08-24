import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/customize/profile/bouncing_card.dart';

class SettingsPanel extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const SettingsPanel({
    super.key,
    required this.title,
    required this.items,
    this.press,
  });

  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          //const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              children:
                  items.map<Widget>((item) {
                    return BouncingCard(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      onTap: item['press'],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
