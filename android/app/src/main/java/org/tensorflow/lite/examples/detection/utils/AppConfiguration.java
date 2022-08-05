package org.tensorflow.lite.examples.detection.utils;

public class AppConfiguration {
    // Debug Mode
    public static boolean debugMode = false;

    // Launch Mode (Flutter module with OD or RTSP)
    public static String nativeBuild = "Detection";
//    public static String nativeBuild = "RTSP";

    // Camera Preview Desired Resolution
    public static int DESIRED_PREVIEW_WIDTH = 1280;
    public static int DESIRED_PREVIEW_HEIGHT = 720;

    // RTSP Client Default Streaming Settings
    public static String RTSP_URL = "rtsp://serverIPAddress/stream/";
    public static int RTSP_WIDTH = 1920;
    public static int RTSP_HEIGHT = 1080;
    public static int RTSP_FPS;
    public static int RTSP_BITRATE;

    // Object Detection Capture Data Interval
    public static int DETECTION_RATE = 1000;
}
