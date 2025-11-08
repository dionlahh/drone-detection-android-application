package org.drone.detection.shared.detection

import android.content.Context
import android.graphics.Bitmap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.tensorflow.lite.examples.detection.tflite.DetectorFactory
import org.tensorflow.lite.examples.detection.tflite.YoloV5Classifier

/**
 * Android implementation of [DetectionEngine] backed by the converted Kotlin YOLOv5 pipeline.
 *
 * Usage:
 *  1. Call [loadModel] with the desired `.tflite` asset filename.
 *  2. Call [start] to begin processing.
 *  3. Feed frames via [submitFrame]. Detection results are emitted through [detections].
 *  4. Call [stop] to tear everything down.
 */
class TensorflowDetectionEngine(
    private val context: Context,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Default)
) : DetectionEngine {

    private val detectionsChannel = Channel<List<DetectionResult>>(Channel.BUFFERED)
    private var frameChannel = Channel<Bitmap>(Channel.BUFFERED)
    private val mutex = Mutex()

    private var classifier: YoloV5Classifier? = null
    private var processingJob: Job? = null
    private var isRunning: Boolean = false

    override val detections: Flow<List<DetectionResult>> = detectionsChannel.receiveAsFlow()

    override suspend fun loadModel(modelId: String) {
        mutex.withLock {
            classifier?.close()
            classifier = DetectorFactory.getDetector(context.assets, modelId)
        }
    }

    override suspend fun start() {
        if (processingJob != null) return

        isRunning = true

        val channel = frameChannel

        processingJob = scope.launch {
            for (bitmap in channel) {
                if (!isRunning) {
                    bitmap.recycle()
                    continue
                }

                val detector = mutex.withLock { classifier }
                if (detector == null) {
                    bitmap.recycle()
                    continue
                }

                runCatching {
                    val recognitions = detector.recognizeImage(bitmap)
                    val mapped = recognitions.mapNotNull { recognition ->
                        val location = recognition.location ?: return@mapNotNull null
                        DetectionResult(
                            id = recognition.id ?: recognition.hashCode().toString(),
                            label = recognition.title ?: "unknown",
                            confidence = recognition.confidence ?: 0f,
                            boundingBox = BoundingBox(
                                left = location.left,
                                top = location.top,
                                right = location.right,
                                bottom = location.bottom
                            )
                        )
                    }
                    detectionsChannel.trySend(mapped)
                }.onFailure {
                    // Logcat left to Android layer. For now we swallow to keep shared module agnostic.
                }

                bitmap.recycle()
            }
        }
    }

    override suspend fun stop() {
        isRunning = false
        processingJob?.cancel()
        processingJob = null

        frameChannel.close()
        frameChannel = Channel(Channel.BUFFERED)

        mutex.withLock {
            classifier?.close()
            classifier = null
        }
    }

    /**
     * Submit a camera frame for processing. Caller retains ownership of the Bitmap until it is copied.
     * A copy is enqueued so that downstream recycling does not affect the caller.
     */
    fun submitFrame(bitmap: Bitmap) {
        if (!isRunning) return
        val config = bitmap.config ?: Bitmap.Config.ARGB_8888
        val copy = bitmap.copy(config, /* isMutable = */ false)
        frameChannel.trySend(copy)
    }
}
