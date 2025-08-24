import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';

class BouncingCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BouncingCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<BouncingCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _triggerBounce() async {
    setState(() => _scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 80));
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerBounce,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: GlobalVariables.accentColor, size: 26),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
