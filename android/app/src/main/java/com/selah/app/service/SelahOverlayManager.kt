package com.selah.app.service

import android.content.Context
import android.graphics.PixelFormat
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import com.selah.app.ui.overlay.InterventionOverlayView

/**
 * Manages the intervention overlay window.
 *
 * Uses WindowManager to add/remove overlay views with TYPE_APPLICATION_OVERLAY.
 * The overlay starts non-focusable (so countdown runs without user input),
 * then becomes focusable when buttons appear.
 */
class SelahOverlayManager(private val context: Context) {

    companion object {
        private const val TAG = "SelahOverlayManager"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: InterventionOverlayView? = null
    private var isOverlayShowing = false

    /**
     * Shows the intervention overlay.
     *
     * @param packageName The package name of the guarded app
     * @param appName The display name of the guarded app
     * @param escalation The escalation data determining content and pause duration
     * @param onReturnToPrayer Callback when user taps "Return to prayer"
     * @param onProceed Callback when user taps "Proceed"
     */
    fun showOverlay(
        packageName: String,
        appName: String,
        escalation: EscalationData,
        onReturnToPrayer: () -> Unit,
        onProceed: () -> Unit
    ) {
        if (isOverlayShowing) {
            Log.d(TAG, "Overlay already showing, ignoring request")
            return
        }

        try {
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

            // Create the overlay view
            overlayView = InterventionOverlayView(
                context = context,
                appName = appName,
                escalation = escalation,
                onReturnToPrayer = onReturnToPrayer,
                onProceed = onProceed
            )

            // Set up layout params for full-screen overlay
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                // Start with FLAG_NOT_FOCUSABLE so countdown runs
                // We'll update flags when buttons appear
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = 0
                y = 0
            }

            // Add view to window
            windowManager?.addView(overlayView, params)
            isOverlayShowing = true

            Log.d(TAG, "Overlay shown for $appName ($packageName)")

            // Start animations
            overlayView?.post {
                overlayView?.startAnimations()

                // After all animations complete, make focusable for button interaction
                // The view will notify us when buttons are ready
                overlayView?.setOnButtonsReadyListener {
                    makeFocusable()
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error showing overlay", e)
            isOverlayShowing = false
        }
    }

    /**
     * Updates window flags to allow touch interaction with buttons.
     */
    private fun makeFocusable() {
        try {
            overlayView?.let { view ->
                val params = view.layoutParams as? WindowManager.LayoutParams
                params?.let {
                    // Remove FLAG_NOT_FOCUSABLE to allow touch
                    it.flags = it.flags and WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE.inv()
                    windowManager?.updateViewLayout(view, it)
                    Log.d(TAG, "Overlay now focusable")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error making overlay focusable", e)
        }
    }

    /**
     * Hides and removes the overlay.
     */
    fun hideOverlay() {
        if (!isOverlayShowing) {
            return
        }

        try {
            overlayView?.cleanup()
            windowManager?.removeView(overlayView)
            Log.d(TAG, "Overlay hidden")
        } catch (e: Exception) {
            Log.e(TAG, "Error hiding overlay", e)
        } finally {
            overlayView = null
            isOverlayShowing = false
        }
    }

    /**
     * Returns whether the overlay is currently displayed.
     */
    fun isShowing(): Boolean = isOverlayShowing
}
