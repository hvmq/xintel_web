import 'dart:ui';

class MenuItem {
  final String label;
  final Object icon;
  final bool isDestuctive;
  final VoidCallback onPressed;

  // contsructor
  const MenuItem({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isDestuctive = false,
  });
}
