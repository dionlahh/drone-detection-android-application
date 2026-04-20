package com.example.flutter_module.host;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.io/battery";
    private static final String TAG = "MainActivity";
    
    // Le package name de votre app Android native
    private static final String DETECTOR_PACKAGE = "org.tensorflow.lite.examples.detection";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        Log.d(TAG, "Configuring Flutter Engine with MethodChannel");
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                Log.d(TAG, "📱 Method called: " + call.method);
                
                switch (call.method) {
                    case "getNativeBuild":
                        Log.d(TAG, "✅ getNativeBuild called");
                        result.success("openCameraActivity");
                        break;
                    
                    case "openCameraActivity":
                        Log.d(TAG, "📷 openCameraActivity called");
                        try {
                            // Vérifier si l'app est installée
                            Intent intent = getPackageManager().getLaunchIntentForPackage(DETECTOR_PACKAGE);
                            
                            if (intent != null) {
                                // L'app est installée, la lancer
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                startActivity(intent);
                                Log.d(TAG, "✅ Detector app launched successfully");
                                result.success("APP_LAUNCHED");
                            } else {
                                // L'app n'est pas installée
                                Log.e(TAG, "❌ Detector app not installed");
                                result.error(
                                    "APP_NOT_FOUND",
                                    "L'application de détection n'est pas installée",
                                    null
                                );
                            }
                        } catch (Exception e) {
                            Log.e(TAG, "❌ Error launching detector app", e);
                            result.error(
                                "LAUNCH_ERROR",
                                "Erreur lors du lancement: " + e.getMessage(),
                                null
                            );
                        }
                        break;
                    
                    case "cameraFOV":
                        Log.d(TAG, "📐 cameraFOV called");
                        result.success("60.0");
                        break;
                    
                    case "increment":
                        Log.d(TAG, "📊 increment called");
                        // Pour l'instant, retourner des données vides
                        result.success("[]");
                        break;
                    
                    default:
                        Log.w(TAG, "⚠️ Method not implemented: " + call.method);
                        result.notImplemented();
                        break;
                }
            });
    }
}
