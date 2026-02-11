import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../database/database_helper.dart';
import '../../app.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final db = DatabaseHelper();
    final settings = await db.getUserSettings();
    await db.updateUserSettings(
      settings.copyWith(onboardingComplete: true),
    );

    // Seed content if needed
    await db.seedContentIfNeeded();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SelahApp()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SelahColors.deepNavy,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SelahSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Preview of intervention
              _buildInterventionPreview(),
              SizedBox(height: SelahSpacing.xxl),
              // Explanation
              Text(
                'This is what you\'ll see when you reach for a guarded app.',
                style: SelahTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SelahSpacing.lg),
              Text(
                'Read. Pray. Then choose.',
                style: SelahTypography.breathPrayer.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // Ready button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeOnboarding(context),
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
                    'I\'m ready',
                    style: SelahTypography.buttonPrimary,
                  ),
                ),
              ),
              SizedBox(height: SelahSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterventionPreview() {
    return Container(
      padding: EdgeInsets.all(SelahSpacing.xl),
      decoration: BoxDecoration(
        color: SelahColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SelahColors.sacredGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SelahColors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gold cross
          Text(
            '✦',
            style: TextStyle(
              fontSize: 40,
              color: SelahColors.sacredGold,
            ),
          ),
          SizedBox(height: SelahSpacing.xl),
          // Scripture
          Text(
            '"Create in me a clean heart, O God, and renew a right spirit within me."',
            style: SelahTypography.scriptureDisplay.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SelahSpacing.sm),
          Text(
            '— Psalm 51:10',
            style: SelahTypography.scriptureReference.copyWith(fontSize: 12),
          ),
          SizedBox(height: SelahSpacing.xl),
          // Mock buttons
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: SelahSpacing.md),
            decoration: BoxDecoration(
              color: SelahColors.sacredGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Return to prayer',
                style: SelahTypography.buttonPrimary.copyWith(fontSize: 14),
              ),
            ),
          ),
          SizedBox(height: SelahSpacing.md),
          Text(
            'Proceed to Instagram',
            style: SelahTypography.buttonSecondary.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
