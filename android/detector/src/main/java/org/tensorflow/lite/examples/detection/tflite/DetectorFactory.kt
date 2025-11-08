package org.tensorflow.lite.examples.detection.tflite

import android.content.res.AssetManager
import android.util.Log
import java.io.IOException

object DetectorFactory {

    @Throws(IOException::class)
    fun getDetector(assetManager: AssetManager, modelFilename: String): YoloV5Classifier {
        var labelFilename: String? = null
        var isQuantized = false
        var inputSize = 0
        var outputWidth = intArrayOf(0)
        var masks = arrayOf(intArrayOf(0))
        var anchors = intArrayOf(0)

        when (modelFilename) {
            "yolov5s.tflite" -> {
                labelFilename = "file:///android_asset/coco.txt"
                isQuantized = false
                inputSize = 640
                outputWidth = intArrayOf(80, 40, 20)
                masks = arrayOf(intArrayOf(0, 1, 2), intArrayOf(3, 4, 5), intArrayOf(6, 7, 8))
                anchors = intArrayOf(
                    10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326
                )
            }
            "yolov5s-fp16.tflite" -> {
                labelFilename = "file:///android_asset/coco.txt"
                isQuantized = false
                inputSize = 320
                outputWidth = intArrayOf(40, 20, 10)
                masks = arrayOf(intArrayOf(0, 1, 2), intArrayOf(3, 4, 5), intArrayOf(6, 7, 8))
                anchors = intArrayOf(
                    10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326
                )
            }
            "yolov5s-int8.tflite" -> {
                labelFilename = "file:///android_asset/coco.txt"
                isQuantized = true
                inputSize = 640
                outputWidth = intArrayOf(40, 20, 10)
                masks = arrayOf(intArrayOf(0, 1, 2), intArrayOf(3, 4, 5), intArrayOf(6, 7, 8))
                anchors = intArrayOf(
                    10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326
                )
            }
            "yolov5n-int8.tflite" -> {
                labelFilename = "file:///android_asset/coco.txt"
                isQuantized = true
                inputSize = 320
                outputWidth = intArrayOf(40, 20, 10)
                masks = arrayOf(intArrayOf(0, 1, 2), intArrayOf(3, 4, 5), intArrayOf(6, 7, 8))
                anchors = intArrayOf(
                    10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326
                )
            }
            "yolov5n-fp16.tflite" -> {
                labelFilename = "file:///android_asset/coco.txt"
                isQuantized = false
                inputSize = 320
                outputWidth = intArrayOf(40, 20, 10)
                masks = arrayOf(intArrayOf(0, 1, 2), intArrayOf(3, 4, 5), intArrayOf(6, 7, 8))
                anchors = intArrayOf(
                    10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326
                )
            }
            else -> {
                val modelConfig = modelFilename.split("-")
                Log.d("DetectorFactory", "${modelConfig[2]} ${modelConfig[3]}")
                inputSize = modelConfig[2].toInt()
                isQuantized = modelConfig[3] != "fp16.tflite"
                labelFilename = "file:///android_asset/labels_custom_drone.txt"
                outputWidth = intArrayOf(40, 20, 10)
                masks = arrayOf(intArrayOf(0, 1, 2), intArrayOf(3, 4, 5), intArrayOf(6, 7, 8))
                anchors = intArrayOf(
                    10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326
                )
            }
        }

        Log.d(
            "DetectorFactory",
            "$modelFilename $labelFilename $isQuantized $inputSize"
        )

        return YoloV5Classifier.create(
            assetManager,
            modelFilename,
            labelFilename,
            isQuantized,
            inputSize
        )
    }
}

