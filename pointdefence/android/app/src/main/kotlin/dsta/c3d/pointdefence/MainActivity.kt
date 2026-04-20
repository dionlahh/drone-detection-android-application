package dsta.c3d.pointdefence

import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.io/battery"
    private val TAG = "MainActivity"
    
    // Le package name de votre app Android native
    private val DETECTOR_PACKAGE = "org.tensorflow.lite.examples.detection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Configuring Flutter Engine with MethodChannel")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d(TAG, "📱 Method called: ${call.method}")
                
                when (call.method) {
                    "getNativeBuild" -> {
                        Log.d(TAG, "✅ getNativeBuild called")
                        result.success("openCameraActivity")
                    }
                    
                    "openCameraActivity" -> {
                        Log.d(TAG, "📷 openCameraActivity called")
                        try {
                            var launchIntent: Intent? = null
                            
                            // Méthode 1: Essayer de lancer directement DetectorActivity (le plus direct)
                            Log.d(TAG, "🔍 Trying DetectorActivity directly...")
                            try {
                                val detectorIntent = Intent().apply {
                                    setClassName(DETECTOR_PACKAGE, "$DETECTOR_PACKAGE.DetectorActivity")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                }
                                
                                val resolveInfo = packageManager.resolveActivity(detectorIntent, PackageManager.MATCH_DEFAULT_ONLY)
                                if (resolveInfo != null) {
                                    launchIntent = detectorIntent
                                    Log.d(TAG, "✅ Found DetectorActivity, launching directly")
                                } else {
                                    Log.d(TAG, "⚠️ DetectorActivity not directly accessible, trying SplashActivity...")
                                }
                            } catch (e2: Exception) {
                                Log.w(TAG, "⚠️ Error checking DetectorActivity: ${e2.message}")
                            }
                            
                            // Méthode 2: Si DetectorActivity n'est pas accessible, utiliser SplashActivity (qui lance DetectorActivity)
                            if (launchIntent == null) {
                                Log.d(TAG, "🔍 Trying SplashActivity (will launch DetectorActivity)...")
                                try {
                                    val splashIntent = Intent().apply {
                                        setClassName(DETECTOR_PACKAGE, "$DETECTOR_PACKAGE.SplashActivity")
                                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                    }
                                    
                                    val splashResolveInfo = packageManager.resolveActivity(splashIntent, PackageManager.MATCH_DEFAULT_ONLY)
                                    if (splashResolveInfo != null) {
                                        launchIntent = splashIntent
                                        Log.d(TAG, "✅ Found SplashActivity, will launch DetectorActivity")
                                    }
                                } catch (e3: Exception) {
                                    Log.w(TAG, "⚠️ Error checking SplashActivity: ${e3.message}")
                                }
                            }
                            
                            // Méthode 3: Fallback vers getLaunchIntentForPackage
                            if (launchIntent == null) {
                                Log.d(TAG, "🔍 Trying getLaunchIntentForPackage as fallback...")
                                launchIntent = packageManager.getLaunchIntentForPackage(DETECTOR_PACKAGE)
                                if (launchIntent != null) {
                                    Log.d(TAG, "✅ Found app via getLaunchIntentForPackage")
                                }
                            }
                            
                            if (launchIntent != null) {
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                startActivity(launchIntent)
                                Log.d(TAG, "✅ Detector app launched successfully")
                                result.success("APP_LAUNCHED")
                            } else {
                                // L'app n'est vraiment pas installée
                                Log.e(TAG, "❌ Detector app not installed. Package: $DETECTOR_PACKAGE")
                                Log.d(TAG, "💡 Suggestion: Install the app with: cd android && ./gradlew installDebug")
                                result.error(
                                    "APP_NOT_FOUND",
                                    "L'application de détection n'est pas installée.\n\nVeuillez installer l'app Android native:\ncd android && ./gradlew installDebug\n\nPackage attendu: $DETECTOR_PACKAGE",
                                    null
                                )
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "❌ Error launching detector app", e)
                            result.error(
                                "LAUNCH_ERROR",
                                "Erreur lors du lancement: ${e.message}",
                                null
                            )
                        }
                    }
                    
                    "cameraFOV" -> {
                        Log.d(TAG, "📐 cameraFOV called")
                        result.success("60.0")
                    }
                    
                    "increment" -> {
                        Log.d(TAG, "📊 increment called")
                        // Pour l'instant, retourner des données vides
                        result.success("[]")
                    }
                    
                    else -> {
                        Log.w(TAG, "⚠️ Method not implemented: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
    }
}
