package org.drone.detection.android

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import org.drone.detection.shared.getPlatform
import org.drone.detection.shared.detection.DetectionRepository
import org.drone.detection.shared.detection.TensorflowDetectionEngine
import kotlinx.coroutines.launch
import android.widget.TextView

class MainActivity : AppCompatActivity() {

    private val detectionRepository by lazy {
        DetectionRepository(TensorflowDetectionEngine())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val infoView: TextView = findViewById(R.id.platformInfo)

        lifecycleScope.launch {
            infoView.text = getString(
                R.string.app_name
            ) + " running on ${getPlatform().name}"
        }

        // TODO: Replace placeholder UI with Compose Multiplatform or platform specific UI layers.
    }
}

