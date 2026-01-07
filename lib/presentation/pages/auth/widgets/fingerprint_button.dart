import 'package:flutter/material.dart';

/// Fingerprint button with pulse animation
class FingerprintButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Animation<double> pulseAnimation;

  const FingerprintButton({
    super.key,
    required this.onPressed,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FACFE).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.fingerprint_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
