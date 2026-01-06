import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:app_locker360/data/models/global_settings.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';

/// شاشة القفل الرئيسية (Auth Screen)
/// تظهر كل مرة يفتح فيها المستخدم التطبيق للدخول إلى لوحة التحكم
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _showError = false;
  int _failedAttempts = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Shake animation for wrong PIN
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Pulse animation for fingerprint icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _showError = false;
      });

      // Auto-verify when 4 digits entered
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _showError = false;
      });
    }
  }

  void _verifyPin() async {
    final settings = HiveService.getGlobalSettings();

    if (_enteredPin == settings.masterPin) {
      // Correct PIN - Navigate to home/dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // Wrong PIN - Show error
      setState(() {
        _showError = true;
        _failedAttempts++;
      });

      // Shake animation
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });

      // Clear PIN after delay
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _enteredPin = '';
          _showError = false;
        });
      }
    }
  }

  void _onFingerprintPressed() {
    // TODO: Implement biometric authentication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'البصمة قيد التطوير',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => _buildForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = HiveService.getGlobalSettings();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Spacer(),

                        // App Logo
                        _buildAppLogo(),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'أدخل الرمز السري',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'للوصول إلى لوحة التحكم',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white60,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // PIN Dots with shake animation
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: _buildPinDots(),
                            );
                          },
                        ),

                        // Error message
                        if (_showError) ...[
                          const SizedBox(height: 20),
                          _buildErrorMessage(),
                        ] else
                          const SizedBox(height: 32),

                        const SizedBox(height: 24),

                        // Fingerprint button (if enabled)
                        if (settings.fingerprintEnabled) ...[
                          _buildFingerprintButton(),
                          const SizedBox(height: 24),
                        ],

                        const Spacer(),

                        // Number pad
                        _buildNumberPad(),

                        const SizedBox(height: 24),

                        // Forgot password link
                        _buildForgotPasswordLink(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Icon(Icons.lock_rounded, size: 50, color: Colors.white),
    );
  }

  Widget _buildPinDots() {
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
            gradient: index < _enteredPin.length
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: index < _enteredPin.length ? null : Colors.white24,
            border: Border.all(
              color: _showError
                  ? Colors.redAccent
                  : (index < _enteredPin.length
                        ? Colors.transparent
                        : Colors.white24),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'رمز خاطئ، حاول مرة أخرى',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _onFingerprintPressed,
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

  Widget _buildNumberPad() {
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
          return _buildNumberButton(
            child: const Icon(Icons.backspace_outlined, color: Colors.white),
            onPressed: _onDeletePressed,
          );
        }
        return _buildNumberButton(
          child: Text(
            number,
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          onPressed: () => _onNumberPressed(number),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _onForgotPassword,
      child: Text(
        'نسيت كلمة السر؟',
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: const Color(0xFF667EEA),
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordDialog() {
    return Dialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'نسيت كلمة السر؟',
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'لاسترجاع كلمة السر، سيتم حذف جميع البيانات وإعادة تعيين التطبيق.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم حذف جميع التطبيقات المقفلة والملفات المشفرة',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _resetApp,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إعادة تعيين',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetApp() async {
    // Close dialog
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
        ),
      ),
    );

    // Clear all data
    await HiveService.clearAllLogs();
    await HiveService.appsConfigBox.clear();
    await HiveService.vaultItemsBox.clear();

    // Reset global settings
    final newSettings = GlobalSettings(hasCompletedOnboarding: false);
    await HiveService.updateGlobalSettings(newSettings);

    // Small delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to onboarding
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
        (route) => false,
      );
    }
  }
}
