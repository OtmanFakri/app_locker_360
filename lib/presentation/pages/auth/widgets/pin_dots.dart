import 'package:flutter/material.dart';

/// PIN dots widget - shows 4 dots representing PIN entry
class PinDots extends StatelessWidget {
  final int filledCount;
  final bool showError;

  const PinDots({super.key, required this.filledCount, this.showError = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: index < filledCount
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: index < filledCount ? null : Colors.white24,
            border: Border.all(
              color: showError
                  ? Colors.redAccent
                  : (index < filledCount ? Colors.transparent : Colors.white24),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
