import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed; // Optional custom callback
  final IconData icon; // Custom icon for the button
  final Color? iconColor; // Custom icon color
  final double iconSize; // Custom icon size

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back, // Default icon
    this.iconColor = Colors.white,
    this.iconSize = 24.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
      onPressed: onPressed ?? () {
        // Navigate back to the previous screen
        Navigator.pop(context);
      },
    );
  }
}