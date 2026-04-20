package org.tensorflow.lite.examples.detection.tflite

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.RectF
import android.os.Build
import android.util.Log
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.util.PriorityQueue
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.Tensor
import org.tensorflow.lite.examples.detection.CameraActivity
import org.tensorflow.lite.examples.detection.env.Logger
import org.tensorflow.lite.examples.detection.env.Utils
import org.tensorflow.lite.gpu.GpuDelegate
import org.tensorflow.lite.nnapi.NnApiDelegate

/**
 * Kotlin port of the YOLOv5 TensorFlow Lite wrapper.
 */
class YoloV5Classifier private constructor() : Classifier {

    private val labels = mutableListOf<String>()
    private lateinit var imgData: ByteBuffer
    private lateinit var outData: ByteBuffer
    private lateinit var intValues: IntArray

    private var inpScale: Float = 0f
    private var inpZeroPoint: Int = 0
    private var oupScale: Float = 0f
    private var oupZeroPoint: Int = 0
    private var numClass: Int = 0

    private var inputSize: Int = -1
    private var outputBox: Int = 0
    private var isModelQuantized: Boolean = false

    private var tfLite: Interpreter? = null
    private var tfliteModel: MappedByteBuffer? = null
    private var tfliteOptions: Interpreter.Options = Interpreter.Options()

    private var gpuDelegate: GpuDelegate? = null
    private var nnapiDelegate: NnApiDelegate? = null

    private var mNmsThresh = 0.6f

    override fun enableStatLogging(debug: Boolean) = Unit

    override fun getStatString(): String = ""

    override fun close() {
        tfLite?.close()
        tfLite = null
        gpuDelegate?.close()
        gpuDelegate = null
        nnapiDelegate?.close()
        nnapiDelegate = null
        tfliteModel = null
    }

    override fun setNumThreads(numThreads: Int) {
        // No-op: Interpreter threads must be configured via Interpreter.Options.
    }

    override fun setUseNNAPI(isChecked: Boolean) {
        if (isChecked) {
            useNNAPI()
        } else {
            useCPU()
        }
    }

    override fun getObjThresh(): Float = CameraActivity.confThresh

    fun getInputSize(): Int = inputSize

    fun getCutOffY(): Int = CameraActivity.cutOffY

    private fun recreateInterpreter() {
        val model = tfliteModel ?: return
        tfLite?.close()
        tfLite = Interpreter(model, tfliteOptions)
    }

    fun useGpu() {
        if (gpuDelegate == null) {
            gpuDelegate = GpuDelegate().also {
                tfliteOptions.addDelegate(it)
            }
            recreateInterpreter()
        }
    }

    fun useCPU() {
        recreateInterpreter()
    }

