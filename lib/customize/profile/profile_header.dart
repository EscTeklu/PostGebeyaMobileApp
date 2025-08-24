import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'bahar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.edit,
                      color: GlobalVariables.accentColor,
                      size: 18,
                    ),
                  ],
                ),
                const Text('+251944089336'),
                const SizedBox(height: 4),
                /* Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ProfilePages.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('Saved with chipchip 0 Birr',
                    style: TextStyle(fontSize: 12)), 
              ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
