import 'package:flutter/material.dart';
import 'small_wood_button.dart';

class MedievalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MedievalBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SmallWoodButton(
      label: '<',
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      // Assuming SmallWoodButton handles sizing well, otherwise we wraps it.
    );
  }
}