    fun useNNAPI() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            nnapiDelegate = NnApiDelegate().also {
                tfliteOptions.addDelegate(it)
            }
            recreateInterpreter()
        }
    }

    override fun recognizeImage(bitmap: Bitmap): List<Classifier.Recognition> {
        val bb = convertBitmapToByteBuffer(bitmap)
        val outputMap = mutableMapOf<Int, Any>()
        outData.rewind()
        outputMap[0] = outData

        val inputArray = arrayOf<Any>(bb)
        tfLite?.runForMultipleInputsOutputs(inputArray, outputMap)

        val byteBuffer = outputMap[0] as ByteBuffer
        byteBuffer.rewind()

        val out = Array(1) { Array(outputBox) { FloatArray(numClass + 5) } }
        for (i in 0 until outputBox) {
            for (j in 0 until numClass + 5) {
                out[0][i][j] = if (isModelQuantized) {
                    oupScale * ((byteBuffer.get().toInt() and 0xFF) - oupZeroPoint)
                } else {
                    byteBuffer.getFloat()
                }
            }
            for (j in 0 until 4) {
                out[0][i][j] *= getInputSize()
            }
        }

        val detections = ArrayList<Classifier.Recognition>()
        for (i in 0 until outputBox) {
            val confidence = out[0][i][4]
            var detectedClass = -1
            var maxClass = 0f

            val classes = FloatArray(labels.size)
            for (c in labels.indices) {
                classes[c] = out[0][i][5 + c]
                if (classes[c] > maxClass) {
                    detectedClass = c
                    maxClass = classes[c]
                }
            }

            val confidenceInClass = maxClass * confidence
            if (confidenceInClass > objThresh && detectedClass >= 0) {
                val xPos = out[0][i][0]
                val yPos = out[0][i][1]
                val w = out[0][i][2]
                val h = out[0][i][3]

                val rect = RectF(
                    max(0f, xPos - w / 2),
                    max(0f, yPos - h / 2),
                    min(bitmap.width - 1f, xPos + w / 2),
                    min(bitmap.height - 1f, yPos + h / 2)
                )

                if (yPos + h < getCutOffY()) {
                    detections.add(
                        Classifier.Recognition(
                            id = i.toString(),
                            title = labels[detectedClass],
                            confidence = confidenceInClass,
                            mutableLocation = rect,
                            detectedClass = detectedClass
                        )
                    )
                }
            }
        }

        return nms(detections)
    }

    private fun convertBitmapToByteBuffer(bitmap: Bitmap): ByteBuffer {
        bitmap.getPixels(
            intValues, 0, bitmap.width, 0, 0,
            bitmap.width, bitmap.height
        )

        imgData.rewind()
        for (i in 0 until inputSize) {
            for (j in 0 until inputSize) {
                val pixelValue = intValues[i * inputSize + j]
                if (isModelQuantized) {
                    imgData.put(
                        (((pixelValue shr 16 and 0xFF) - IMAGE_MEAN) / IMAGE_STD / inpScale + inpZeroPoint).toInt().toByte()
                    )
                    imgData.put(
                        (((pixelValue shr 8 and 0xFF) - IMAGE_MEAN) / IMAGE_STD / inpScale + inpZeroPoint).toInt().toByte()
                    )
                    imgData.put(
                        (((pixelValue and 0xFF) - IMAGE_MEAN) / IMAGE_STD / inpScale + inpZeroPoint).toInt().toByte()
                    )
                } else {
                    imgData.putFloat(((pixelValue shr 16 and 0xFF) - IMAGE_MEAN) / IMAGE_STD)
                    imgData.putFloat(((pixelValue shr 8 and 0xFF) - IMAGE_MEAN) / IMAGE_STD)
                    imgData.putFloat(((pixelValue and 0xFF) - IMAGE_MEAN) / IMAGE_STD)
                }
            }
        }
        return imgData
    }

    private fun nms(recognitions: ArrayList<Classifier.Recognition>): ArrayList<Classifier.Recognition> {
        val nmsList = ArrayList<Classifier.Recognition>()
        for (k in labels.indices) {
            val queue = PriorityQueue<Classifier.Recognition>(50) { lhs, rhs ->
                java.lang.Float.compare(rhs.confidence ?: 0f, lhs.confidence ?: 0f)
            }
            for (recognition in recognitions) {
                if (recognition.detectedClass == k) {
                    queue.add(recognition)
                }
            }

            while (queue.isNotEmpty()) {
                val detections = queue.toTypedArray()
                val maxRecognition = detections[0]
                nmsList.add(maxRecognition)
                queue.clear()

                for (j in 1 until detections.size) {
                    val detection = detections[j]
                    val location = detection.location ?: continue
                    val maxLocation = maxRecognition.location ?: continue
                    if (boxIou(maxLocation, location) < mNmsThresh) {
                        queue.add(detection)
                    }
                }
            }
        }
        return nmsList
    }

    private fun boxIou(a: RectF, b: RectF): Float {
        return boxIntersection(a, b) / boxUnion(a, b)
    }

    private fun boxIntersection(a: RectF, b: RectF): Float {
        val w = overlap((a.left + a.right) / 2, a.right - a.left, (b.left + b.right) / 2, b.right - b.left)
        val h = overlap((a.top + a.bottom) / 2, a.bottom - a.top, (b.top + b.bottom) / 2, b.bottom - b.top)
        if (w < 0 || h < 0) return 0f
        return w * h
    }

    private fun boxUnion(a: RectF, b: RectF): Float {
        val intersection = boxIntersection(a, b)
        val union = (a.right - a.left) * (a.bottom - a.top) +
            (b.right - b.left) * (b.bottom - b.top) - intersection
        return union
    }

    private fun overlap(x1: Float, w1: Float, x2: Float, w2: Float): Float {
        val l1 = x1 - w1 / 2
        val l2 = x2 - w2 / 2
        val left = max(l1, l2)
        val r1 = x1 + w1 / 2
        val r2 = x2 + w2 / 2
        val right = min(r1, r2)
        return right - left
    }

    fun checkInvalidateBox(
        x: Float,
        y: Float,
        width: Float,
        height: Float,
        oriW: Float,
        oriH: Float,
        inputSize: Int
    ): Boolean {
        val halfHeight = height / 2.0f
        val halfWidth = width / 2.0f

        val predCoor = floatArrayOf(
            x - halfWidth,
            y - halfHeight,
            x + halfWidth,
            y + halfHeight
        )

        val resizeRatioW = inputSize.toFloat() / oriW
        val resizeRatioH = inputSize.toFloat() / oriH
        val resizeRatio = min(resizeRatioW, resizeRatioH)

        val dw = (inputSize - resizeRatio * oriW) / 2
        val dh = (inputSize - resizeRatio * oriH) / 2

        predCoor[0] = (predCoor[0] - dw) / resizeRatio
        predCoor[2] = (predCoor[2] - dw) / resizeRatio
        predCoor[1] = (predCoor[1] - dh) / resizeRatio
        predCoor[3] = (predCoor[3] - dh) / resizeRatio

        predCoor[0] = max(0f, predCoor[0])
        predCoor[1] = max(0f, predCoor[1])
        predCoor[2] = min(oriW - 1, predCoor[2])
        predCoor[3] = min(oriH - 1, predCoor[3])

        if (predCoor[0] > predCoor[2] || predCoor[1] > predCoor[3]) {
            return false
        }

        val area = (predCoor[2] - predCoor[0]) * (predCoor[3] - predCoor[1])
        if (area < 0) {
            Log.e("checkInvalidateBox", "temp < 0")
            return false
        }
        if (sqrt(area.toDouble()) > Float.MAX_VALUE) {
            Log.e("checkInvalidateBox", "temp max")
            return false
        }
        return true
    }

    companion object {
        private val LOGGER = Logger()

        private const val IMAGE_MEAN = 0f
        private const val IMAGE_STD = 255.0f
        private const val NUM_THREADS = 1

        private const val BATCH_SIZE = 1
        private const val PIXEL_SIZE = 3

        private var isNNAPI = false
        private var isGPU = false

        @JvmStatic
        @Throws(IOException::class)
        fun create(
            assetManager: AssetManager,
            modelFilename: String,
            labelFilename: String,
            isQuantized: Boolean,
            inputSize: Int
        ): YoloV5Classifier {
            val classifier = YoloV5Classifier()

            val actualFilename = labelFilename.split("file:///android_asset/")[1]
            assetManager.open(actualFilename).use { input ->
                BufferedReader(InputStreamReader(input)).useLines { sequence ->
                    sequence.forEach { line ->
                        LOGGER.w(line)
                        classifier.labels.add(line)
                    }
                }
            }

            val options = Interpreter.Options().apply {
                setNumThreads(NUM_THREADS)
                if (isNNAPI && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    classifier.nnapiDelegate = NnApiDelegate()
                    addDelegate(classifier.nnapiDelegate)
                    setUseNNAPI(true)
                }
                if (isGPU) {
                    val delegate = GpuDelegate(
                        GpuDelegate.Options().apply {
                            setPrecisionLossAllowed(true)
                            setInferencePreference(GpuDelegate.Options.INFERENCE_PREFERENCE_SUSTAINED_SPEED)
                        }
                    )
                    classifier.gpuDelegate = delegate
                    addDelegate(delegate)
                }
            }

            classifier.tfliteOptions = options
            classifier.tfliteModel = Utils.loadModelFile(assetManager, modelFilename)
            classifier.tfLite = Interpreter(classifier.tfliteModel!!, options)

            classifier.isModelQuantized = isQuantized
            val numBytesPerChannel = if (isQuantized) 1 else 4
            classifier.inputSize = inputSize
            classifier.imgData = ByteBuffer.allocateDirect(BATCH_SIZE * inputSize * inputSize * PIXEL_SIZE * numBytesPerChannel).apply {
                order(ByteOrder.nativeOrder())
            }
            classifier.intValues = IntArray(inputSize * inputSize)

            classifier.outputBox = (
                (inputSize / 32.0).pow(2.0) +
                    (inputSize / 16.0).pow(2.0) +
                    (inputSize / 8.0).pow(2.0)
                ).toInt() * 3

            if (classifier.isModelQuantized) {
                val inputTensor: Tensor = classifier.tfLite!!.getInputTensor(0)
                classifier.inpScale = inputTensor.quantizationParams().scale
                classifier.inpZeroPoint = inputTensor.quantizationParams().zeroPoint
                val outputTensor: Tensor = classifier.tfLite!!.getOutputTensor(0)
                classifier.oupScale = outputTensor.quantizationParams().scale
                classifier.oupZeroPoint = outputTensor.quantizationParams().zeroPoint
            }

            val shape = classifier.tfLite!!.getOutputTensor(0).shape()
            val numClass = shape[shape.size - 1] - 5
            classifier.numClass = numClass
            classifier.outData = ByteBuffer.allocateDirect(classifier.outputBox * (numClass + 5) * numBytesPerChannel).apply {
                order(ByteOrder.nativeOrder())
            }

            return classifier
        }

        private val objThresh: Float
            get() = CameraActivity.confThresh
    }
}

