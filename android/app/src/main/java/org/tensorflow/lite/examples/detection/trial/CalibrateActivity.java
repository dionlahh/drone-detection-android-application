package org.tensorflow.lite.examples.detection.trial;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import org.tensorflow.lite.examples.detection.position.DrawView;
import org.tensorflow.lite.examples.detection.R;
import org.tensorflow.lite.examples.detection.env.Logger;

public class CalibrateActivity extends AppCompatActivity {

    private DrawView drawView;
    private Button button;

    private int[] rectDim;

    private int boxWidth = 0 , boxHeight = 0;

    private static final Logger LOGGER = new Logger();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_calibrate);
        drawView = findViewById(R.id.draw_view_test);
        button = findViewById(R.id.calibrate_button);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
//                drawView.doTheCrop();
                rectDim = drawView.captureDataPoints();
                boxWidth = rectDim[0];
                boxHeight = rectDim[1];
                LOGGER.d("Box Width: " + boxWidth +
                        "\nBox Height: " + boxHeight);
                Toast.makeText(CalibrateActivity.this, "Width: " + boxWidth + " Height: " + boxHeight, Toast.LENGTH_SHORT).show();
            }
        });
    }
}