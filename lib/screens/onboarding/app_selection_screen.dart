import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../database/database_helper.dart';
import '../../models/guarded_app.dart';
import 'schedule_screen.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final _db = DatabaseHelper();
  List<AppInfo> _installedApps = [];
  final Set<String> _selectedApps = {};
  bool _isLoading = true;
  bool _isPremium = false;

  // Common social/distraction apps to surface at top
  static const _commonApps = [
    'com.instagram.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.google.android.youtube',
    'com.twitter.android',
    'com.reddit.frontpage',
    'com.facebook.katana',
    'com.snapchat.android',
    'com.pinterest',
  ];

  @override
  void initState() {
    super.initState();
    _loadApps();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final settings = await _db.getUserSettings();
    setState(() {
      _isPremium = settings.isPremium;
    });
  }

  Future<void> _loadApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps();

      // Sort: common apps first, then alphabetically
      apps.sort((a, b) {
        final aIsCommon = _commonApps.contains(a.packageName);
        final bIsCommon = _commonApps.contains(b.packageName);

        if (aIsCommon && !bIsCommon) return -1;
        if (!aIsCommon && bIsCommon) return 1;

        final aName = a.name;
        final bName = b.name;
        return (aName).compareTo(bName);
      });

      setState(() {
        _installedApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading apps: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleApp(String packageName) {
    setState(() {
      if (_selectedApps.contains(packageName)) {
        _selectedApps.remove(packageName);
      } else {
        // Free tier limit: 3 apps
        if (!_isPremium && _selectedApps.length >= 3) {
          _showPremiumPrompt();
          return;
        }
        _selectedApps.add(packageName);
      }
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
          'Guard more apps with Selah Plus',
          style: SelahTypography.heading3.copyWith(
            color: SelahColors.sacredGold,
          ),
        ),
        content: Text(
          'The free version guards up to 3 apps. Upgrade to Selah Plus for unlimited app guarding.',
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to premium screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SelahColors.sacredGold,
              foregroundColor: SelahColors.deepNavy,
            ),
            child: Text(
              'Learn more',
              style: SelahTypography.buttonPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    // Save selected apps to database
    for (final app in _installedApps) {
      final pkgName = app.packageName;
      if (_selectedApps.contains(pkgName)) {
        await _db.upsertGuardedApp(GuardedApp(
          packageName: pkgName,
          appName: app.name,
          isActive: true,
          addedAt: DateTime.now(),
        ));
      }
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScheduleScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SelahColors.deepNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(SelahSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Which apps steal your peace?',
                    style: SelahTypography.scriptureDisplay.copyWith(fontSize: 24),
                  ),
                  SizedBox(height: SelahSpacing.md),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SelahSpacing.md,
                          vertical: SelahSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: SelahColors.sacredGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Guarding ${_selectedApps.length} app${_selectedApps.length == 1 ? '' : 's'}',
                          style: SelahTypography.caption.copyWith(
                            color: SelahColors.sacredGold,
                          ),
                        ),
                      ),
                      if (!_isPremium) ...[
                        SizedBox(width: SelahSpacing.sm),
                        Text(
                          '(3 max free)',
                          style: SelahTypography.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // App grid
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: SelahColors.sacredGold,
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: SelahSpacing.screenPadding,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _installedApps.length,
                      itemBuilder: (context, index) {
                        final app = _installedApps[index];
                        final isSelected = _selectedApps.contains(app.packageName);
                        final isCommon = _commonApps.contains(app.packageName);

                        return _buildAppTile(app, isSelected, isCommon);
                      },
                    ),
            ),
            // Note and button
            Padding(
              padding: EdgeInsets.all(SelahSpacing.screenPadding),
              child: Column(
                children: [
                  Text(
                    'You can always change this. Selah never locks you out — it only asks you to pause.',
                    style: SelahTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SelahSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedApps.isNotEmpty ? _saveAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedApps.isNotEmpty
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTile(AppInfo app, bool isSelected, bool isCommon) {
    return GestureDetector(
      onTap: () => _toggleApp(app.packageName),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: SelahColors.sacredGold, width: 2)
                      : null,
                  color: isSelected
                      ? SelahColors.sacredGold.withValues(alpha: 0.1)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: app.icon != null
                      ? Image.memory(
                          app.icon!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.android,
                            color: SelahColors.subduedGray,
                          ),
                        )
                      : Icon(
                          Icons.android,
                          size: 48,
                          color: SelahColors.subduedGray,
                        ),
                ),
              ),
              if (isSelected)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: SelahColors.sacredGold,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: SelahColors.deepNavy,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: SelahSpacing.xs),
          Text(
            app.name,
            style: SelahTypography.caption.copyWith(
              fontSize: 11,
              color: isSelected ? SelahColors.warmCream : SelahColors.subduedGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
