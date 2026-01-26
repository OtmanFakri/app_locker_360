import 'package:app_locker360/presentation/widgets/ActionBuutton.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:google_fonts/google_fonts.dart';

class AppListTile extends StatelessWidget {
  final Application app;
  final VoidCallback onLockToggle;
  final VoidCallback onInternetToggle;
  final VoidCallback onUninstallProtectionToggle;
  final VoidCallback onLongPress;

  const AppListTile({
    super.key,
    required this.app,
    required this.onLockToggle,
    required this.onInternetToggle,
    required this.onUninstallProtectionToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final config = MMKVService.getAppConfig(app.packageName);
    final isLocked = config?.isLocked ?? false;
    final hasUninstallProtection = config?.uninstallProtection ?? false;
    final blockInternet = config?.blockInternet ?? NetBlock.none;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // App icon
                if (app is ApplicationWithIcon)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      (app as ApplicationWithIcon).icon,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.android, color: Colors.white),
                  ),

                const SizedBox(width: 12),

                // App name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: GoogleFonts.cairo(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.packageName,
                        style: GoogleFonts.cairo(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Uninstall Protection toggle
                    ActionButton(
                      icon: hasUninstallProtection
                          ? Icons.admin_panel_settings_rounded
                          : Icons.no_encryption_rounded,
                      color: hasUninstallProtection
                          ? const Color(0xFF9C27B0)
                          : Theme.of(context).disabledColor,
                      onTap: onUninstallProtectionToggle,
                    ),

                    const SizedBox(width: 4),

                    // Internet block toggle
                    ActionButton(
                      icon: _getInternetIcon(blockInternet),
                      color: _getInternetColor(context, blockInternet),
                      onTap: onInternetToggle,
                    ),

                    const SizedBox(width: 4),

                    // Lock toggle
                    ActionButton(
                      icon: isLocked
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      color: isLocked
                          ? const Color(0xFF667EEA)
                          : Theme.of(context).disabledColor,
                      onTap: onLockToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getInternetIcon(NetBlock block) {
    switch (block) {
      case NetBlock.none:
        return Icons.wifi_rounded;
      case NetBlock.wifi:
        return Icons.wifi_off_rounded;
      case NetBlock.mobile:
        return Icons.signal_cellular_off_rounded;
      case NetBlock.all:
        return Icons.block_rounded;
    }
  }

  Color _getInternetColor(BuildContext context, NetBlock block) {
    switch (block) {
      case NetBlock.none:
        return Theme.of(context).disabledColor;
      case NetBlock.wifi:
      case NetBlock.mobile:
        return Colors.orange;
      case NetBlock.all:
        return Colors.redAccent;
    }
  }
}
