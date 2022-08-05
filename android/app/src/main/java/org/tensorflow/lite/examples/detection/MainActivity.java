package org.tensorflow.lite.examples.detection; 

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Sensor;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import org.tensorflow.lite.examples.detection.display.ClientActivity;
import org.tensorflow.lite.examples.detection.trial.*;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;

public class MainActivity extends AppCompatActivity {

    private Button cameraButton, detectButton, flutterButton;

    public static float MINIMUM_CONFIDENCE_TF_OD_API = 0.3f;

    protected static final String[] PERMISSIONS = {
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.ACCESS_FINE_LOCATION
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        getSupportActionBar().setTitle("Point Defence");

        if (!hasPermissions(this, PERMISSIONS)) {
            ActivityCompat.requestPermissions(this, PERMISSIONS, 1);
        }

        ListView listView = findViewById(R.id.listview);
        List<String> list = new ArrayList<>();
        list.add("Camera Detection");
        list.add("Flutter");
        list.add("Image Detection Testing");
        list.add("3D Mapping Testing");
        list.add("Gyroscope and Sensors");
        list.add("Calibrate Camera");
        list.add("RTSP Client");

        ArrayAdapter arrayAdapter = new ArrayAdapter(getApplicationContext(), android.R.layout.simple_list_item_1, list);
        listView.setAdapter(arrayAdapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                switch (i) {
                    case 0: // Camera Objection Detection
                        startActivity(new Intent(MainActivity.this, DetectorActivity.class));
                        break;
                    case 1: // Flutter Activity
                        FlutterEngine flutterEngine = new FlutterEngine(MainActivity.this);
                        flutterEngine.getNavigationChannel().setInitialRoute("/second");

                        flutterEngine.getDartExecutor().executeDartEntrypoint(
                                DartExecutor.DartEntrypoint.createDefault()
                        );
//
                        FlutterEngineCache.getInstance().put("myEngine", flutterEngine);
                                startActivity(
                                        FlutterActivity
                                                .withCachedEngine("myEngine")
                                                .build(MainActivity.this)
                                                .setClass(MainActivity.this, MyFlutterActivity.class)
                                );
                                break;
                    case 2: // Static Image OD Testing
                        startActivity(new Intent(MainActivity.this, ImageDetectionActivity.class));
                        break;
                    case 3: // 3D Mapping Testing
                        startActivity(new Intent(MainActivity.this, SpatialActivity.class));
                        break;
                    case 4: // Gyroscope and Sensors Testing
                        startActivity(new Intent(MainActivity.this, SensorActivity.class));
                        break;
                    case 5: // Camera Calibration Testing
                        startActivity(new Intent(MainActivity.this, CalibrateActivity.class));
                        break;
                    case 6:
                        startActivity(new Intent(MainActivity.this, ClientActivity.class));
                        break;
                    default:
                        break;
                }
            }
        });
//        GeneratedPluginRegistrant.registerWith(flutterEngine);

//        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
//                .setMethodCallHandler(
//                        new MethodChannel.MethodCallHandler() {
//                            @Override
//                            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
//                                if (call.method.equals("test")) {
//                                    String greetings = helloFromNativeCode();
//                                    result.success(greetings);
//                                }
//                            }
//                        });


//        cameraButton = findViewById(R.id.cameraButton);
//        detectButton = findViewById(R.id.detectButton);
//        flutterButton = findViewById(R.id.flutterButton);




//        FlutterEngine flutterEngine = new FlutterEngine(this);
//        flutterEngine.getNavigationChannel().setInitialRoute("/second");
//
//        flutterEngine.getDartExecutor().executeDartEntrypoint(
//                DartExecutor.DartEntrypoint.createDefault()
//        );
////
//        FlutterEngineCache.getInstance().put("myEngine", flutterEngine);
//        flutterButton.setOnClickListener(v->
//                startActivity(
//                        FlutterActivity
//                                .withCachedEngine("myEngine")
//                                .build(this)
//                                .setClass(this, MyFlutterActivity.class)
//                ));

//        flutterButton.setOnClickListener(v->
//                startActivity(
//                        new FlutterActivity.CachedEngineIntentBuilder(MyFlutterActivity.class, "myEngine")
//                                .build(getApplicationContext())
//                                .putExtra("title", "Title")
//                ));

//        cameraButton.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, DetectorActivity.class)));
//        detectButton.setOnClickListener(v -> startActivity(new Intent(MainActivity.this, SpatialActivity.class)));
    }


    protected static boolean hasPermissions(Context context, String... permissions) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2 && context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED)
                    return false;
            }
        }
        return true;
    }
}
