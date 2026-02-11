import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

/// The intervention overlay - the heart of Selah.
///
/// This full-screen overlay appears when a user opens a guarded app.
/// It displays Scripture, a cross, and presents two choices:
/// - "Return to prayer" (gold, prominent)
/// - "Proceed" (gray, subdued)
///
/// Buttons are hidden during the pause period, then fade in.
class InterventionOverlay extends StatefulWidget {
  /// The name of the app that was opened
  final String appName;

  /// The package name of the app
  final String packageName;

  /// The current attempt number (1st, 2nd, 3rd, etc.)
  final int attemptNumber;

  /// Callback when user chooses to return to prayer
  final VoidCallback? onReturnToPrayer;

  /// Callback when user chooses to proceed
  final VoidCallback? onProceed;

  const InterventionOverlay({
    super.key,
    this.appName = 'this app',
    this.packageName = '',
    this.attemptNumber = 1,
    this.onReturnToPrayer,
    this.onProceed,
  });

  @override
  State<InterventionOverlay> createState() => _InterventionOverlayState();
}

class _InterventionOverlayState extends State<InterventionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scriptureController;
  late AnimationController _buttonsController;
  late Animation<double> _scriptureFade;
  late Animation<double> _buttonsFade;

  Timer? _pauseTimer;
  int _remainingSeconds = 0;
  bool _buttonsVisible = false;

  /// Get pause duration based on attempt number
  int get _pauseDuration {
    switch (widget.attemptNumber) {
      case 1:
        return 5;
      case 2:
        return 10;
      case 3:
        return 20;
      default:
        return 30;
    }
  }

  /// Get sub-prompt based on attempt number
  String? get _subPrompt {
    switch (widget.attemptNumber) {
      case 1:
        return null; // No sub-prompt on first attempt
      case 2:
        return 'What are you looking for right now?';
      case 3:
        return "You've come back three times today. What is your heart telling you?";
      case 4:
        return 'He sees you here. He loves you here. Do you want to stay?';
      default:
        return "You've been here ${widget.attemptNumber} times. That's okay. But what would it feel like to stop?";
    }
  }

  @override
  void initState() {
    super.initState();

    // Scripture fade-in animation (1.5 seconds)
    _scriptureController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scriptureFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scriptureController, curve: Curves.easeIn),
    );

    // Buttons fade-in animation (0.5 seconds)
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );

    // Start Scripture animation
    _scriptureController.forward();

    // Start pause countdown
    _remainingSeconds = _pauseDuration;
    _startPauseTimer();
  }

  void _startPauseTimer() {
    _pauseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _showButtons();
      }
    });
  }

  void _showButtons() {
    setState(() {
      _buttonsVisible = true;
    });
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _scriptureController.dispose();
    _buttonsController.dispose();
    super.dispose();
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
              // Top section with cross
              SizedBox(height: SelahSpacing.huge),
              _buildCross(),

              // Middle section with Scripture
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _scriptureFade,
                    child: _buildScriptureSection(),
                  ),
                ),
              ),

              // Bottom section with buttons
              _buildButtonSection(),

              // Attempt info at bottom
              SizedBox(height: SelahSpacing.lg),
              _buildAttemptInfo(),
              SizedBox(height: SelahSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCross() {
    return Text(
      '✦',
      style: TextStyle(
        fontSize: 56,
        color: SelahColors.sacredGold,
      ),
    );
  }

  Widget _buildScriptureSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scripture text (hardcoded Psalm 51:10 for now)
        Text(
          '"Create in me a clean heart, O God,\nand renew a right spirit within me."',
          style: SelahTypography.scriptureDisplay,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: SelahSpacing.lg),
        Text(
          '— Psalm 51:10',
          style: SelahTypography.scriptureReference,
        ),

        // Sub-prompt (attempt 2+)
        if (_subPrompt != null) ...[
          SizedBox(height: SelahSpacing.xxxl),
          Text(
            _subPrompt!,
            style: SelahTypography.reflection,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildButtonSection() {
    if (!_buttonsVisible) {
      // Show countdown while waiting
      return Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1 - (_remainingSeconds / _pauseDuration),
                  strokeWidth: 2,
                  backgroundColor: SelahColors.sacredGold.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(SelahColors.sacredGold),
                ),
                Text(
                  '$_remainingSeconds',
                  style: TextStyle(
                    color: SelahColors.sacredGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return FadeTransition(
      opacity: _buttonsFade,
      child: Column(
        children: [
          // Return to prayer button (primary, gold)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onReturnToPrayer,
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
                'Return to prayer',
                style: SelahTypography.buttonPrimary,
              ),
            ),
          ),

          SizedBox(height: SelahSpacing.lg),

          // Proceed button (secondary, gray)
          TextButton(
            onPressed: widget.onProceed,
            child: Text(
              'Proceed to ${widget.appName}',
              style: SelahTypography.buttonSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptInfo() {
    return Text(
      'Attempt ${widget.attemptNumber} today · $_pauseDuration sec',
      style: SelahTypography.caption.copyWith(
        color: SelahColors.subduedGray.withValues(alpha: 0.6),
      ),
    );
  }
}

/// A preview widget for testing the intervention overlay
class InterventionOverlayPreview extends StatelessWidget {
  const InterventionOverlayPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return InterventionOverlay(
      appName: 'Instagram',
      packageName: 'com.instagram.android',
      attemptNumber: 2,
      onReturnToPrayer: () {
        debugPrint('User chose to return to prayer');
        Navigator.of(context).pop();
      },
      onProceed: () {
        debugPrint('User chose to proceed');
        Navigator.of(context).pop();
      },
    );
  }
}
