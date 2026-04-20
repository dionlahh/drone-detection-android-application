package org.tensorflow.lite.examples.detection.tflite

import android.graphics.Bitmap
import android.graphics.RectF

/**
 * Generic interface for interacting with different recognition engines.
 */
interface Classifier {
    fun recognizeImage(bitmap: Bitmap): List<Recognition>
    fun enableStatLogging(debug: Boolean)
    fun getStatString(): String
    fun close()
    fun setNumThreads(numThreads: Int)
    fun setUseNNAPI(isChecked: Boolean)
    fun getObjThresh(): Float

    /**
     * An immutable result returned by a Classifier describing what was recognized.
     */
    data class Recognition(
        val id: String?,
        val title: String?,
        val confidence: Float?,
        private var mutableLocation: RectF? = null,
        var detectedClass: Int = -1
    ) {

        var location: RectF?
            get() = mutableLocation?.let { RectF(it) }
            set(value) {
                mutableLocation = value?.let { RectF(it) }
            }

        override fun toString(): String {
            val builder = StringBuilder()
            if (id != null) {
                builder.append("[").append(id).append("] ")
            }
            if (title != null) {
                builder.append(title).append(" ")
            }
            if (confidence != null) {
                builder.append(String.format("(%.1f%%) ", confidence * 100.0f))
            }
            if (_location != null) {
                builder.append(_location).append(" ")
            }
            return builder.toString().trim()
        }
    }
}

