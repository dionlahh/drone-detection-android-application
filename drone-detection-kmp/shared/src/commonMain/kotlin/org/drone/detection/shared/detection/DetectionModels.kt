package org.drone.detection.shared.detection

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

/**
 * Represents a raw inference result that can be mapped onto platform specific drawing layers.
 */
data class DetectionResult(
    val id: String,
    val label: String,
    val confidence: Float,
    val boundingBox: BoundingBox
)

data class BoundingBox(
    val left: Float,
    val top: Float,
    val right: Float,
    val bottom: Float
)

/**
 * Abstraction for the object detection pipeline so platform code can provide optimized implementations.
 */
interface DetectionEngine {
    suspend fun loadModel(modelId: String)
    suspend fun start()
    suspend fun stop()
    val detections: Flow<List<DetectionResult>>
}

/**
 * Placeholder shared repository that glues detection results to the map module.
 * The Android implementation will bridge to TensorFlow Lite while other platforms can provide
 * their own strategy or default to simulation data.
 */
class DetectionRepository(
    private val engine: DetectionEngine
) {
    private val _activeModel = MutableStateFlow<String?>(null)
    val activeModel: Flow<String?> = _activeModel

    suspend fun activateModel(modelId: String) {
        engine.stop()
        engine.loadModel(modelId)
        engine.start()
        _activeModel.value = modelId
    }

    suspend fun deactivate() {
        engine.stop()
        _activeModel.value = null
    }

    val detections: Flow<List<DetectionResult>> = engine.detections
}

