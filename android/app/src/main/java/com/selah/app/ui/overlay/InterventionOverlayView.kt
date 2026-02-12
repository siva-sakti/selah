package com.selah.app.ui.overlay

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.os.CountDownTimer
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.selah.app.R
import com.selah.app.service.ContentLevel
import com.selah.app.service.EscalationData

/**
 * Custom view for the intervention overlay.
 *
 * Handles:
 * - Progressive reveal animations based on content level
 * - Variable content (breath prayer vs scripture vs companion)
 * - Countdown timer before showing buttons
 * - Button callbacks for "Return to prayer" and "Proceed"
 * - Back button interception (does not dismiss)
 */
class InterventionOverlayView(
    context: Context,
    private val appName: String,
    private val escalation: EscalationData,
    private val onReturnToPrayer: () -> Unit,
    private val onProceed: () -> Unit
) : FrameLayout(context) {

    private val crossSymbol: TextView
    private val breathPrayer: TextView
    private val scriptureContainer: LinearLayout
    private val scriptureText: TextView
    private val scriptureReference: TextView
    private val subPrompt: TextView
    private val companionContainer: LinearLayout
    private val companionQuote: TextView
    private val companionName: TextView
    private val btnReturnToPrayer: Button
    private val btnProceed: TextView
    private val attemptCounter: TextView

    private var countDownTimer: CountDownTimer? = null
    private var onButtonsReadyListener: (() -> Unit)? = null

    init {
        LayoutInflater.from(context).inflate(R.layout.overlay_intervention, this, true)

        crossSymbol = findViewById(R.id.cross_symbol)
        breathPrayer = findViewById(R.id.breath_prayer)
        scriptureContainer = findViewById(R.id.scripture_container)
        scriptureText = findViewById(R.id.scripture_text)
        scriptureReference = findViewById(R.id.scripture_reference)
        subPrompt = findViewById(R.id.sub_prompt)
        companionContainer = findViewById(R.id.companion_container)
        companionQuote = findViewById(R.id.companion_quote)
        companionName = findViewById(R.id.companion_name)
        btnReturnToPrayer = findViewById(R.id.btn_return_to_prayer)
        btnProceed = findViewById(R.id.btn_proceed)
        attemptCounter = findViewById(R.id.attempt_counter)

        // Set up content based on escalation level
        setupContent()

        // Set up button click listeners
        btnReturnToPrayer.setOnClickListener {
            cleanup()
            onReturnToPrayer()
        }

        btnProceed.setOnClickListener {
            cleanup()
            onProceed()
        }

        // Make focusable to intercept back button
        isFocusable = true
        isFocusableInTouchMode = true
    }

    private fun setupContent() {
        // Dynamic button text
        btnProceed.text = "Proceed to $appName"

        // Attempt counter with sit time
        attemptCounter.text = "Attempt ${escalation.attemptNumber} today · Sitting for ${escalation.pauseDurationSeconds}s"

        // Scripture content (if applicable)
        scriptureText.text = escalation.scriptureText
        scriptureReference.text = "— ${escalation.scriptureRef}"

        // Sub-prompt (if applicable)
        escalation.subPromptText?.let {
            subPrompt.text = it
        }

        // Companion quote (if applicable)
        escalation.companionQuote?.let {
            companionQuote.text = it
        }
        escalation.companionName?.let {
            companionName.text = "— $it"
        }
    }

    fun setOnButtonsReadyListener(listener: () -> Unit) {
        onButtonsReadyListener = listener
    }

    /**
     * Start the animation sequence based on content level.
     * Call this after the view is attached to the window.
     */
    fun startAnimations() {
        when (escalation.contentLevel) {
            ContentLevel.BREATH_PRAYER -> animateBreathPrayer()
            ContentLevel.SCRIPTURE -> animateScripture()
            ContentLevel.SCRIPTURE_DEEPER -> animateScriptureDeeper()
            ContentLevel.SCRIPTURE_COMPANION -> animateScriptureCompanion()
        }
    }

    /**
     * Attempt 1: Cross → "Be still." → Return button immediately → Proceed after timer
     */
    private fun animateBreathPrayer() {
        // Show breath prayer element
        breathPrayer.visibility = View.VISIBLE

        // Phase 1: Fade in cross (400ms)
        crossSymbol.animate()
            .alpha(1f)
            .setDuration(400)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    // Phase 2: Fade in breath prayer (500ms)
                    breathPrayer.animate()
                        .alpha(1f)
                        .setDuration(500)
                        .setListener(object : AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: Animator) {
                                // Show Return button immediately
                                showReturnButton()
                                // Start countdown for Proceed button
                                startCountdown(escalation.pauseDurationSeconds * 1000L - 900)
                            }
                        })
                        .start()
                }
            })
            .start()
    }

    /**
     * Attempt 2: Cross → scripture → Return button → sub-prompt → Proceed after timer
     */
    private fun animateScripture() {
        scriptureContainer.visibility = View.VISIBLE
        subPrompt.visibility = View.VISIBLE

        // Phase 1: Cross (400ms)
        crossSymbol.animate()
            .alpha(1f)
            .setDuration(400)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    // Phase 2: Scripture (600ms)
                    scriptureContainer.animate()
                        .alpha(1f)
                        .setDuration(600)
                        .setListener(object : AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: Animator) {
                                // Show Return button as soon as scripture appears
                                showReturnButton()
                                // Phase 3: Sub-prompt after 1s delay
                                postDelayed({
                                    subPrompt.animate()
                                        .alpha(1f)
                                        .setDuration(500)
                                        .setListener(object : AnimatorListenerAdapter() {
                                            override fun onAnimationEnd(animation: Animator) {
                                                // Remaining time until Proceed button
                                                val elapsed = 400 + 600 + 1000 + 500 // 2.5s
                                                val remaining = (escalation.pauseDurationSeconds * 1000L) - elapsed
                                                startCountdown(remaining.coerceAtLeast(500))
                                            }
                                        })
                                        .start()
                                }, 1000)
                            }
                        })
                        .start()
                }
            })
            .start()
    }

    /**
     * Attempt 3: Cross → scripture → Return button → deeper sub-prompt → Proceed after timer
     */
    private fun animateScriptureDeeper() {
        scriptureContainer.visibility = View.VISIBLE
        subPrompt.visibility = View.VISIBLE

        // Phase 1: Cross (400ms)
        crossSymbol.animate()
            .alpha(1f)
            .setDuration(400)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    // Phase 2: Scripture (800ms)
                    scriptureContainer.animate()
                        .alpha(1f)
                        .setDuration(800)
                        .setListener(object : AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: Animator) {
                                // Show Return button as soon as scripture appears
                                showReturnButton()
                                // Phase 3: Sub-prompt after 2s delay (more contemplative)
                                postDelayed({
                                    subPrompt.animate()
                                        .alpha(1f)
                                        .setDuration(600)
                                        .setListener(object : AnimatorListenerAdapter() {
                                            override fun onAnimationEnd(animation: Animator) {
                                                // Remaining time until Proceed button
                                                val elapsed = 400 + 800 + 2000 + 600 // 3.8s
                                                val remaining = (escalation.pauseDurationSeconds * 1000L) - elapsed
                                                startCountdown(remaining.coerceAtLeast(500))
                                            }
                                        })
                                        .start()
                                }, 2000)
                            }
                        })
                        .start()
                }
            })
            .start()
    }

    /**
     * Attempt 4+: Cross → scripture → sub-prompt → companion → buttons (15s)
     */
    private fun animateScriptureCompanion() {
        scriptureContainer.visibility = View.VISIBLE
        subPrompt.visibility = View.VISIBLE
        companionContainer.visibility = View.VISIBLE

        // Phase 1: Cross (400ms)
        crossSymbol.animate()
            .alpha(1f)
            .setDuration(400)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    // Phase 2: Scripture (800ms)
                    scriptureContainer.animate()
                        .alpha(1f)
                        .setDuration(800)
                        .setListener(object : AnimatorListenerAdapter() {
                            override fun onAnimationEnd(animation: Animator) {
                                // Show Return button as soon as scripture appears
                                showReturnButton()
                                // Phase 3: Sub-prompt after 2s delay
                                postDelayed({
                                    subPrompt.animate()
                                        .alpha(1f)
                                        .setDuration(600)
                                        .setListener(object : AnimatorListenerAdapter() {
                                            override fun onAnimationEnd(animation: Animator) {
                                                // Phase 4: Companion after another 3s delay
                                                postDelayed({
                                                    companionContainer.animate()
                                                        .alpha(1f)
                                                        .setDuration(700)
                                                        .setListener(object : AnimatorListenerAdapter() {
                                                            override fun onAnimationEnd(animation: Animator) {
                                                                // Remaining time until buttons
                                                                val elapsed = 400 + 800 + 2000 + 600 + 3000 + 700 // 7.5s
                                                                val remaining = (escalation.pauseDurationSeconds * 1000L) - elapsed
                                                                startCountdown(remaining.coerceAtLeast(500))
                                                            }
                                                        })
                                                        .start()
                                                }, 3000)
                                            }
                                        })
                                        .start()
                                }, 2000)
                            }
                        })
                        .start()
                }
            })
            .start()
    }

    /**
     * Show the "Return to prayer" button immediately.
     * Called early in animation so user can always choose to leave.
     */
    private fun showReturnButton() {
        btnReturnToPrayer.visibility = View.VISIBLE
        btnReturnToPrayer.alpha = 0f
        btnReturnToPrayer.animate()
            .alpha(1f)
            .setDuration(300)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    // Notify that at least one button is ready for touch
                    onButtonsReadyListener?.invoke()
                }
            })
            .start()
    }

    private fun startCountdown(durationMs: Long) {
        if (durationMs <= 0) {
            showProceedButton()
            return
        }

        countDownTimer = object : CountDownTimer(durationMs, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                // Could update UI with countdown if desired
            }

            override fun onFinish() {
                showProceedButton()
            }
        }.start()
    }

    /**
     * Show the "Proceed" button after countdown completes.
     */
    private fun showProceedButton() {
        btnProceed.visibility = View.VISIBLE
        btnProceed.alpha = 0f
        btnProceed.animate()
            .alpha(1f)
            .setDuration(300)
            .start()
    }

    /**
     * Intercept back button to prevent dismissing the overlay.
     */
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.keyCode == KeyEvent.KEYCODE_BACK) {
            // Consume the back button event - don't dismiss
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    /**
     * Clean up resources when overlay is dismissed.
     */
    fun cleanup() {
        countDownTimer?.cancel()
        countDownTimer = null
    }
}
