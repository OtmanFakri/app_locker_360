package com.example.app_locker360

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AppMonitorAccessibilityService : AccessibilityService() {

    // Cooldown: After entering PIN correctly, allow 1 minute without prompting again
    private var lastSuccessfulAuthTime: Long = 0
    private val COOLDOWN_MS = 60000L // 1 minute cooldown

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.packageName == null) return
        
        val packageName = event.packageName.toString()
        val className = event.className?.toString() ?: ""
        val eventTypeStr = AccessibilityEvent.eventTypeToString(event.eventType)

        // VERBOSE: Log EVERY event to see what's happening
        Log.d("DEBUG_LOCKER", "📋 Event: $eventTypeStr | Package: $packageName | Class: $className")

        // Special focus on MIUI launcher
        if (packageName == "com.miui.home") {
            Log.d("DEBUG_LOCKER", "🏠 LAUNCHER EVENT DETECTED!")
            Log.d("DEBUG_LOCKER", "   Type: $eventTypeStr")
            Log.d("DEBUG_LOCKER", "   Class: $className")
            Log.d("DEBUG_LOCKER", "   Text: ${event.text}")
        }

        // 1. Protection for MIUI Security Center (Native protection)
        if (packageName == "com.miui.securitycenter") {
            // Check if it's the App Details activity
            if (className.contains("ApplicationsDetailsActivity", ignoreCase = true)) {
                Log.d("DEBUG_LOCKER", "🚨 Security Center App Details detected!")
                showLockScreen(packageName)
                return
            }
        }

        // 2. Protection for MIUI Launcher - trigger on DeleteDialog only
        if (packageName == "com.miui.home") {
            // ONLY trigger when the actual uninstall confirmation dialog appears
            if (className.contains("DeleteDialog", ignoreCase = true) ||
                className.contains("UninstallDialog", ignoreCase = true)) {
                
                Log.d("DEBUG_LOCKER", "🚨 UNINSTALL DIALOG DETECTED!")
                Log.d("DEBUG_LOCKER", "   Class: $className")
                Log.d("DEBUG_LOCKER", "   Text: ${event.text}")
                
                // Show PIN - Flutter side will check if protection is needed
                showLockScreen("system_uninstall")
                return
            }
        }
    }

    private fun showLockScreen(detectedPackage: String) {
        try {
            // Check if within cooldown period (1 minute after last PIN prompt)
            val currentTime = System.currentTimeMillis()
            val timeSinceLastPrompt = currentTime - lastSuccessfulAuthTime
            
            if (timeSinceLastPrompt < COOLDOWN_MS) {
                val remainingSeconds = (COOLDOWN_MS - timeSinceLastPrompt) / 1000
                Log.d("DEBUG_LOCKER", "⏳ Cooldown active ($remainingSeconds seconds remaining), allowing uninstall without PIN")
                return
            }

            Log.d("DEBUG_LOCKER", "🔒 Triggering lock screen for: $detectedPackage")
            
            // Update cooldown - start 1-minute timer from now
            lastSuccessfulAuthTime = currentTime
            
            // Launch our app's lock screen
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("locked_package", detectedPackage)
                putExtra("uninstall_protection", true)
            }
            startActivity(intent)
            
            // Try to close launcher popup by simulating back press
            performGlobalAction(GLOBAL_ACTION_BACK)
            
        } catch (e: Exception) {
            Log.e("DEBUG_LOCKER", "Error launching lock screen: ${e.message}")
        }
    }

    override fun onInterrupt() {
        Log.d("DEBUG_LOCKER", "AccessibilityService interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("DEBUG_LOCKER", "✅ AccessibilityService connected and ready!")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("DEBUG_LOCKER", "❌ AccessibilityService destroyed")
    }
}
