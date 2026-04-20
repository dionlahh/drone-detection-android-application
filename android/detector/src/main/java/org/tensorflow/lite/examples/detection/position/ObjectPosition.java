package org.tensorflow.lite.examples.detection.position;


import android.graphics.RectF;

import org.tensorflow.lite.examples.detection.CameraActivity;
import org.tensorflow.lite.examples.detection.tflite.Classifier;

public class ObjectPosition {
    private RectF rectF;
    private int imageSize;
    private float droneDim = 0.2895f;
    public double sizeConstant = 10f * Math.sqrt(54.7f * 42.3f);
    private double relativeX, relativeY, relativeZ;
    private double rotatedX, rotatedY, rotatedZ;
    private double thetaRad;
    private LinearInterpolation linearInterpolation;

    public ObjectPosition(RectF rectF, int imageSize){
        this.rectF = rectF;
        this.imageSize = imageSize;
        this.thetaRad = CameraActivity.phoneTiltAngle / 180;
        this.linearInterpolation = new LinearInterpolation();

        relativeX = (rectF.centerX() - 320) * droneDim / rectF.height();
        relativeY = - (rectF.centerY() - 320) * droneDim / rectF.width();
//        relativeZ = sizeConstant / (Math.sqrt(rectF.width() * rectF.height()));
        relativeZ = linearInterpolation.getDistanceEstimate(Math.sqrt(rectF.width() * rectF.height()));

        rotatedX = relativeX;
        rotatedY = Math.cos(thetaRad) * relativeY + -Math.sin(thetaRad) * relativeZ;
        rotatedZ = Math.sin(thetaRad) * relativeY + Math.cos(thetaRad) * relativeZ;
    }

    public double getRelativeX() {
        return relativeX;
    }

    public double getRelativeY() {
        return relativeY;
    }

    public double getRelativeZ() {
        return relativeZ;
    }

    public double getRotatedX(){
        return rotatedX;
    }

    public double getRotatedY() {
        return rotatedY;
    }

    public double getRotatedZ() {
        return rotatedZ;
    }

    public void setThetaDegree(double thetaDegree) {
        this.thetaRad = thetaDegree;
    }

    public void updateSizeConstant(double droneDistance, double boxWidth, double boxHeight){
        sizeConstant = droneDistance * Math.sqrt(boxWidth * boxHeight);
        relativeZ = sizeConstant / (Math.sqrt(rectF.width() * rectF.height()));
        rotatedY = Math.cos(thetaRad) * relativeY + -Math.sin(thetaRad) * relativeZ;
        rotatedZ = Math.sin(thetaRad) * relativeY + Math.cos(thetaRad) * relativeZ;
    }
}
