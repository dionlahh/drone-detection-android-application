package org.tensorflow.lite.examples.detection.position;

import org.tensorflow.lite.examples.detection.env.Logger;

public class LinearInterpolation {
    private double[] xList = {81.117, 55.498, 41.533, 23.324};  // Box corner to corner diagonal length
    private double[] yList = {1.5, 3, 5, 10};                   // Distances between drone & phone

    private double extrapolateConstant = 10 * 23.324;

    private static Logger LOGGER = new Logger();


    public LinearInterpolation(){
    }

    public LinearInterpolation(double[] xList, double[] yList) {
        this.xList = xList;
        this.yList = yList;
    }

    public double getDistanceEstimate(double x) { // x = Math.sqrt(width * height), y = distance in m
        double x1, x2;
        double y1, y2;
        double y = extrapolateConstant / x;

        if (x <= xList[0] && x>= xList[xList.length - 1]) {
            for (int i = 0; i < xList.length; i++){
                if (xList[i] == x){
                    y = yList[i];
                } else if (i > 0) {
                    if (xList[i-1] > x && x > xList[i]) {
                        y1 = yList[i-1];
                        y2 = yList[i];
                        x1 = xList[i-1];
                        x2 = xList[i];
                        y = y1 + (x-x1) * (y2-y1) / (x2 - x1);
                        LOGGER.d(String.format("getDistanceEstimate x: %.2f  y: %.2f", x, y));
                    }
                }
            }
        }
        return y;
    }
}
