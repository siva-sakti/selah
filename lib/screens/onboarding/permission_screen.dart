import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../services/accessibility_handler.dart';
import 'ready_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  final _accessibilityHandler = AccessibilityHandler();
  bool _permissionGranted = false;
  bool _checkingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check permission when returning from settings
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() {
      _checkingPermission = true;
    });

    final isEnabled = await _accessibilityHandler.isAccessibilityEnabled();

    setState(() {
      _permissionGranted = isEnabled;
      _checkingPermission = false;
    });
  }

  Future<void> _requestPermission() async {
    await _accessibilityHandler.requestAccessibilityPermission();
    // Permission check will happen when user returns (didChangeAppLifecycleState)
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReadyScreen()),
    );
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
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _permissionGranted
                      ? SelahColors.sacredGold.withValues(alpha: 0.2)
                      : SelahColors.subduedGray.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _permissionGranted ? Icons.check : Icons.accessibility_new,
                  size: 40,
                  color: _permissionGranted
                      ? SelahColors.sacredGold
                      : SelahColors.warmCream,
                ),
              ),
              SizedBox(height: SelahSpacing.xxl),
              // Title
              Text(
                _permissionGranted
                    ? 'Permission Granted'
                    : 'One More Step',
                style: SelahTypography.scriptureDisplay.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SelahSpacing.xl),
              // Explanation
              Text(
                _permissionGranted
                    ? 'Selah can now guard your heart when you reach for distracting apps.'
                    : 'To guard your heart, Selah needs accessibility permission. This lets Selah notice when you open a guarded app and show you a moment of prayer instead.',
                style: SelahTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              if (!_permissionGranted) ...[
                SizedBox(height: SelahSpacing.xxl),
                // Privacy note
                Container(
                  padding: EdgeInsets.all(SelahSpacing.lg),
                  decoration: BoxDecoration(
                    color: SelahColors.warmCream.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SelahColors.subduedGray.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: SelahColors.subduedGray,
                        size: 20,
                      ),
                      SizedBox(width: SelahSpacing.md),
                      Expanded(
                        child: Text(
                          'Selah never reads your screen content, never collects your data, and never sends anything off your device. Your prayer life stays between you and God.',
                          style: SelahTypography.caption.copyWith(
                            color: SelahColors.warmCream.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 2),
              // Buttons
              if (_checkingPermission)
                CircularProgressIndicator(
                  color: SelahColors.sacredGold,
                )
              else if (_permissionGranted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continue,
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
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _requestPermission,
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
                          'Grant permission',
                          style: SelahTypography.buttonPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: SelahSpacing.md),
                    TextButton(
                      onPressed: _continue,
                      child: Text(
                        'Skip for now',
                        style: SelahTypography.buttonSecondary,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: SelahSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
