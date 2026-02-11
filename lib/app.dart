import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';
import 'screens/home/home_screen.dart';
import 'screens/journey/journey_screen.dart';
import 'screens/offerings/offerings_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/accessibility_handler.dart';
import 'services/overlay_data_service.dart';
import 'database/database_helper.dart';
import 'models/intervention.dart';

class SelahApp extends StatelessWidget {
  const SelahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for navy background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: SelahColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: SelahColors.deepNavy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Selah',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const MainNavigationScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SelahColors.deepNavy,
      primaryColor: SelahColors.sacredGold,
      colorScheme: const ColorScheme.dark(
        primary: SelahColors.sacredGold,
        secondary: SelahColors.sacredGold,
        surface: SelahColors.deepNavy,
        onPrimary: SelahColors.deepNavy,
        onSecondary: SelahColors.deepNavy,
        onSurface: SelahColors.warmCream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SelahColors.deepNavy,
        foregroundColor: SelahColors.warmCream,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: SelahColors.deepNavy,
        selectedItemColor: SelahColors.sacredGold,
        unselectedItemColor: SelahColors.subduedGray,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: SelahTypography.navLabel.copyWith(
          color: SelahColors.sacredGold,
        ),
        unselectedLabelStyle: SelahTypography.navLabel,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelahColors.sacredGold,
          foregroundColor: SelahColors.deepNavy,
          textStyle: SelahTypography.buttonPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SelahColors.subduedGray,
          textStyle: SelahTypography.buttonSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: SelahColors.warmCream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final _accessibilityHandler = AccessibilityHandler();
  final _overlayDataService = OverlayDataService();
  final _db = DatabaseHelper();

  // Periodic timer to check accessibility permission
  Timer? _accessibilityCheckTimer;

  final List<Widget> _screens = const [
    HomeScreen(),
    JourneyScreen(),
    OfferingsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAccessibilityService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('>>> LIFECYCLE STATE CHANGED: $state');
    // Re-check accessibility when app resumes (user might have enabled it in settings)
    if (state == AppLifecycleState.resumed) {
      debugPrint('>>> APP RESUMED - checking accessibility...');
      _checkAndStartAccessibility();
      _consumePendingInterventionResult();
    }
  }

  /// Check for and consume any pending intervention result from the overlay
  Future<void> _consumePendingInterventionResult() async {
    try {
      final result = await _overlayDataService.consumePendingResult();
      if (result == null) return;

      // Write the intervention to the database
      final intervention = Intervention(
        timestamp: result.timestamp,
        appPackage: result.appPackage,
        outcome: result.outcome,
        reason: result.reason,
        offeringText: result.offeringText,
        scriptureShown: result.scriptureShown,
        pauseDuration: result.pauseDuration,
        attemptNumber: result.attemptNumber,
        timeSavedEst: result.timeSavedEst,
      );

      await _db.insertIntervention(intervention);
      debugPrint('MainApp: Logged intervention - ${result.outcome} for ${result.appPackage}');

      // Reset overlay tracking in accessibility handler
      _accessibilityHandler.onOverlayDismissed();
    } catch (e) {
      debugPrint('MainApp: Error consuming intervention result: $e');
    }
  }

  Future<void> _initializeAccessibilityService() async {
    // HARDCODED FOR TESTING: Add Instagram as a guarded app
    _accessibilityHandler.addGuardedApp(CommonApps.instagram);

    // Also add YouTube and TikTok for testing variety
    _accessibilityHandler.addGuardedApp(CommonApps.youtube);
    _accessibilityHandler.addGuardedApp(CommonApps.tiktok);

    debugPrint('AccessibilityHandler: Guarded apps configured: Instagram, YouTube, TikTok');

    // Check if accessibility is already enabled
    final isEnabled = await _accessibilityHandler.isAccessibilityEnabled();

    if (isEnabled) {
      // Permission already granted - start listening immediately
      debugPrint('AccessibilityHandler: Permission already enabled, starting listener');
      await _accessibilityHandler.startListening(force: true);
    } else {
      // Permission not granted yet - start periodic checking
      debugPrint('AccessibilityHandler: Permission not enabled, starting periodic check');
      _startAccessibilityCheck();
    }
  }

  /// Start periodic checking for accessibility permission
  void _startAccessibilityCheck() {
    // Check every 2 seconds if accessibility becomes enabled
    _accessibilityCheckTimer?.cancel();
    _accessibilityCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final isEnabled = await _accessibilityHandler.isAccessibilityEnabled();
      if (isEnabled) {
        debugPrint('AccessibilityHandler: Permission detected via periodic check!');
        timer.cancel();
        _accessibilityCheckTimer = null;
        await _accessibilityHandler.startListening(force: true);
        debugPrint('AccessibilityHandler: Listener started - protection is now active');
      }
    });
  }

  Future<void> _checkAndStartAccessibility() async {
    debugPrint('>>> _checkAndStartAccessibility called');
    final isEnabled = await _accessibilityHandler.isAccessibilityEnabled();
    debugPrint('>>> Accessibility permission check result: $isEnabled');

    if (isEnabled) {
      // Stop periodic checking if it was running
      _accessibilityCheckTimer?.cancel();
      _accessibilityCheckTimer = null;

      debugPrint('>>> Permission IS enabled - force restarting stream...');
      // Force restart the stream to ensure it's connected after permission granted
      await _accessibilityHandler.startListening(force: true);
      debugPrint('>>> Stream restarted successfully - protection is active');
    } else {
      debugPrint('AccessibilityHandler: Accessibility not enabled - enable in Settings > Accessibility > Selah');
      // Make sure periodic checking is running
      if (_accessibilityCheckTimer == null || !_accessibilityCheckTimer!.isActive) {
        _startAccessibilityCheck();
      }
    }
  }

  @override
  void dispose() {
    _accessibilityCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _accessibilityHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: SelahColors.sacredGold.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.today_outlined),
              activeIcon: Icon(Icons.today),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Journey',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism_outlined),
              activeIcon: Icon(Icons.volunteer_activism),
              label: 'Offerings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
