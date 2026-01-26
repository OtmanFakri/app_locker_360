import 'dart:ui';

import 'package:app_locker360/presentation/pages/lock_screen/screen_lock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_locker360/data/datasources/mmkv_service.dart';
import 'package:app_locker360/presentation/pages/onboarding/page.dart';
import 'package:app_locker360/presentation/pages/auth/auth_page.dart';
import 'package:mmkv/mmkv.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:app_locker360/data/services/ad_helper.dart';
import 'package:app_locker360/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize MMKV
  await MMKV.initialize();
  await MMKVService.init();
  await MMKVService.openBoxes();
  await MMKVService.initializeGlobalSettings();

  // Initialize Google Mobile Ads
  await AdHelper.initialize();

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
  DartPluginRegistrant.ensureInitialized();
  await MMKVService.initBackground(); // Initialize MMKV for background

  String? tempUnlockedPackage;

  // Setup Listeners
  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((event) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((event) => service.setAsBackgroundService());
  }
  service.on('stopService').listen((event) => service.stopSelf());

  service.on('unlockPackage').listen((event) {
    if (event != null && event['package'] != null) {
      tempUnlockedPackage = event['package'];
      print("🔓 Service: Unlocked $tempUnlockedPackage locally");
    }
  });

  // Config update listener (MMKV doesn't need box refresh like Hive)
  service.on('updateConfig').listen((event) async {
    print("🔄 SIGNAL: Config update received (MMKV auto-syncs)");
    // MMKV automatically syncs with disk via mmap, no manual refresh needed
  });

  print("==== Service Started Loop ===");
  final myLockerPackageName = 'com.example.app_locker360';
  String? lastPackageName;

  while (true) {
    try {
      final endData = DateTime.now();
      // Khlliha 2 Minutes (bach t-lqat event dima)
      final startData = endData.subtract(const Duration(minutes: 2));

      List<EventUsageInfo> events = await UsageStats.queryEvents(
        startData,
        endData,
      );
      var foregroundEvents = events.where((e) => e.eventType == '1').toList();

      if (foregroundEvents.isNotEmpty) {
        foregroundEvents.sort(
          (a, b) => int.parse(b.timeStamp!).compareTo(int.parse(a.timeStamp!)),
        );

        final currentPackage = foregroundEvents.first.packageName!;

        if (currentPackage == myLockerPackageName) {
          await Future.delayed(const Duration(milliseconds: 200));
          continue;
        }

        // --- SWITCH LOGIC ---
        // Nta gulti "f dik lhda khso i3wd itekd"
        // Hna Service ghadi y-checki Hive direct
        if (lastPackageName != null && lastPackageName != currentPackage) {
          print("🔄 Switched: $lastPackageName -> $currentPackage");
          await MMKVService.setLockedPackage(null);
          tempUnlockedPackage = null;
          // Remove from temporary unlock list
          await MMKVService.removeTemporarilyUnlocked(lastPackageName!);
        }

        // --- LOCK CHECK ---
        // MMKV auto-syncs, so getAppConfig always returns fresh data
        final appConfig = MMKVService.getAppConfig(currentPackage);

        // Debug chno 9rina
        if (appConfig != null) {
          // print("Check $currentPackage: Locked=${appConfig.isLocked}");
        }

        final isUnlockedLocally = tempUnlockedPackage == currentPackage;
        final isUnlockedMMKV = MMKVService.isTemporarilyUnlocked(
          currentPackage,
        );

        if (appConfig != null &&
            appConfig.isLocked &&
            !isUnlockedLocally &&
            !isUnlockedMMKV) {
          // Check if this is a system installer package
          final isSystemInstaller = [
            'com.android.packageinstaller',
            'com.google.android.packageinstaller',
            'com.android.settings',
            'com.android.vending',
            'com.miui.packageinstaller',
            'com.miui.securitycenter',
          ].contains(currentPackage);

          if (isSystemInstaller) {
            print('🚨 ========================================');
            print('🚨 SYSTEM INSTALLER DETECTED!');
            print('🚨 Package: $currentPackage');
            print('🚨 User is trying to uninstall an app!');
            print('🚨 Showing PIN screen...');
            print('🚨 ========================================');
          } else {
            print("🔒 LOCKING NOW: $currentPackage");
          }

          await MMKVService.setLockedPackage(currentPackage);

          await Future.delayed(const Duration(milliseconds: 50));

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
          await Future.delayed(const Duration(milliseconds: 200));
        }

        lastPackageName = currentPackage;
      }
    } catch (e) {
      print("Error in Loop: $e");
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// Global function to trigger app rebuild (for language switching)
void rebuildMainApp() {
  _MainAppState._rebuildApp();
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

  // Locale and Theme state
  late String _currentLocale;
  String _currentTheme = 'Light';

  // Static callback for settings page to trigger rebuild
  static _MainAppState? _instance;

  static void _rebuildApp() {
    _instance?.setState(() {
      final settings = MMKVService.getGlobalSettings();
      _instance?._currentLocale = settings.preferredLanguage;
      _instance?._currentTheme = settings.appTheme;
    });
  }

  @override
  void initState() {
    super.initState();
    _instance = this;
    final settings = MMKVService.getGlobalSettings();
    _currentLocale = settings.preferredLanguage;
    _currentTheme = settings.appTheme;

    WidgetsBinding.instance.addObserver(this);
    _initLifecycleListeners();
  }

  @override
  void dispose() {
    _instance = null;
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
    final locale = Locale(_currentLocale);

    ThemeMode themeMode;
    if (_currentTheme == 'System') {
      themeMode = ThemeMode.system;
    } else if (_currentTheme == 'Dark') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }

    return MaterialApp(
      title: 'App Locker 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(
          0xFFF5F6FA,
        ), // Light grey background
        cardColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        cardColor: const Color(0xFF1A1F3A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F3A),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeMode,
      // Localization
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // Arabic
        Locale('en'), // English
      ],
      locale: locale,
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
        // Note: MMKV doesn't have ValueListenable like Hive
        // We'll use a simple rebuild approach with the lockStateBox
        final lockedPackage = MMKVService.lockStateBox.decodeString(
          'current_locked_package',
        );
        // Logic:
        // Ila kanet kyna 'lockedPackage', affichi LockScreen FO9 kulchi.
        // Ila makantch, affichi 'child' (li howa l-app l-3adya).

        return Stack(
          children: [
            // Layer 1: Normal app (Home, Splash, etc.)
            if (child != null) child,

            // Layer 2: Lock Screen (Overlay)
            if (lockedPackage != null)
              Positioned.fill(
                child: ScreenLockPage(lockedPackageName: lockedPackage),
              ),

            // If we received an intent in background, show lock screen
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
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    // Check if user has completed onboarding
    final settings = MMKVService.getGlobalSettings();

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
