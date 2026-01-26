import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Number pad widget for PIN entry
class NumberPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;
  final Color? textColor;
  final Color? buttonColor;
  final Color? buttonBorderColor;

  const NumberPad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.textColor,
    this.buttonColor,
    this.buttonBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildNumberRow(['', '0', 'delete']),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        if (number == 'delete') {
          return _NumberButton(
            onPressed: onDeletePressed,
            color: buttonColor,
            borderColor: buttonBorderColor,
            child: Icon(
              Icons.backspace_outlined,
              color: textColor ?? Colors.white,
            ),
          );
        }
        return _NumberButton(
          onPressed: () => onNumberPressed(number),
          color: buttonColor,
          borderColor: buttonBorderColor,
          child: Text(
            number,
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? color;
  final Color? borderColor;

  const _NumberButton({
    required this.child,
    required this.onPressed,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
