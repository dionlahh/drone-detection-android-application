package org.tensorflow.lite.examples.detection.position;

public class WorldCoordinateOffset {
    private double phoneHeading, droneHeading, dronePosRadius, worldNorthing, worldEasting;
    public WorldCoordinateOffset(double phoneX, double phoneZ, double currentAzimuth){
        phoneHeading = currentAzimuth;
        droneHeading = currentAzimuth + Math.atan(phoneX / phoneZ) * 180;
        dronePosRadius = Math.sqrt(Math.pow(phoneX, 2) + Math.pow(phoneZ, 2));
        worldNorthing = dronePosRadius * Math.cos(2 * Math.PI * droneHeading / 360.0);
        worldEasting = dronePosRadius * Math.sin(2 * Math.PI * droneHeading / 360.0);
    }

    public double getNorthingOffset(){
//        if (droneHeading <= 90)
//            return worldNorthing;
//        else if (droneHeading <= 270)
//            return -worldNorthing;
//        else
//            return worldNorthing;
        return worldNorthing;
    }

    public double getEastingOffset(){
//        if (droneHeading <= 180)
//            return worldEasting;
//        else
//            return -worldEasting;
        return worldEasting;
    }

    public double getDroneHeading(){
        return droneHeading;
    }

    public double getPhoneHeading(){
        return phoneHeading;
    }

    public double getDronePosRadius(){
        return dronePosRadius;
    }
}
