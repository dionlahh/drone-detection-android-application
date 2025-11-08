package org.drone.detection.androidApp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import android.widget.TextView
import kotlinx.coroutines.launch
import org.drone.detection.shared.detection.DetectionRepository
import org.drone.detection.shared.detection.TensorflowDetectionEngine
import org.drone.detection.shared.getPlatform

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

