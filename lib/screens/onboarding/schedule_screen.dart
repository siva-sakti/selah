import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../database/database_helper.dart';
import 'how_it_works_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedSchedule = 'always';
  final _db = DatabaseHelper();
  bool _isPremium = false;

  final List<_ScheduleOption> _schedules = [
    _ScheduleOption(
      id: 'always',
      title: 'Always',
      description: 'Every time you open a guarded app',
      icon: Icons.all_inclusive,
      isPremiumOnly: false,
    ),
    _ScheduleOption(
      id: 'evening',
      title: 'Evening Peace',
      description: '6 PM to 7 AM',
      icon: Icons.nights_stay,
      isPremiumOnly: false,
    ),
    _ScheduleOption(
      id: 'sabbath',
      title: 'Sabbath Rest',
      description: 'Sundays, all day',
      icon: Icons.wb_sunny,
      isPremiumOnly: false,
    ),
    _ScheduleOption(
      id: 'custom',
      title: 'Custom',
      description: 'Pick your own days and hours',
      icon: Icons.tune,
      isPremiumOnly: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final settings = await _db.getUserSettings();
    setState(() {
      _isPremium = settings.isPremium;
    });
  }

  void _selectSchedule(String scheduleId, bool isPremiumOnly) {
    if (isPremiumOnly && !_isPremium) {
      _showPremiumPrompt();
      return;
    }

    setState(() {
      _selectedSchedule = scheduleId;
    });
  }

  void _showPremiumPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SelahColors.deepNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: SelahColors.sacredGold.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Custom scheduling with Selah Plus',
          style: SelahTypography.heading3.copyWith(
            color: SelahColors.sacredGold,
          ),
        ),
        content: Text(
          'Custom schedules are available with Selah Plus. Upgrade to set your own days and hours.',
          style: SelahTypography.bodyLight,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe later',
              style: SelahTypography.buttonSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    final settings = await _db.getUserSettings();
    await _db.updateUserSettings(
      settings.copyWith(scheduleMode: _selectedSchedule),
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
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
              Text(
                'When should Selah guard your heart?',
                style: SelahTypography.scriptureDisplay.copyWith(fontSize: 24),
              ),
              SizedBox(height: SelahSpacing.xxl),
              // Schedule options
              Expanded(
                child: ListView.separated(
                  itemCount: _schedules.length,
                  separatorBuilder: (context, index) => SizedBox(height: SelahSpacing.md),
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    final isSelected = _selectedSchedule == schedule.id;
                    final isLocked = schedule.isPremiumOnly && !_isPremium;

                    return _buildScheduleCard(schedule, isSelected, isLocked);
                  },
                ),
              ),
              SizedBox(height: SelahSpacing.lg),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
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

  Widget _buildScheduleCard(_ScheduleOption schedule, bool isSelected, bool isLocked) {
    return GestureDetector(
      onTap: () => _selectSchedule(schedule.id, schedule.isPremiumOnly),
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
                schedule.icon,
                color: isLocked
                    ? SelahColors.subduedGray.withValues(alpha: 0.5)
                    : isSelected
                        ? SelahColors.sacredGold
                        : SelahColors.subduedGray,
              ),
            ),
            SizedBox(width: SelahSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        schedule.title,
                        style: SelahTypography.heading3.copyWith(
                          color: isLocked
                              ? SelahColors.subduedGray.withValues(alpha: 0.5)
                              : isSelected
                                  ? SelahColors.sacredGold
                                  : SelahColors.warmCream,
                        ),
                      ),
                      if (isLocked) ...[
                        SizedBox(width: SelahSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SelahSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: SelahColors.sacredGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PLUS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: SelahColors.sacredGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: SelahSpacing.xs),
                  Text(
                    schedule.description,
                    style: SelahTypography.caption.copyWith(
                      color: isLocked
                          ? SelahColors.subduedGray.withValues(alpha: 0.5)
                          : isSelected
                              ? SelahColors.warmCream.withValues(alpha: 0.9)
                              : SelahColors.subduedGray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected && !isLocked)
              Icon(
                Icons.check_circle,
                color: SelahColors.sacredGold,
              ),
            if (isLocked)
              Icon(
                Icons.lock,
                color: SelahColors.subduedGray.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isPremiumOnly;

  const _ScheduleOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isPremiumOnly,
  });
}
