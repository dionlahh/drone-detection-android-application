package org.tensorflow.lite.examples.detection;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class CameraService extends Service {
    public CameraService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }
}