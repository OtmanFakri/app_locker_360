package com.example.app_locker360

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AppMonitorAccessibilityService : AccessibilityService() {

    companion object {
        private var instance: AppMonitorAccessibilityService? = null
        private var temporaryBypassUntil: Long = 0
        private const val BYPASS_DURATION_MS = 45000L // 45 seconds - enough time for settings
        
        /**
         * Called from MainActivity when PIN is successfully verified
         * Sets the cooldown timer to allow uninstall without re-prompting for 1 minute
         */
        fun notifyPinVerified() {
            instance?.let {
                it.lastSuccessfulAuthTime = System.currentTimeMillis()
                Log.d("DEBUG_LOCKER", "✅ PIN verified! Cooldown started for 60 seconds")
            } ?: Log.w("DEBUG_LOCKER", "⚠️ Cannot set cooldown - service instance is null")
        }
        
        /**
         * Temporarily bypass lock screen checks for settings access
         * Called when user is opening settings to configure permissions
         */
        fun setTemporaryBypass() {
            temporaryBypassUntil = System.currentTimeMillis() + BYPASS_DURATION_MS
            Log.d("DEBUG_LOCKER", "⏳ Temporary bypass enabled for 15 seconds")
        }
    }

    // Cooldown: After entering PIN correctly, allow 1 minute without prompting again
    private var lastSuccessfulAuthTime: Long = 0
    private val COOLDOWN_MS = 60000L // 1 minute cooldown

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || event.packageName == null) return
        
        // Check for temporary bypass (when user is configuring permissions)
        val currentTime = System.currentTimeMillis()
        if (currentTime < temporaryBypassUntil) {
            val remainingSeconds = (temporaryBypassUntil - currentTime) / 1000
            Log.d("DEBUG_LOCKER", "⏭️ Temporary bypass active ($remainingSeconds seconds remaining)")
            return
        }
        
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
        
        // 3. GENERIC Uninstall Protection (works on all Android devices)
        // Detect system package installers and uninstaller activities
        if (packageName == "com.google.android.packageinstaller" ||
            packageName == "com.android.packageinstaller" ||
            packageName == "com.samsung.android.packageinstaller") {
            
            // Check if it's an uninstaller activity
            if (className.contains("Uninstall", ignoreCase = true) ||
                className.contains("UninstallAppProgress", ignoreCase = true)) {
                
                Log.d("DEBUG_LOCKER", "🚨 GENERIC UNINSTALL DETECTED!")
                Log.d("DEBUG_LOCKER", "   Package: $packageName")
                Log.d("DEBUG_LOCKER", "   Class: $className")
                Log.d("DEBUG_LOCKER", "   Event: $eventTypeStr")
                
                // Show PIN screen
                showLockScreen("system_uninstall")
                return
            }
        }
    }

    private fun showLockScreen(detectedPackage: String) {
        try {
            // Check if within cooldown period (1 minute after last successful PIN entry)
            val currentTime = System.currentTimeMillis()
            val timeSinceLastAuth = currentTime - lastSuccessfulAuthTime
            
            if (timeSinceLastAuth < COOLDOWN_MS) {
                val remainingSeconds = (COOLDOWN_MS - timeSinceLastAuth) / 1000
                Log.d("DEBUG_LOCKER", "⏳ Cooldown active ($remainingSeconds seconds remaining), allowing uninstall without PIN")
                return
            }

            Log.d("DEBUG_LOCKER", "🔒 Triggering lock screen for: $detectedPackage")
            
            // NOTE: Do NOT set cooldown here! 
            // Cooldown is set ONLY after successful PIN verification via notifyPinVerified()
            
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
        instance = this
        
        // Start as foreground service with persistent notification
        startForegroundServiceWithNotification()

        Log.d("DEBUG_LOCKER", "✅ AccessibilityService connected and ready!")
    }
    
    private fun startForegroundServiceWithNotification() {
        try {
            val channelId = "accessibility_service_channel"
            val channelName = "Accessibility Service"
            
            // Create notification channel (required for Android O+)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val importance = android.app.NotificationManager.IMPORTANCE_LOW
                val channel = android.app.NotificationChannel(channelId, channelName, importance).apply {
                    description = "Keeps accessibility service running for app protection"
                    setShowBadge(false)
                }
                val notificationManager = getSystemService(android.app.NotificationManager::class.java)
                notificationManager.createNotificationChannel(channel)
            }
            
            // Create notification
            val notification = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                android.app.Notification.Builder(this, channelId)
            } else {
                @Suppress("DEPRECATION")
                android.app.Notification.Builder(this)
            }
                .setContentTitle("App Protection Active")
                .setContentText("Protecting your apps")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setOngoing(true)
                .setPriority(android.app.Notification.PRIORITY_LOW)
                .build()
            
            // Start foreground service
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                startForeground(
                    1001,
                    notification,
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                @Suppress("DEPRECATION")
                startForeground(1001, notification)
            }
            
            Log.d("DEBUG_LOCKER", "🔔 Foreground service started with notification")
        } catch (e: Exception) {
            Log.e("DEBUG_LOCKER", "Failed to start foreground service: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        
        // Stop foreground service
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        
        Log.d("DEBUG_LOCKER", "❌ AccessibilityService destroyed")
    }
}
