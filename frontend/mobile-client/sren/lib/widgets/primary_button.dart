import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).elevatedButtonTheme.style;
    final child = switch (icon) {
      null => ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: Text(text),
        ),
      _ => ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(text),
          style: style,
        ),
    };

    return SizedBox(width: double.infinity, child: child);
  }
}
