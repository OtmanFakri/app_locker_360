import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/app_logo.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/error_message.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/fingerprint_button.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class ScreenLockPage extends StatefulWidget {
  final String? lockedPackageName;
  const ScreenLockPage({super.key, this.lockedPackageName});

  @override
  State<ScreenLockPage> createState() => _ScreenLockPageState();
}

class _ScreenLockPageState extends State<ScreenLockPage>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  bool _showError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

  Future<void> _verifyPin() async {
    final settings = HiveService.getGlobalSettings();
    if (_enteredPin == settings.masterPin) {
      // 1. Inform Background Service IMMEDIATELY (Fast)
      if (widget.lockedPackageName != null) {
        print(
          "🔓 Sending unlockPackage event for: ${widget.lockedPackageName}",
        );
        FlutterBackgroundService().invoke('unlockPackage', {
          'package': widget.lockedPackageName,
        });
      }

      // 2. Reset Hive Trigger (Persistence)
      await HiveService.setLockedPackage(null);

      // 3. Give Temporary Pass (Hive Backup)
      if (widget.lockedPackageName != null) {
        await HiveService.setTemporarilyUnlocked(widget.lockedPackageName!);
      }

      // 4. Exit App Locker
      if (mounted) {
        SystemNavigator.pop();
      }
    } else {
      // Error Animation...
      _shakeController.forward(from: 0);
      setState(() {
        _showError = true;
        _enteredPin = '';
      });
      print("Invalid PIN");
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

  @override
  Widget build(BuildContext context) {
    final settings = HiveService.getGlobalSettings();

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                          const AppLogo(),

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
                                child: PinDots(
                                  filledCount: _enteredPin.length,
                                  showError: _showError,
                                ),
                              );
                            },
                          ),

                          // Error message
                          if (_showError) ...[
                            const SizedBox(height: 20),
                            const ErrorMessage(),
                          ] else
                            const SizedBox(height: 32),

                          const SizedBox(height: 24),

                          // Fingerprint button (if enabled)
                          if (settings.fingerprintEnabled) ...[
                            FingerprintButton(
                              onPressed: _onFingerprintPressed,
                              pulseAnimation: _pulseAnimation,
                            ),
                            const SizedBox(height: 24),
                          ],

                          const Spacer(),

                          // Number pad
                          NumberPad(
                            onNumberPressed: _onNumberPressed,
                            onDeletePressed: _onDeletePressed,
                          ),

                          const SizedBox(height: 24),

                          // Forgot password link
                          // TextButton(
                          //   onPressed: _onForgotPassword,
                          //   child: Text(
                          //     'نسيت كلمة السر؟',
                          //     style: GoogleFonts.cairo(
                          //       fontSize: 16,
                          //       color: const Color(0xFF667EEA),
                          //       fontWeight: FontWeight.w500,
                          //       decoration: TextDecoration.underline,
                          //     ),
                          //   ),
                          // ),
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
      ),
    );
  }
}
