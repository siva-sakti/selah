import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'database/database_helper.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'theme/colors.dart';
import 'overlay/overlay_main.dart';

/// Entry point for the accessibility overlay.
///
/// CRITICAL: This runs in a SEPARATE Flutter engine from the main app.
/// It cannot share state, providers, or database connections with main().
/// The overlay is triggered by the AccessibilityService when a guarded app is detected.
@pragma("vm:entry-point")
void accessibilityOverlay() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InterventionOverlayStandalone());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: SelahColors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: SelahColors.deepNavy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize database and check onboarding status
  final db = DatabaseHelper();
  final settings = await db.getUserSettings();

  runApp(SelahRoot(onboardingComplete: settings.onboardingComplete));
}

class SelahRoot extends StatelessWidget {
  final bool onboardingComplete;

  const SelahRoot({
    super.key,
    required this.onboardingComplete,
  });

  @override
  Widget build(BuildContext context) {
    // If onboarding is not complete, show onboarding flow
    // Otherwise, show the main app
    if (!onboardingComplete) {
      return MaterialApp(
        title: 'Selah',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: SelahColors.deepNavy,
          primaryColor: SelahColors.sacredGold,
          colorScheme: const ColorScheme.dark(
            primary: SelahColors.sacredGold,
            secondary: SelahColors.sacredGold,
            surface: SelahColors.deepNavy,
          ),
        ),
        home: const WelcomeScreen(),
      );
    }

    return const SelahApp();
  }
}
