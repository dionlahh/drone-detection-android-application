package org.tensorflow.lite.examples.detection;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.RequiresApi;

public class MyForegroundService extends Service {

    private MyForegroundServiceBinder binder = new MyForegroundServiceBinder();

    @Override
    public void onCreate() {
        super.onCreate();

    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        new Thread(
                new Runnable() {
                    @Override
                    public void run() {
                        while(true){
//                            Log.d("TAG", "Foreground service is running");
                            try {
                                Thread.sleep(2000);
                            } catch (InterruptedException e) {

                            }
                        }
                    }
                }
        ).start();

        final String NOTIFICATION_CHANNEL_ID = "foreground service";
        NotificationChannel channel = new NotificationChannel(NOTIFICATION_CHANNEL_ID, NOTIFICATION_CHANNEL_ID, NotificationManager.IMPORTANCE_DEFAULT);

        getSystemService(NotificationManager.class).createNotificationChannel(channel);
        Notification.Builder notification = new Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setContentText("Foreground Service App")
                .setContentTitle("My Title");

        startForeground(1001, notification.build());

        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    public class MyForegroundServiceBinder extends Binder {
        MyForegroundService getService() {
            return MyForegroundService.this;
        }
    }
}