import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'overlay_data_reader.dart';

/// Colors for the overlay (duplicated since overlay runs in separate engine)
class OverlayColors {
  static const Color deepNavy = Color(0xFF1B2340);
  static const Color sacredGold = Color(0xFFC9A84C);
  static const Color warmCream = Color(0xFFF5F0E6);
  static const Color subduedGray = Color(0xFF666666);
}

/// The intervention overlay that runs in a separate Flutter engine.
///
/// IMPORTANT: This widget runs in its own isolate and cannot share state
/// with the main app. Data is passed via SharedPreferences.
class InterventionOverlayStandalone extends StatefulWidget {
  const InterventionOverlayStandalone({super.key});

  @override
  State<InterventionOverlayStandalone> createState() =>
      _InterventionOverlayStandaloneState();
}

class _InterventionOverlayStandaloneState
    extends State<InterventionOverlayStandalone> with TickerProviderStateMixin {
  late AnimationController _scriptureController;
  late AnimationController _buttonsController;
  late Animation<double> _scriptureFade;
  late Animation<double> _buttonsFade;

  Timer? _pauseTimer;
  int _remainingSeconds = 5;
  bool _buttonsVisible = false;
  bool _dataLoaded = false;

  // Dynamic data from SharedPreferences
  OverlayDisplayData? _overlayData;

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

    // Load data from SharedPreferences
    _loadOverlayData();
  }

  Future<void> _loadOverlayData() async {
    try {
      final data = await OverlayDataReader.readData();
      setState(() {
        _overlayData = data;
        _remainingSeconds = data.pauseDuration;
        _dataLoaded = true;
      });

      // Start animations after data is loaded
      _scriptureController.forward();
      _startPauseTimer();
    } catch (e) {
      debugPrint('Overlay: Error loading data: $e');
      // Use fallback values
      setState(() {
        _overlayData = OverlayDisplayData(
          appPackage: '',
          appName: 'App',
          scriptureRef: 'Psalm 51:10',
          scriptureText:
              'Create in me a clean heart, O God, and renew a right spirit within me.',
          breathPrayer: 'Be still.',
          reflection: 'What draws you here?',
          companionName: '',
          companionQuote: '',
          attemptCount: 1,
          pauseDuration: 5,
          tradition: 'exploring',
          subPrompt: null,
          lentenDay: 1,
        );
        _remainingSeconds = 5;
        _dataLoaded = true;
      });
      _scriptureController.forward();
      _startPauseTimer();
    }
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

  /// Handle "Return to prayer" - dismiss overlay and go home
  Future<void> _onReturnToPrayer() async {
    // Write intervention result before dismissing
    await OverlayDataReader.writeResult(
      outcome: 'resisted',
      offeringText: null, // TODO: Add offering text input in future
      timeSavedEst: 300, // Estimate 5 minutes saved
    );

    // Hide the overlay first
    await FlutterAccessibilityService.hideOverlayWindow();
    // Then go to home screen
    await FlutterAccessibilityService.performGlobalAction(
      GlobalAction.globalActionHome,
    );
  }

  /// Handle "Proceed" - just dismiss overlay, let target app continue
  Future<void> _onProceed() async {
    // Write intervention result before dismissing
    await OverlayDataReader.writeResult(
      outcome: 'proceeded',
      reason: null, // TODO: Add examination reason selection in future
      timeSavedEst: 0, // No time saved if proceeded
    );

    await FlutterAccessibilityService.hideOverlayWindow();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: OverlayColors.deepNavy,
        body: SafeArea(
          child: _dataLoaded ? _buildContent() : _buildLoading(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: OverlayColors.sacredGold,
      ),
    );
  }

  Widget _buildContent() {
    final data = _overlayData!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Top section with cross
          const SizedBox(height: 48),
          _buildCross(),

          // Middle section with Scripture (animation disabled for debugging)
          Expanded(
            child: Center(
              child: _buildScriptureSection(data),
            ),
          ),

          // Sub-prompt for escalated attempts
          if (data.subPrompt != null) ...[
            _buildSubPrompt(data.subPrompt!),
            const SizedBox(height: 24),
          ],

          // Bottom section with buttons
          _buildButtonSection(data),

          // Attempt info at bottom
          const SizedBox(height: 16),
          _buildAttemptInfo(data),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCross() {
    return const Text(
      '\u2726', // ✦ character
      style: TextStyle(
        fontSize: 56,
        color: OverlayColors.sacredGold,
      ),
    );
  }

  Widget _buildScriptureSection(OverlayDisplayData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scripture text
        Text(
          '"${data.scriptureText}"',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: OverlayColors.sacredGold,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Scripture reference
        Text(
          '— ${data.scriptureRef}',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: OverlayColors.sacredGold.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSubPrompt(String subPrompt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: OverlayColors.sacredGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        subPrompt,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: OverlayColors.warmCream.withValues(alpha: 0.9),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildButtonSection(OverlayDisplayData data) {
    // Show countdown while waiting
    if (!_buttonsVisible) {
      return Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1 - (_remainingSeconds / data.pauseDuration),
                  strokeWidth: 2,
                  backgroundColor: OverlayColors.sacredGold.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    OverlayColors.sacredGold,
                  ),
                ),
                Text(
                  '$_remainingSeconds',
                  style: const TextStyle(
                    color: OverlayColors.sacredGold,
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

    // Show buttons after countdown
    return Column(
      children: [
        // Return to prayer button (primary, gold)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onReturnToPrayer,
            style: ElevatedButton.styleFrom(
              backgroundColor: OverlayColors.sacredGold,
              foregroundColor: OverlayColors.deepNavy,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Return to prayer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Proceed button (secondary, gray) - generic text, but we still track which app
        TextButton(
          onPressed: _onProceed,
          child: Text(
            'Continue anyway',
            style: TextStyle(
              fontSize: 16,
              color: OverlayColors.subduedGray.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptInfo(OverlayDisplayData data) {
    final attemptText = data.attemptCount == 1
        ? 'Attempt 1 today'
        : 'Attempt ${data.attemptCount} today';

    return Text(
      '$attemptText \u00B7 ${data.pauseDuration} sec',
      style: TextStyle(
        fontSize: 12,
        color: OverlayColors.subduedGray.withValues(alpha: 0.6),
      ),
    );
  }
}
