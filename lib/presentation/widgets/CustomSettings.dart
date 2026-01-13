import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:device_apps/device_apps.dart';

/// Custom settings bottom sheet
class CustomSettingsSheet extends StatefulWidget {
  final Application app;

  const CustomSettingsSheet({required this.app});

  @override
  State<CustomSettingsSheet> createState() => CustomSettingsSheetState();
}

class CustomSettingsSheetState extends State<CustomSettingsSheet> {
  late AppsConfig _config;

  @override
  void initState() {
    super.initState();
    _config =
        MMKVService.getAppConfig(widget.app.packageName) ??
        AppsConfig(
          packageName: widget.app.packageName,
          appName: widget.app.appName,
        );
  }

  void _saveAndClose() {
    // Validate custom PIN
    if (_config.lockType == LockType.custom &&
        (_config.customPin == null || _config.customPin!.length < 4)) {
      // Revert to global if invalid
      _config = _config.copyWith(lockType: LockType.global);
    }
    MMKVService.addAppConfig(_config);
    Navigator.pop(context);
  }

  Future<void> _showPinSetupDialog() async {
    String pin = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تعيين رمز خاص',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PinDots(filledCount: pin.length),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 400,
                    child: NumberPad(
                      onNumberPressed: (num) {
                        if (pin.length < 4) {
                          setStateDialog(() {
                            pin += num;
                          });
                          if (pin.length == 4) {
                            Navigator.pop(context);
                            setState(() {
                              _config = _config.copyWith(
                                lockType: LockType.custom,
                                customPin: pin,
                              );
                            });
                          }
                        }
                      },
                      onDeletePressed: () {
                        if (pin.isNotEmpty) {
                          setStateDialog(() {
                            pin = pin.substring(0, pin.length - 1);
                          });
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    // Revert if cancelled and invalid
    if (_config.lockType == LockType.custom &&
        (_config.customPin == null || _config.customPin!.isEmpty)) {
      setState(() {
        _config = _config.copyWith(lockType: LockType.global);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (widget.app is ApplicationWithIcon)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    (widget.app as ApplicationWithIcon).icon,
                    width: 48,
                    height: 48,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.app.appName,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lock type
          Text(
            'نوع القفل',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  label: 'رمز عام',
                  isSelected: _config.lockType == LockType.global,
                  onTap: () {
                    setState(() {
                      _config = _config.copyWith(lockType: LockType.global);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionButton(
                  label: 'رمز خاص',
                  isSelected: _config.lockType == LockType.custom,
                  onTap: () {
                    setState(() {
                      _config = _config.copyWith(lockType: LockType.custom);
                    });
                    if (_config.customPin == null ||
                        _config.customPin!.isEmpty) {
                      _showPinSetupDialog();
                    }
                  },
                ),
              ),
            ],
          ),

          if (_config.lockType == LockType.custom)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextButton(
                  onPressed: _showPinSetupDialog,
                  child: Text(
                    _config.customPin != null && _config.customPin!.isNotEmpty
                        ? 'تغيير الرمز الخاص'
                        : 'تعيين الرمز الخاص',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF667EEA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'حفظ',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

/// Option button widget
class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
