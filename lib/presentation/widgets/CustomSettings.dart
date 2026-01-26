import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/number_pad.dart';
import 'package:app_locker360/presentation/pages/auth/widgets/pin_dots.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/l10n/app_localizations.dart';

/// Custom settings bottom sheet
class CustomSettingsSheet extends StatefulWidget {
  final Application app;

  const CustomSettingsSheet({super.key, required this.app});

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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.setCustomPin,
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
                                enableFingerprint: _config.enableFingerprint,
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
                      textColor: Colors.white,
                      buttonColor: Colors.white.withOpacity(0.1),
                      buttonBorderColor: Colors.transparent,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
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
    final l10n = AppLocalizations.of(context)!;
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

          // Lock Options
          Text(
            l10n.lockMethod,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildLockOption(
                  title: l10n.fingerprintGlobalPin,
                  subtitle: l10n.fingerprintGlobalPinDesc,
                  isSelected:
                      _config.lockType == LockType.global &&
                      _config.enableFingerprint,
                  onTap: () => setState(() {
                    _config = _config.copyWith(
                      lockType: LockType.global,
                      enableFingerprint: true,
                    );
                  }),
                ),
                _buildDivider(),
                _buildLockOption(
                  title: l10n.fingerprintCustomPin,
                  subtitle: l10n.fingerprintCustomPinDesc,
                  isSelected:
                      _config.lockType == LockType.custom &&
                      _config.enableFingerprint,
                  onTap: () {
                    setState(() {
                      _config = _config.copyWith(
                        lockType: LockType.custom,
                        enableFingerprint: true,
                      );
                    });
                    if (_config.customPin == null ||
                        _config.customPin!.isEmpty) {
                      _showPinSetupDialog();
                    }
                  },
                ),
                _buildDivider(),
                _buildLockOption(
                  title: l10n.fingerprintSystemLock,
                  subtitle: l10n.fingerprintSystemLockDesc,
                  isSelected: _config.lockType == LockType.system,
                  onTap: () => setState(() {
                    _config = _config.copyWith(
                      lockType: LockType.system,
                      enableFingerprint:
                          true, // System implies biometric usually
                    );
                  }),
                ),
                _buildDivider(),
                _buildLockOption(
                  title: l10n.pinOnly,
                  subtitle: l10n.pinOnlyDesc,
                  isSelected:
                      (_config.lockType == LockType.global ||
                          _config.lockType == LockType.custom) &&
                      !_config.enableFingerprint,
                  onTap: () {
                    setState(() {
                      if (_config.lockType == LockType.system ||
                          _config.lockType == LockType.fingerprintOnly) {
                        _config = _config.copyWith(lockType: LockType.global);
                      }
                      _config = _config.copyWith(enableFingerprint: false);
                    });
                  },
                  showSettings:
                      !_config.enableFingerprint &&
                      (_config.lockType == LockType.global ||
                          _config.lockType == LockType.custom),
                  onSettingsTap: () {
                    // Toggle between Global and Custom for "PIN Only" mode
                    setState(() {
                      if (_config.lockType == LockType.global) {
                        _config = _config.copyWith(lockType: LockType.custom);
                        if (_config.customPin == null ||
                            _config.customPin!.isEmpty) {
                          _showPinSetupDialog();
                        }
                      } else {
                        _config = _config.copyWith(lockType: LockType.global);
                      }
                    });
                  },
                ),
                if (!_config.enableFingerprint &&
                    (_config.lockType == LockType.global ||
                        _config.lockType == LockType.custom))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.subdirectory_arrow_right,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _config.lockType == LockType.global
                              ? l10n.selectedGlobalPin
                              : l10n.selectedCustomPin,
                          style: GoogleFonts.cairo(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_config.lockType == LockType.global) {
                                _config = _config.copyWith(
                                  lockType: LockType.custom,
                                );
                                if (_config.customPin == null ||
                                    _config.customPin!.isEmpty) {
                                  _showPinSetupDialog();
                                }
                              } else {
                                _config = _config.copyWith(
                                  lockType: LockType.global,
                                );
                              }
                            });
                          },
                          child: Text(
                            l10n.switchAction,
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF667EEA),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildDivider(),
                _buildLockOption(
                  title: l10n.fingerprintOnly,
                  subtitle: l10n.fingerprintOnlyDesc,
                  isSelected: _config.lockType == LockType.fingerprintOnly,
                  onTap: () => setState(() {
                    _config = _config.copyWith(
                      lockType: LockType.fingerprintOnly,
                      enableFingerprint: true,
                    );
                  }),
                ),
              ],
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
                l10n.save,
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

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.white.withOpacity(0.05));
  }

  Widget _buildLockOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool showSettings = false,
    VoidCallback? onSettingsTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF667EEA) : Colors.white24,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF667EEA),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (showSettings)
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white54),
                onPressed: onSettingsTap,
              ),
          ],
        ),
      ),
    );
  }
}
