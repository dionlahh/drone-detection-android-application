package org.tensorflow.lite.examples.detection.tflite;

import android.content.res.AssetManager;
import android.util.Log;

import java.io.IOException;

public class DetectorFactory {
    public static YoloV5Classifier getDetector(
            final AssetManager assetManager,
            final String modelFilename)
            throws IOException {
        String labelFilename = null;
        boolean isQuantized = false;
        int inputSize = 0;
        int[] output_width = new int[]{0};
        int[][] masks = new int[][]{{0}};
        int[] anchors = new int[]{0};

        if (modelFilename.equals("yolov5s.tflite")) {
            labelFilename = "file:///android_asset/coco.txt";
            isQuantized = false;
            inputSize = 640;
            output_width = new int[]{80, 40, 20};
            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
            anchors = new int[]{
                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
            };
        }
        else if (modelFilename.equals("yolov5s-fp16.tflite")) {
            labelFilename = "file:///android_asset/coco.txt";
            isQuantized = false;
            inputSize = 320;
            output_width = new int[]{40, 20, 10};
            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
            anchors = new int[]{
                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
            };
        }
        else if (modelFilename.equals("yolov5s-int8.tflite")) {
            labelFilename = "file:///android_asset/coco.txt";
            isQuantized = true;
            inputSize = 640;
            output_width = new int[]{40, 20, 10};
            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
            anchors = new int[]{
                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
            };
        }
        else if (modelFilename.equals("yolov5n-int8.tflite")) {
            labelFilename = "file:///android_asset/coco.txt";
            isQuantized = true;
            inputSize = 320;
            output_width = new int[]{40, 20, 10};
            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
            anchors = new int[]{
                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
            };
        }
        else if (modelFilename.equals("yolov5n-fp16.tflite")) {
            labelFilename = "file:///android_asset/coco.txt";
            isQuantized = false;
            inputSize = 320;
            output_width = new int[]{40, 20, 10};
            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
            anchors = new int[]{
                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
            };
        }
//        else if (modelFilename.equals("yolov5-nano-640-fp16.tflite")) {
//            labelFilename = "file:///android_asset/labels_custom.txt";
//            isQuantized = false;
//            inputSize = 640;
//            output_width = new int[]{40, 20, 10};
//            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
//            anchors = new int[]{
//                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
//            };
//        }
//        else if (modelFilename.equals("yolov5-extra-640-fp16.tflite")) {
//            labelFilename = "file:///android_asset/labels_custom.txt";
//            isQuantized = false;
//            inputSize = 640;
//            output_width = new int[]{40, 20, 10};
//            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
//            anchors = new int[]{
//                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
//            };
//        }
        else {
            String modelName = modelFilename;
            String[] modelConfig = modelName.split("-");
            Log.d("DetectorFactory", modelConfig[2] + " " + modelConfig[3]);
            inputSize = Integer.parseInt(modelConfig[2]);
            if (modelConfig[3].equals("fp16.tflite"))
                isQuantized = false;
            else isQuantized = true;
            labelFilename = "file:///android_asset/labels_custom_drone.txt";
            output_width = new int[]{40, 20, 10};
            masks = new int[][]{{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
            anchors = new int[]{
                    10,13, 16,30, 33,23, 30,61, 62,45, 59,119, 116,90, 156,198, 373,326
            };
        }
        Log.d("DetectorFactory", modelFilename + " " + labelFilename + " " + isQuantized  + " " +
                inputSize);

        return YoloV5Classifier.create(assetManager, modelFilename, labelFilename, isQuantized,
                inputSize);
    }

}
