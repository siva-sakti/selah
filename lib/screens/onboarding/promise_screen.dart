import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import 'tradition_screen.dart';

class PromiseScreen extends StatelessWidget {
  const PromiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SelahColors.deepNavy,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SelahSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Visual representation - phone transforming
              _buildVisual(),
              SizedBox(height: SelahSpacing.xxxl),
              // Promise text
              Text(
                'Selah places Scripture between you and the apps that steal your peace.',
                style: SelahTypography.scriptureDisplay.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SelahSpacing.xl),
              Text(
                'When you reach for distraction, you\'ll find a prayer instead.',
                style: SelahTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // Set up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TraditionScreen()),
                    );
                  },
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
                    'Set up my guard',
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

  Widget _buildVisual() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: SelahColors.sacredGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_android,
              size: 48,
              color: SelahColors.sacredGold.withValues(alpha: 0.5),
            ),
            SizedBox(height: SelahSpacing.lg),
            Icon(
              Icons.arrow_downward,
              size: 24,
              color: SelahColors.sacredGold.withValues(alpha: 0.7),
            ),
            SizedBox(height: SelahSpacing.lg),
            Text(
              '✦',
              style: TextStyle(
                fontSize: 48,
                color: SelahColors.sacredGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
