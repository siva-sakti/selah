import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SelahColors.deepNavy,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gold cross
              Text(
                '✦',
                style: TextStyle(
                  fontSize: 48,
                  color: SelahColors.sacredGold,
                ),
              ),
              SizedBox(height: SelahSpacing.xl),
              Text(
                'Today',
                style: SelahTypography.scriptureDisplay,
              ),
              SizedBox(height: SelahSpacing.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SelahSpacing.screenPadding),
                child: Text(
                  'Your daily Scripture and stats will appear here.',
                  style: SelahTypography.bodyLight,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
