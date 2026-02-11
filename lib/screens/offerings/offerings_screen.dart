import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';

class OfferingsScreen extends StatelessWidget {
  const OfferingsScreen({super.key});

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
                'Offerings',
                style: SelahTypography.scriptureDisplay,
              ),
              SizedBox(height: SelahSpacing.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SelahSpacing.screenPadding),
                child: Text(
                  'Your dedicated sacrifices and prayers will appear here.',
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
