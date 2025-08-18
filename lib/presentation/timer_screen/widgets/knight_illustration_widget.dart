import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/core/widgets/inner_shadow.dart';

class KnightIllustrationWidget extends StatelessWidget {
  const KnightIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.5),
              width: 5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 5,
              ),
            ),
            child: InnerShadow(
              key: Key('shadow'),
              child: Image.asset(
                'assets/images/knight.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
