package org.tensorflow.lite.examples.detection;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import org.tensorflow.lite.examples.detection.utils.AppConfiguration;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;

public class SplashActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        getSupportActionBar().hide();

        // Vérifier et demander les permissions de manière asynchrone
        if (!MainActivity.hasPermissions(this, MainActivity.PERMISSIONS)) {
            ActivityCompat.requestPermissions(this, MainActivity.PERMISSIONS, 1);
            // Attendre que les permissions soient accordées avant de continuer
            // Les permissions seront gérées dans onRequestPermissionsResult
            return;
        }

        // Si les permissions sont déjà accordées, lancer DetectorActivity
        launchDetectorActivity();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        // Vérifier si toutes les permissions sont accordées
        boolean allPermissionsGranted = true;
        for (int result : grantResults) {
            if (result != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                allPermissionsGranted = false;
                break;
            }
        }
        
        if (allPermissionsGranted) {
            // Les permissions sont accordées, lancer DetectorActivity
            launchDetectorActivity();
        } else {
            // Les permissions sont refusées, fermer l'app ou afficher un message
            android.util.Log.e("SplashActivity", "Permissions denied. Cannot launch DetectorActivity.");
            finish();
        }
    }

    private void launchDetectorActivity() {
        new Handler().postDelayed(
                () -> {
                    try {
                        // Lancer directement DetectorActivity (la caméra)
                        Intent intent = new Intent(this, DetectorActivity.class);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
                        finish();
                    } catch (Exception e) {
                        android.util.Log.e("SplashActivity", "Error launching DetectorActivity", e);
                        // En cas d'erreur, retourner au menu principal
                        try {
                            startActivity(new Intent(this, MainActivity.class));
                            finish();
                        } catch (Exception e2) {
                            android.util.Log.e("SplashActivity", "Error launching MainActivity", e2);
                            finish();
                        }
                    }
                }, 500 // Petit délai pour s'assurer que l'UI est prête
        );
    }
}