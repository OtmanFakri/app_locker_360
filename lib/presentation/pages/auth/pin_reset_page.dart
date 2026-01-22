import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:app_locker360/presentation/pages/home/home_page.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

/// Page to reset the master PIN after backup verification
class PinResetPage extends StatefulWidget {
  const PinResetPage({super.key});

  @override
  State<PinResetPage> createState() => _PinResetPageState();
}

class _PinResetPageState extends State<PinResetPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _showError = false;

  void _onNumberPressed(String number) {
    setState(() {
      _showError = false;
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _saveNewPin();
          }
        }
      } else {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _isConfirming = true;
              });
            });
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _showError = false;
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
          _pin = '';
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _saveNewPin() async {
    if (_pin == _confirmPin) {
      // Save new PIN
      final settings = MMKVService.getGlobalSettings();
      final updatedSettings = settings.copyWith(masterPin: _pin);
      await MMKVService.updateGlobalSettings(updatedSettings);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PIN Reset Successfully', // TODO: Localize
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } else {
      // Mismatch
      setState(() {
        _showError = true;
        _confirmPin = '';
        _isConfirming = false;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        _isConfirming ? l10n.confirmPin : l10n.createPin,
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isConfirming
                            ? l10n.confirmPinDesc
                            : l10n.createPinDesc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.white60,
                        ),
                      ),

                      const SizedBox(height: 48),

                      PinDots(
                        filledCount: _isConfirming
                            ? _confirmPin.length
                            : _pin.length,
                        showError: _showError,
                      ),

                      if (_showError) ...[
                        const SizedBox(height: 20),
                        Text(
                          l10n.pinMismatch,
                          style: GoogleFonts.cairo(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // NumberPad
                      NumberPad(
                        onNumberPressed: _onNumberPressed,
                        onDeletePressed: _onDeletePressed,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
