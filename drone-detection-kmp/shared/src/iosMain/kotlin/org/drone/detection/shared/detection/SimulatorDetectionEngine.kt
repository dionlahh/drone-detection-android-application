package org.drone.detection.shared.detection

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

/**
 * iOS stub implementation that simply emits no detections for now.
 * Replace with a real CoreML bridge when the detection pipeline is ported.
 */
class SimulatorDetectionEngine : DetectionEngine {
    private val scope = CoroutineScope(Dispatchers.Default)
    private val detectionsFlow = MutableSharedFlow<List<DetectionResult>>(replay = 1)

    override suspend fun loadModel(modelId: String) {
        detectionsFlow.emit(emptyList())
    }

    override suspend fun start() {
        scope.launch {
            while (true) {
                detectionsFlow.emit(emptyList())
                delay(1_000)
            }
        }
    }

    override suspend fun stop() {
        // No-op for simulator
    }

    override val detections: Flow<List<DetectionResult>> = detectionsFlow
}

