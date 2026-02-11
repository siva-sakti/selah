import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../database/database_helper.dart';
import 'app_selection_screen.dart';

class TraditionScreen extends StatefulWidget {
  const TraditionScreen({super.key});

  @override
  State<TraditionScreen> createState() => _TraditionScreenState();
}

class _TraditionScreenState extends State<TraditionScreen> {
  String? _selectedTradition;
  final _db = DatabaseHelper();

  final List<_TraditionOption> _traditions = [
    _TraditionOption(
      id: 'catholic',
      title: 'Catholic',
      description: 'Saints, Marian prayers, examination of conscience, liturgical calendar with feast days',
      icon: Icons.church,
    ),
    _TraditionOption(
      id: 'protestant',
      title: 'Protestant',
      description: 'Scripture-focused, biblical companions, heart-check language',
      icon: Icons.menu_book,
    ),
    _TraditionOption(
      id: 'orthodox',
      title: 'Orthodox',
      description: 'Desert Fathers, the Jesus Prayer, icons, Great Lent calendar',
      icon: Icons.auto_awesome,
    ),
    _TraditionOption(
      id: 'exploring',
      title: 'Exploring / Other',
      description: 'Universal, gentle, Scripture-only, no tradition-specific content',
      icon: Icons.explore,
    ),
  ];

  Future<void> _saveAndContinue() async {
    if (_selectedTradition == null) return;

    final settings = await _db.getUserSettings();
    await _db.updateUserSettings(
      settings.copyWith(tradition: _selectedTradition),
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AppSelectionScreen()),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SelahSpacing.xl),
              // Title
              Text(
                'How would you like Selah to speak to you?',
                style: SelahTypography.scriptureDisplay.copyWith(fontSize: 24),
              ),
              SizedBox(height: SelahSpacing.xl),
              // Tradition cards
              Expanded(
                child: ListView.separated(
                  itemCount: _traditions.length,
                  separatorBuilder: (context, index) => SizedBox(height: SelahSpacing.md),
                  itemBuilder: (context, index) {
                    final tradition = _traditions[index];
                    final isSelected = _selectedTradition == tradition.id;

                    return _buildTraditionCard(tradition, isSelected);
                  },
                ),
              ),
              SizedBox(height: SelahSpacing.lg),
              // Note
              Text(
                'You can change this anytime in Settings.',
                style: SelahTypography.caption,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SelahSpacing.lg),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedTradition != null ? _saveAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTradition != null
                        ? SelahColors.sacredGold
                        : SelahColors.subduedGray,
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

  Widget _buildTraditionCard(_TraditionOption tradition, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTradition = tradition.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(SelahSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? SelahColors.sacredGold.withValues(alpha: 0.15)
              : SelahColors.deepNavy,
          border: Border.all(
            color: isSelected
                ? SelahColors.sacredGold
                : SelahColors.subduedGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? SelahColors.sacredGold.withValues(alpha: 0.2)
                    : SelahColors.subduedGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tradition.icon,
                color: isSelected
                    ? SelahColors.sacredGold
                    : SelahColors.subduedGray,
              ),
            ),
            SizedBox(width: SelahSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tradition.title,
                    style: SelahTypography.heading3.copyWith(
                      color: isSelected
                          ? SelahColors.sacredGold
                          : SelahColors.warmCream,
                    ),
                  ),
                  SizedBox(height: SelahSpacing.xs),
                  Text(
                    tradition.description,
                    style: SelahTypography.caption.copyWith(
                      color: isSelected
                          ? SelahColors.warmCream.withValues(alpha: 0.9)
                          : SelahColors.subduedGray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: SelahColors.sacredGold,
              ),
          ],
        ),
      ),
    );
  }
}

class _TraditionOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const _TraditionOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
