package org.tensorflow.lite.examples.detection.display

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.pedro.rtplibrary.base.DisplayBase
import com.pedro.rtplibrary.rtmp.RtmpDisplay
import com.pedro.rtplibrary.rtsp.RtspDisplay
import org.tensorflow.lite.examples.detection.ConnectCheckerRtp
import org.tensorflow.lite.examples.detection.R


/**
 * Basic RTMP/RTSP service streaming implementation with camera2
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
class DisplayService : Service() {

    override fun onCreate() {
        super.onCreate()
        INSTANCE = this
        Log.i(TAG, "RTP Display service create")
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel =
                NotificationChannel(channelId, channelId, NotificationManager.IMPORTANCE_HIGH)
            notificationManager?.createNotificationChannel(channel)
        }
        keepAliveTrick()
    }

    private fun keepAliveTrick() {
        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_dsta_logo)
            .setSilent(true)
            .setOngoing(false)
            .build()
        startForeground(1, notification)
    }

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        INSTANCE = this
        Log.i(TAG, "RTP Display service started")
        displayBase = RtmpDisplay(baseContext, true, connectCheckerRtp)
        displayBase?.glInterface?.setForceRender(true)
        return START_STICKY
    }

    companion object {
        private const val TAG = "DisplayService"
        private const val channelId = "rtpDisplayStreamChannel"
        const val notifyId = 123456
        var INSTANCE: DisplayService? = null
    }

    private var notificationManager: NotificationManager? = null
    private var displayBase: DisplayBase? = null

    fun sendIntent(): Intent? {
        return displayBase?.sendIntent()
    }

    fun isStreaming(): Boolean {
        return displayBase?.isStreaming ?: false
    }

    fun isRecording(): Boolean {
        return displayBase?.isRecording ?: false
    }

    fun stopStream() {
        if (displayBase?.isStreaming == true) {
            displayBase?.stopStream()
            notificationManager?.cancel(notifyId)
        }
    }

    private val connectCheckerRtp = object : ConnectCheckerRtp {

        override fun onConnectionStartedRtp(rtpUrl: String) {
        }

        override fun onConnectionSuccessRtp() {
            showNotification("Stream started")
            Log.i(TAG, "RTP service destroy")
        }

        override fun onNewBitrateRtp(bitrate: Long) {

        }

        override fun onConnectionFailedRtp(reason: String) {
            showNotification("Stream connection failed")
            Log.i(TAG, "RTP service destroy")
        }

        override fun onDisconnectRtp() {
            showNotification("Stream stopped")
        }

        override fun onAuthErrorRtp() {
            showNotification("Stream auth error")
        }

        override fun onAuthSuccessRtp() {
            showNotification("Stream auth success")
        }
    }

    private fun showNotification(text: String) {
        val notification = NotificationCompat.Builder(baseContext, channelId)
            .setSmallIcon(R.drawable.ic_dsta_logo)
            .setContentTitle("RTP Display Stream")
            .setContentText(text)
            .setOngoing(false)
            .build()
        notificationManager?.notify(notifyId, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i(TAG, "RTP Display service destroy")
        stopStream()
        INSTANCE = null
    }

    fun prepareStreamRtp(endpoint: String, resultCode: Int, data: Intent) {
        stopStream()
        if (endpoint.startsWith("rtmp")) {
            displayBase = RtmpDisplay(baseContext, true, connectCheckerRtp)
            displayBase?.setIntentResult(resultCode, data)
        } else {
            displayBase = RtspDisplay(baseContext, true, connectCheckerRtp)
            displayBase?.setIntentResult(resultCode, data)
        }
        displayBase?.glInterface?.setForceRender(true)
    }

    fun startStreamRtp(endpoint: String) {
        if (displayBase?.isStreaming != true) {
            if (displayBase?.prepareVideo(
                    1920,
                    1080,
                    30,
                    4000000,
                    0,
                    320
                ) == true && displayBase?.prepareAudio() == true
            ) {
                displayBase?.startStream(endpoint)
            }
        } else {
            showNotification("You are already streaming :(")
        }
    }
}
