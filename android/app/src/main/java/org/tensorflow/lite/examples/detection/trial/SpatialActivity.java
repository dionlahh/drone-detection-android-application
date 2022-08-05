package org.tensorflow.lite.examples.detection.trial;

import androidx.appcompat.app.AppCompatActivity;

import android.hardware.Camera;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Bundle;
import android.widget.TextView;

import com.pedro.encoder.input.video.Camera2ApiManager;

import org.tensorflow.lite.examples.detection.R;
import org.tensorflow.lite.examples.detection.env.Logger;

public class SpatialActivity extends AppCompatActivity {

    // Camera1API
    Camera camera = Camera.open(0);
    Camera.Parameters cameraParameters = camera.getParameters();

    // Units are in metres(m)
    private double focal = cameraParameters.getFocalLength() * Math.pow(10, -3);
    private double pxSize = 1.4 * Math.pow(10, -6);
    private double pxHeight = pxSize, pxWidth = pxSize;
    private double droneSize = 0.2895;
    private double droneDistance = 10;
    private double actualHeight, actualWidth;
    private static final Logger LOGGER = new Logger();
    private TextView textView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_spatial);

        double focalLength = 0;
        //Camera2API
        CameraManager cameraManager =
                (CameraManager)getSystemService(CAMERA_SERVICE);
        CameraCharacteristics cameraCharacteristics;
        {
            try {
                cameraCharacteristics = cameraManager.getCameraCharacteristics("0");

                focalLength = cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)[0] * Math.pow(10,-3);
            } catch (CameraAccessException e) {
                e.printStackTrace();
            }
        }

        textView = findViewById(R.id.textView);
        actualHeight = pxHeight * droneDistance / focalLength;
        actualWidth = pxWidth * droneDistance / focalLength;
        textView.setText("Camera focal length: " + focalLength +
                "\nDrone distance: " + droneDistance +
                "\nActual Height: " + actualHeight +
                "\nActual Width: " + actualWidth);
        LOGGER.d("Camera focal length: " + focalLength +
                "\nDrone distance: " + droneDistance +
                "\nActual Height: " + actualHeight +
                "\nActual Width: " + actualWidth);
    }
}