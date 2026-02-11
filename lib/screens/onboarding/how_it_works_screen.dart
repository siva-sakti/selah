import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import 'permission_screen.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SelahColors.deepNavy,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SelahSpacing.screenPadding),
          child: Column(
            children: [
              SizedBox(height: SelahSpacing.xl),
              // Title
              Text(
                'How Selah Works',
                style: SelahTypography.scriptureDisplay.copyWith(fontSize: 26),
              ),
              SizedBox(height: SelahSpacing.xxxl),
              // Explanation
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStep(
                        number: '1',
                        title: 'You reach for a guarded app',
                        description: 'Instagram, TikTok, whatever steals your peace.',
                        icon: Icons.touch_app,
                      ),
                      SizedBox(height: SelahSpacing.xl),
                      _buildStep(
                        number: '2',
                        title: 'Selah shows you Scripture',
                        description: 'A moment of prayer replaces the impulse.',
                        icon: Icons.menu_book,
                      ),
                      SizedBox(height: SelahSpacing.xl),
                      _buildStep(
                        number: '3',
                        title: 'The pause deepens',
                        description: 'Each time you return, Selah asks you to sit a little longer — 5 seconds, then 10, then 20. Like the Desert Fathers who sat in patience, the practice deepens with repetition.',
                        icon: Icons.hourglass_bottom,
                      ),
                      SizedBox(height: SelahSpacing.xl),
                      _buildStep(
                        number: '4',
                        title: 'You choose',
                        description: 'Return to prayer and offer this moment to God, or proceed to the app. Either way, you pause. Either way, you pray.',
                        icon: Icons.call_split,
                      ),
                      SizedBox(height: SelahSpacing.xxxl),
                      // Spiritual insight
                      Container(
                        padding: EdgeInsets.all(SelahSpacing.lg),
                        decoration: BoxDecoration(
                          color: SelahColors.sacredGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: SelahColors.sacredGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '"The more you return, the more the Word has time to work."',
                              style: SelahTypography.reflection,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SelahSpacing.lg),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PermissionScreen()),
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
                    'Continue',
                    style: SelahTypography.buttonPrimary,
                  ),
                ),
              ),
              SizedBox(height: SelahSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: SelahColors.sacredGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SelahColors.sacredGold,
              ),
            ),
          ),
        ),
        SizedBox(width: SelahSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: SelahTypography.heading3.copyWith(
                  color: SelahColors.sacredGold,
                ),
              ),
              SizedBox(height: SelahSpacing.xs),
              Text(
                description,
                style: SelahTypography.bodyLight.copyWith(
                  color: SelahColors.warmCream.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
