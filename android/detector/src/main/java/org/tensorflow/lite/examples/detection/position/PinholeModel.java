package org.tensorflow.lite.examples.detection.position;

import android.graphics.Matrix;
import android.graphics.RectF;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.renderscript.Matrix3f;

import org.tensorflow.lite.examples.detection.CameraActivity;
import org.tensorflow.lite.examples.detection.trial.ImageDetectionActivity;

public class PinholeModel {

    private RectF rectF;
    // Units in metres(m)
    private double focalLength;
    private double pxSize = 1.4 * Math.pow(10, -6);
    private double pxHeight = pxSize, pxWidth = pxSize;
    private double droneSize = 0.2895;
    private double droneDistance = 10;
    private double actualHeight, actualWidth;
    private double pxCountX, pxCountY;
    private double rotatedX, rotatedY, rotatedZ;
    private double thetaRad = CameraActivity.phoneTiltAngle / 180f;



    public PinholeModel(RectF rectF, CameraManager cameraManager) {
        this.rectF = rectF;
        CameraCharacteristics cameraCharacteristics;
        {
            try {
                cameraCharacteristics = cameraManager.getCameraCharacteristics("0");

                this.focalLength = cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)[0] * Math.pow(10,-3);
            } catch (CameraAccessException e) {
                e.printStackTrace();
            }
        }

        pxCountX = (rectF.centerX() - 320) * CameraActivity.previewHeight / CameraActivity.imageSize;
        pxCountY = - (rectF.centerY() - 320) * CameraActivity.previewWidth / CameraActivity.imageSize;

    }

    public double getActualHeight(double zDistance) {
        actualHeight = pxCountY * pxHeight * zDistance / focalLength;
        return actualHeight;
    }

    public double getActualWidth(double zDistance) {
        actualWidth = pxCountX * pxWidth * zDistance / focalLength;
        return actualWidth;
    }

    public double getRotatedX(double zDistance){
        rotatedX = pxCountX * pxWidth * zDistance / focalLength;;
        return rotatedX;
    }

    public double getRotatedY(double zDistance){
        thetaRad = Math.toRadians(CameraActivity.phoneTiltAngle);
        rotatedY = Math.cos(thetaRad) * pxCountY * pxHeight * zDistance / focalLength - Math.sin(thetaRad) * zDistance;
        return rotatedY;
    }

    public double getRotatedZ(double zDistance){
        thetaRad = Math.toRadians(CameraActivity.phoneTiltAngle);
        rotatedZ = Math.sin(thetaRad) * pxCountY * pxHeight * zDistance / focalLength + Math.cos(thetaRad) * zDistance;
        return rotatedZ;
    }

    public void setThetaDegree(double thetaDegree) {
        this.thetaRad = Math.toRadians(thetaDegree);
    }

    public double getRotatedZDist(double zDistance) {
        return zDistance * Math.cos(Math.toRadians(CameraActivity.phoneTiltAngle));
    }
}
