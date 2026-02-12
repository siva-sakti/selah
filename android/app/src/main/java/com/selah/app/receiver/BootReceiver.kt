package com.selah.app.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receives BOOT_COMPLETED and MY_PACKAGE_REPLACED broadcasts.
 *
 * The AccessibilityService auto-restarts via Android's accessibility framework,
 * but this receiver ensures our app state is ready and allows for any
 * initialization that needs to happen on boot/update.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "SelahBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                Log.d(TAG, "Device boot completed - Selah app state ready")
                // AccessibilityService will auto-restart if enabled
                // Any additional boot-time initialization can go here
            }
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d(TAG, "Selah app updated - ensuring state is ready")
                // Handle any migration or state refresh after app update
            }
        }
    }
}
