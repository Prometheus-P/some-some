import 'package:flutter/material.dart';

import '../tds.dart';

class TossButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color; // Allow null for default brand color
  final IconData? icon;
  final double width;

  const TossButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.icon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final buttonColor = color ?? cs.primary;

    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: cs.onPrimary,
      padding: const EdgeInsets.symmetric(
        horizontal: spaceLarge,
        vertical: spaceMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaceXxSmall), // 4.0
      ),
      textStyle: bodyBig(cs).copyWith(fontWeight: FontWeight.bold),
    );

    if (icon != null) {
      return SizedBox(
        width: width,
        child: FilledButton.icon(
          style: buttonStyle,
          onPressed: onTap,
          icon: Icon(icon!, size: 20),
          label: Text(text),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: FilledButton(
        style: buttonStyle,
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
