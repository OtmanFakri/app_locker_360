import 'dart:ui';

import 'package:app_locker360/presentation/pages/lock_screen/screen_lock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';
import 'package:app_locker360/presentation/pages/auth/auth_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await HiveService.init();
  await HiveService.openBoxes();
  await HiveService.initializeGlobalSettings();

  final box = HiveService.lockStateBox;
  if (box.get('current_locked_package') == null) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Background service
  await initializeService();
  runApp(const MainApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // 1. Init Dart
  DartPluginRegistrant.ensureInitialized();

  // 2. Init Hive (Darouri f Background)
  await HiveService.initBackground();

  // Local active unlock cache (Active for this session)
  // Hadi hiya li ghat-men3 l-loop hit Hive tape chwya
  String? tempUnlockedPackage;

  // 3. Configure Service
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Hna fin UI ghay-goul l-Service: "Safe rani hellit had l-package"
  service.on('unlockPackage').listen((event) {
    if (event != null && event['package'] != null) {
      tempUnlockedPackage = event['package'];
      print("🔓 Service Received Unlock: $tempUnlockedPackage");

      // Reset after 30 seconds (just in case)
      Future.delayed(const Duration(seconds: 30), () {
        if (tempUnlockedPackage == event['package']) {
          tempUnlockedPackage = null;
        }
      });
    }
  });

  print("==== Service Started Loop ===");
  final myLockerPackageName = 'com.example.app_locker360';

  // 4. INFINITE LOOP (Machi Timer)
  while (true) {
    try {
      // Logic Time: N-choufo chno tra f 5 d-tawani l-akhira
      final endData = DateTime.now();
      final startData = endData.subtract(const Duration(seconds: 5));

      // Query
      List<EventUsageInfo> events = await UsageStats.queryEvents(
        startData,
        endData,
      );

      // Filter: Gher li banou f Foreground (type 1)
      var foregroundEvents = events.where((e) => e.eventType == '1').toList();

      if (foregroundEvents.isNotEmpty) {
        // Sort: Jib jdid howa l-lewel
        foregroundEvents.sort(
          (a, b) => int.parse(b.timeStamp!).compareTo(int.parse(a.timeStamp!)),
        );

        final currentEvent = foregroundEvents.first;
        final currentPackage = currentEvent.packageName!;

        // Ignore self
        if (currentPackage == myLockerPackageName) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        // Check if this app is actually locked
        final appConfig = HiveService.getAppConfig(currentPackage);

        // Check Local Cache FIRST (Fastest) or Hive (Slowest)
        final isUnlockedLocally = tempUnlockedPackage == currentPackage;

        if (appConfig != null &&
            appConfig.isLocked &&
            !isUnlockedLocally &&
            !HiveService.isTemporarilyUnlocked(currentPackage)) {
          // This app is locked! Show the lock screen
          print("🔒 App is LOCKED: $currentPackage");

          // 1. Save the locked package to Hive
          await HiveService.setLockedPackage(currentPackage);

          // Debug Notification
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "App Locker Active",
              content: "Locked: $currentPackage",
            );
          }

          await Future.delayed(const Duration(milliseconds: 100));

          // 2. Launch the lock screen intent via Main Channel
          final intent = AndroidIntent(
            action: 'android.intent.action.MAIN',
            package: myLockerPackageName,
            category: 'android.intent.category.LAUNCHER',
            componentName: '$myLockerPackageName.MainActivity',
            arguments: <String, dynamic>{'locked_package': currentPackage},
            flags: <int>[
              Flag.FLAG_ACTIVITY_NEW_TASK,
              Flag.FLAG_ACTIVITY_REORDER_TO_FRONT,
              Flag.FLAG_ACTIVITY_SINGLE_TOP,
              Flag.FLAG_ACTIVITY_CLEAR_TOP,
            ],
          );
          await intent.launch();

          // Wait a bit to avoid spamming
          await Future.delayed(const Duration(milliseconds: 1000));
        } else {
          // App is not locked or is allowed
          if (isUnlockedLocally) {
            print("🔓 Allowed (Locally): $currentPackage");
          }
        }
      }
    } catch (e) {
      print("Error in Loop: $e");
    }

    // 5. Delay
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, this.initialLockedPackage});
  final String? initialLockedPackage;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  String? receivedLockedPackage;
  static const _intentChannel = MethodChannel(
    'com.example.app_locker360/intent',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLifecycleListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // MethodChannel doesn't need explicit disposal like a stream subscription here
    // but we should set handler to null if we want to be clean, though rarely needed for main app
    _intentChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (receivedLockedPackage != null) {
        print("⏸️ App Paused: Clearing receivedLockedPackage");
        setState(() {
          receivedLockedPackage = null;
        });
      }
    }
  }

  Future<void> _initLifecycleListeners() async {
    // 1. Setup Listener for New Intents (Background -> Foreground)
    _intentChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNewIntent') {
        final extras = call.arguments;
        if (extras is Map) {
          _handleIntentExtras(extras);
        }
      }
    });

    // 2. Check Initial Intent (Cold Start)
    try {
      final initialExtras = await _intentChannel.invokeMethod(
        'getInitialIntent',
      );
      if (initialExtras is Map) {
        print("🥶 Cold Start Intent Data: $initialExtras");
        _handleIntentExtras(initialExtras);
      }
    } catch (e) {
      print("Error checking initial intent: $e");
    }
  }

  void _handleIntentExtras(Map extras) {
    final lockedPackage = extras['locked_package'];
    if (lockedPackage != null && lockedPackage is String) {
      print("🔔 Intent Detected Locked Package: $lockedPackage");
      setState(() {
        receivedLockedPackage = lockedPackage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Locker 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      // Hada howa l-entree l-3adya (Splash -> Auth -> Home)
      // Ila jana locked package mn intent (Cold start awla Stream), n-affichiw ScreenLockPage
      home: receivedLockedPackage != null
          ? ScreenLockPage(lockedPackageName: receivedLockedPackage!)
          : (widget.initialLockedPackage != null
                ? ScreenLockPage(
                    lockedPackageName: widget.initialLockedPackage!,
                  )
                : const SplashScreen()),

      // HNA FIN KAYN SSER: Builder kay-ghellef l-app kamla
      builder: (context, child) {
        return ValueListenableBuilder(
          valueListenable: HiveService.lockStateBox.listenable(),
          builder: (context, box, _) {
            final lockedPackage = box.get('current_locked_package');
            // Logic:
            // Ila kanet kyna 'lockedPackage', affichi LockScreen FO9 kulchi.
            // Ila makantch, affichi 'child' (li howa l-app l-3adya).

            return Stack(
              children: [
                // Tabaqa 1: L-App l-3adya (Home, Splash, etc..)
                if (child != null) child,

                // Tabaqa 2: Lock Screen (Overlay)
                // N-zido hta receivedLockedPackage f l-overlay bach yban dghya
                if (lockedPackage != null)
                  Positioned.fill(
                    child: ScreenLockPage(lockedPackageName: lockedPackage),
                  ),

                // Ila jana Intent f Background, ymken Hive mazal ma wslatch l update via Stream
                // So n-forcew l-overlay hna
                if (receivedLockedPackage != null && lockedPackage == null)
                  Positioned.fill(
                    child: ScreenLockPage(
                      lockedPackageName: receivedLockedPackage!,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Splash screen to check onboarding status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check if user has completed onboarding
    final settings = HiveService.getGlobalSettings();

    if (settings.hasCompletedOnboarding) {
      // User has completed onboarding, show auth screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } else {
      // First time user, show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with gradient
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
