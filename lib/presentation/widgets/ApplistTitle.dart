
import 'package:app_locker360/presentation/widgets/ActionBuutton.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:app_locker360/data/models/apps_config.dart';
import 'package:google_fonts/google_fonts.dart';



class AppListTile extends StatelessWidget {
  final Application app;
  final VoidCallback onLockToggle;
  final VoidCallback onInternetToggle;
  final VoidCallback onHiddenToggle;
  final VoidCallback onLongPress;

  const AppListTile({
    required this.app,
    required this.onLockToggle,
    required this.onInternetToggle,
    required this.onHiddenToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final config = HiveService.getAppConfig(app.packageName);
    final isLocked = config?.isLocked ?? false;
    final isHidden = config?.isHidden ?? false;
    final blockInternet = config?.blockInternet ?? NetBlock.none;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
                          color: Colors.white,
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
                          color: Colors.white60,
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
                    // Hidden toggle
                    ActionButton(
                      icon: isHidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: isHidden ? Colors.orange : Colors.white60,
                      onTap: onHiddenToggle,
                    ),

                    const SizedBox(width: 4),

                    // Internet block toggle
                    ActionButton(
                      icon: _getInternetIcon(blockInternet),
                      color: _getInternetColor(blockInternet),
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
                          : Colors.white60,
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

  Color _getInternetColor(NetBlock block) {
    switch (block) {
      case NetBlock.none:
        return Colors.white60;
      case NetBlock.wifi:
      case NetBlock.mobile:
        return Colors.orange;
      case NetBlock.all:
        return Colors.redAccent;
    }
  }
}
