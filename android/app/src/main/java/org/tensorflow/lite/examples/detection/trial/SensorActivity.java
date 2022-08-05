package org.tensorflow.lite.examples.detection.trial;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.os.Bundle;
import android.util.Log;
import android.util.SizeF;
import android.widget.ImageView;
import android.widget.TextView;

import org.tensorflow.lite.examples.detection.R;
import org.tensorflow.lite.examples.detection.compass.Compass;
import org.tensorflow.lite.examples.detection.compass.SOTWFormatter;
import org.tensorflow.lite.examples.detection.env.Logger;

import java.util.List;

import org.tensorflow.lite.examples.detection.env.Logger;



public class SensorActivity extends AppCompatActivity {


    private static final Logger LOGGER = new Logger();
    private TextView angle, x_accel, y_accel, z_accel;

    private Compass compass;
    private TextView sotwLabel;  // SOTW is for "side of the world"

    private float currentAzimuth;
    private SOTWFormatter sotwFormatter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sensor);

        angle = findViewById(R.id.accelerometer);
        x_accel = findViewById(R.id.x_acceleration);
        y_accel = findViewById(R.id.y_acceleration);
        z_accel = findViewById(R.id.z_acceleration);

        SensorManager sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        List<Sensor> accelerometer = sensorManager.getSensorList(Sensor.TYPE_ACCELEROMETER);

        // For Legacy Camera
//        Camera camera = Camera.open(0);
//        Camera.Parameters cameraParameters = camera.getParameters();
//        double cameraHFOV = cameraParameters.getHorizontalViewAngle();
//        double cameraVFOV = cameraParameters.getVerticalViewAngle();
//        camera.release();




        // For Camera2 API
        double horizontalAngle = 0;
        double verticalAngle = 0;
        CameraManager cameraManager = (CameraManager) getSystemService(Context.CAMERA_SERVICE);
        try {
            CameraCharacteristics cameraCharacteristics = (CameraCharacteristics) cameraManager.getCameraCharacteristics("0");
            float focalLength = cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)[0];
            SizeF sensorSize = cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE);
            horizontalAngle = Math.toDegrees(2f * Math.atan(sensorSize.getWidth() / (focalLength * 2f)));
            verticalAngle = Math.toDegrees(2f * Math.atan(sensorSize.getHeight() / (focalLength * 2f)));
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }


        double finalHorizontalAngle = horizontalAngle;
        double finalVerticalAngle = verticalAngle;


        SensorEventListener accelerometerEventListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent sensorEvent) {
                float[] values = sensorEvent.values;
                float x = values[0];
                float y = values[1];
                float z = values[2];
                double ang = Math.toDegrees(Math.atan(Math.abs(y/z)));
                if (z < 0) {
                    if (currentAzimuth >= 180)
                        currentAzimuth -= 180;
                    else
                        currentAzimuth += 180;
                }
                angle.setText("Accelerometer: " + ang + "\n" +
                        "Camera2HFOV: " + finalHorizontalAngle +
                        "\nCamera2VFOV: " + finalVerticalAngle +
                        "\nHeading: " + sotwFormatter.format(currentAzimuth));
                x_accel.setText("X: " + x);
                y_accel.setText("Y: " + y);
                z_accel.setText("Z: " + z);
                LOGGER.d(ang + ", " + x + ", " + y + ", " + z + ", Camera2HFOV: " + finalHorizontalAngle + ", Camera2VFOV: " + finalVerticalAngle);
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int i) {

            }
        };
        sensorManager.registerListener(accelerometerEventListener, accelerometer.get(0), SensorManager.SENSOR_DELAY_NORMAL);

        sotwFormatter = new SOTWFormatter(this);
        setupCompass();

    }

    @Override
    protected void onStart() {
        super.onStart();
        compass.start();
    }

    @Override
    protected void onPause() {
        super.onPause();
        compass.stop();
    }

    @Override
    protected void onResume() {
        super.onResume();
        compass.start();
    }

    @Override
    protected void onStop() {
        super.onStop();
        compass.stop();
    }

    private void setupCompass() {
        compass = new Compass(this);
        Compass.CompassListener compassListener = getCompassListner();
        compass.setListener(compassListener);
    }

    private Compass.CompassListener getCompassListner() {
        return new Compass.CompassListener() {
            @Override
            public void onNewAzimuth(float azimuth) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        currentAzimuth = azimuth;
                    }
                });
            }
        };
    }
}