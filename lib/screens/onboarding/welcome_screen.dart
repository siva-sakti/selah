import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import 'promise_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PromiseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SelahColors.deepNavy,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(SelahSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Gold cross
                Text(
                  '✦',
                  style: TextStyle(
                    fontSize: 64,
                    color: SelahColors.sacredGold,
                  ),
                ),
                SizedBox(height: SelahSpacing.xxxl),
                // Scripture quote
                Text(
                  '"Be still, and know that I am God."',
                  style: SelahTypography.scriptureDisplay,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SelahSpacing.sm),
                Text(
                  '— Psalm 46:10',
                  style: SelahTypography.scriptureReference,
                ),
                SizedBox(height: SelahSpacing.huge),
                // Welcome text
                Text(
                  'Welcome to Selah.',
                  style: SelahTypography.breathPrayer,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SelahSpacing.lg),
                Text(
                  'A sacred pause between you and distraction.',
                  style: SelahTypography.bodyLight,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                // Begin button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToNextScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SelahColors.sacredGold,
                      foregroundColor: SelahColors.deepNavy,
                      padding: EdgeInsets.symmetric(
                        vertical: SelahSpacing.buttonPaddingV,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Begin',
                      style: SelahTypography.buttonPrimary,
                    ),
                  ),
                ),
                SizedBox(height: SelahSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
