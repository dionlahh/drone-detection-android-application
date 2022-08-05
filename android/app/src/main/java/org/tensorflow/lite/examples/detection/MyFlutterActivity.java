package org.tensorflow.lite.examples.detection;

import android.content.Intent;
import android.hardware.Camera;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;

import org.tensorflow.lite.examples.detection.display.ClientActivity;
import org.tensorflow.lite.examples.detection.env.Logger;
import org.tensorflow.lite.examples.detection.utils.AppConfiguration;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;

import io.flutter.plugins.GeneratedPluginRegistrant;

public class MyFlutterActivity extends FlutterActivity {

    private static final Logger LOGGER = new Logger();
    private static final String CHANNEL = "samples.flutter.io/battery";

    String title = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle extras = getIntent().getExtras();
        title = extras.getString("title");
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(((methodCall, result) -> {
            if (methodCall.method.equals("increment")) {
//                SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd G 'at' HH:mm:ss:SSS z");
//                String currentDateandTime = sdf.format(new Date());
                List<String> stringList = new ArrayList<>();
                // String format is in : result id, northing offset, easting offset
                stringList.add("0,-12.5,2.45");
                stringList.add("1,-12.5,2.45");
                List<String> resultList = CameraActivity.worldOffsetResults;
//                LOGGER.d(resultList.get(0) + " " + resultList.get(1));
                String json = new Gson().toJson(resultList);
                if (AppConfiguration.debugMode) {
                    if (resultList.size() == 0) {
                        Toast.makeText(MyFlutterActivity.this, "No saved detections", Toast.LENGTH_SHORT).show();
                    } else {
                        Toast.makeText(MyFlutterActivity.this, "Updated " + resultList.size() + " detections", Toast.LENGTH_SHORT).show();
                    }
                }
                result.success(json);
            } else if (methodCall.method.equals("getNativeBuild")) {
                result.success(AppConfiguration.nativeBuild);
            } else if (methodCall.method.equals("Detection")) {
                startActivity(new Intent(MyFlutterActivity.this, DetectorActivity.class));
                overridePendingTransition(R.anim.enter_from_right, R.anim.exit_out_left);
            } else if (methodCall.method.equals("RTSP")) {
                startActivity(new Intent(MyFlutterActivity.this, ClientActivity.class));
                overridePendingTransition(R.anim.enter_from_right, R.anim.exit_out_left);
            } else if (methodCall.method.equals("getTitle")) {
                result.success(title); // It returns string "batteryLevel".
            } else if (methodCall.method.equals("showToast")) {
                String argument = methodCall.argument("msg");
                Toast.makeText(this, argument, Toast.LENGTH_LONG).show();
            } else if (methodCall.method.equals("getTime")) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd 'at' HH:mm:ss Z");
                sdf.setTimeZone(TimeZone.getTimeZone("GMT+8:00"));
                String currentDateandTime = sdf.format(new Date());
                result.success(currentDateandTime);
            } else if (methodCall.method.equals("cameraFOV")) {
                Camera camera = Camera.open(0);
                Camera.Parameters cameraParameters = camera.getParameters();
                double cameraHFOV = cameraParameters.getHorizontalViewAngle();
//                double cameraVFOV = cameraParameters.getVerticalViewAngle();
                result.success(String.valueOf(cameraHFOV));
                camera.release();
            } else {
                result.notImplemented();
            }
        }));
    }
}
