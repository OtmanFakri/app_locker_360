package com.example.app_locker360

import android.app.AppOpsManager
import android.content.Context
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
            when (call.method) {
                "getInitialIntent" -> {
                    result.success(getIntentExtrasMap(intent))
                }
                "isXiaomiPermissionGranted" -> {
                    val isGranted = isXiaomiBackgroundPermissionGranted()
                    result.success(isGranted)
                }
                "openXiaomiOtherPermissions" -> {
                    try {
                        val intent = android.content.Intent("miui.intent.action.APP_PERM_EDITOR")
                        intent.setClassName(
                            "com.miui.securitycenter",
                            "com.miui.permcenter.permissions.PermissionsEditorActivity"
                        )
                        intent.putExtra("extra_pkgname", packageName)
                        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        // Fallback to general permissions page
                        try {
                            val fallbackIntent = android.content.Intent("miui.intent.action.APP_PERM_EDITOR")
                            fallbackIntent.putExtra("extra_pkgname", packageName)
                            fallbackIntent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(fallbackIntent)
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("ERROR", "Failed to open permissions: ${ex.message}", null)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
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

    private fun isXiaomiBackgroundPermissionGranted(): Boolean {
        val manufacturer = android.os.Build.MANUFACTURER.lowercase()
        if (!manufacturer.contains("xiaomi") && !manufacturer.contains("redmi")) {
            return true
        }

        try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val uid = android.os.Process.myUid()
            val pkg = packageName
            
            // HNA FIN KENNA GHALTIN:
            // Ma-nsta3mlouch String ("android:..."), n-sta3mlo Reflection bach n-passiw Rqm (10021)
            
            // 1. Jib Class d-AppOpsManager
            val appOpsClass = AppOpsManager::class.java
            
            // 2. Jib l-Method "checkOpNoThrow" li kat-9bel (int, int, String)
            // Note: int.class f Java hiya Int::class.javaPrimitiveType f Kotlin
            val method = appOpsClass.getMethod(
                "checkOpNoThrow", 
                Int::class.javaPrimitiveType, 
                Int::class.javaPrimitiveType, 
                String::class.java
            )
            
            // 3. Executi l-Method (Invoke) m3a Rqm 10021
            // 10021 = OP_BACKGROUND_START_ACTIVITY
            val result = method.invoke(appOps, 10021, uid, pkg) as Int
            
            // 4. Debugging
            println("XIAOMI DEBUG: OpCode=10021, Result=$result (Allowed is ${AppOpsManager.MODE_ALLOWED})")

            return result == AppOpsManager.MODE_ALLOWED

        } catch (e: Exception) {
            println("XIAOMI DEBUG: Error -> $e")
            return false 
        }
    }
}
