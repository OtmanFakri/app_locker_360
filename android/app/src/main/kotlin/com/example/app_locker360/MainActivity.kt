package com.example.app_locker360

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app_locker360/media_scanner"
    private val INTENT_CHANNEL = "com.example.app_locker360/intent"
    private var intentMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Existing MediaScanner Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "deleteFromMediaStore" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val success = MediaScannerHandler.deleteFromMediaStore(this, filePath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                "scanMediaFile" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        MediaScannerHandler.scanMediaFile(this, filePath) { success ->
                            result.success(success)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // New Intent Channel
        intentMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL)
        intentMethodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialIntent") {
                result.success(getIntentExtrasMap(intent))
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        this.intent = intent
        intentMethodChannel?.invokeMethod("onNewIntent", getIntentExtrasMap(intent))
    }

    private fun getIntentExtrasMap(intent: android.content.Intent?): Map<String, Any?>? {
        if (intent == null) return null
        val extras = intent.extras ?: return null
        val map = mutableMapOf<String, Any?>()
        for (key in extras.keySet()) {
            map[key] = extras.get(key)
        }
        return map
    }
}
