import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/customize/profile/profile_header.dart';
import 'package:nopcommerce_mobile/customize/profile/settings_panel.dart';

class ProfilePages extends StatelessWidget {
  const ProfilePages({super.key});
  static const Color accentColor = Color(0xFF2C2E7B);

  @override
  Widget build(BuildContext context) {
    final panelItems = [
      {'icon': Icons.language, 'label': 'Language'},
      {'icon': Icons.favorite_border, 'label': 'Favorite'},
      {'icon': Icons.location_on_outlined, 'label': 'Location'},
      {'icon': Icons.nightlight_round, 'label': 'Dark Mode'},
      {'icon': Icons.star_border, 'label': 'Rate us'},
      {'icon': Icons.delete_outline, 'label': 'Delete'},
      {'icon': Icons.help_outline, 'label': 'FAQs'},
      {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: accentColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const ProfileHeader(),
            SettingsPanel(title: 'Account Settings', items: panelItems),
            SettingsPanel(title: 'App Preferences', items: panelItems),
            const SizedBox(height: 8),
            const Text('Contact Phone (9133)', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
