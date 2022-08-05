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

        while (true) {
            if (!MainActivity.hasPermissions(this, MainActivity.PERMISSIONS)) {
                ActivityCompat.requestPermissions(this, MainActivity.PERMISSIONS, 1);
            } else {
                break;
            }
        }

        new Handler().postDelayed(
                () -> {
                    if (AppConfiguration.debugMode) {
                        startActivity(new Intent(this, MainActivity.class));
                    } else {
                        FlutterEngine flutterEngine = new FlutterEngine(SplashActivity.this);
                        flutterEngine.getNavigationChannel().setInitialRoute("/second");

                        flutterEngine.getDartExecutor().executeDartEntrypoint(
                                DartExecutor.DartEntrypoint.createDefault()
                        );
//
                        FlutterEngineCache.getInstance().put("myEngine", flutterEngine);
                        startActivity(
                                FlutterActivity
                                        .withCachedEngine("myEngine")
                                        .build(SplashActivity.this)
                                        .setClass(SplashActivity.this, MyFlutterActivity.class)
                        );
                    }
                        finish();
                }, 0
        );
    }
}