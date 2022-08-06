# Drone Detection Map

**Drone Detection Map** is the Hunter Concept's Ground Sensor application.

It was built using Android Studio SDK, Flutter framework and supporting [libraries](#libraries).

Developed by myself, as well as [vintageyj](https://github.com/vintageyj).

**Drone Detection Map** is designed to enable aerial surveillance of a deployment site through object detections on unauthorised (hostile) drones.

Features that **Drone Detection Map** offers:

- Map view of current position
- Area of coverage
- Feature plotting
- Object Detection with Hotswappable Inference Models
- Range & Geopositioning Estimation on detected drones
- Screen Mirror or Camera Feed via RTSP Stream

# Prerequisites

- Android Studio SDK
- Flutter SDK
- Android 9.0 and above

# Table of Contents

1. [Integration](#integration)
2. [Features & Functions](#features--functions)<br>
   a. [Map](#map)<br>
   b. [App Bar Buttons](#app-bar-buttons)<br>
   c. [Floating Action Buttons](#floating-action-buttons)<br>
   d. [Object Detection](#object-detection)<br>
   e. [Object Detection Setup](#object-detector-setup)<br>
   f. [Red Line](#red-line)<br>
   g. [Range & Geopositioning](#range--geopositioning)<br>
3. [Design & Architecture](#design--architecture)<br>
   a. [BLoC](#bloc)<br>
   b. [MVVM](#mvvm)<br>
5. [Libraries](#libraries)

# Integration

Due to outdated TFLite plugins for Flutter, the computer vision aspect of **Drone Detection Map** had to be built on native Android. As such, the Map module of had to be attached as a [Flutter module](https://blog.codemagic.io/flutter-module-android-yaml/).

When developing on different workstations, the Flutter packages and dependencies needs to be updated. This can be done so by running the following command lines within the Flutter module's working directory:

```
flutter clean
```

followed by

```
flutter pub get
```

# Features & Functions

**Drone Detection Map** has mainly two feature-filled modules, the Map and Object Detector.

## Launch

On application launch, it will first launch the map module, with orienation lock on. The screen will show the phone's current location and heading.

## Map

<p align="center">
  <img src="android\readme album\map\Updated\appbar_buttons.jpg" width="240" height="480" />
</p>

## App Bar Buttons:

- Orientation Lock Toggle
  - True (default): Screen is locked to the phone's current position on the map, and and will automatically rotate towards the phones's heading.
  - False: Screen is no longer locked, and the user can move the map around to view other parts of the map. Map no longer automatically rotate to the phone's heading.
- Drone View Mode Toggle
  - Last Detected Location (default): Draws a marker on the map, showing the last detection by the phone.
  - Drone's Flight Path: Shows a polyline, drawn using the all the detected lattitudes and longitudes.
  - Timelapse: Draws markers on the map, showing one detection at a time.
- Grid Toggle
  - Toggles on and off a grid on the map.
- Map Layer Toggle
  - Toggles between different map layers.
- Launch Camera Button
  - Switches the view to the camera for [object detection](#object-detection).
- Settings Button
  - Allows the user to adjust the position marker's arc's radius and span using 2 different sliders. (default: 100m and phone's back camera's horizontal FOV)

## Floating Action Buttons:

These buttons allows for the user to draw its corresponding shapes/objects on the map:

## Clear All:

- Button is only available when there are objects plotted on the map.
- Deletes all plotted objects.

## Polyline:

<p align="center">
    <img src="android\readme album\map\Polyline_Trim_AdobeExpress.gif" width="240" height="480" />
</p>

- Tap on the screen to plot the points of the polyline.
- Save the plotted polyline by pressing the save button. This will change the polyline's colour to red, indicating that it has been saved.
- Toggle button switches the opacity of all saved polylines between 1 (default) and 0.

## Polygon:

<p align="center">
    <img src="android\readme album\map\Polygon_Trim_AdobeExpress.gif" width="240" height="480" />
</p>

- Tap on the screen to plot the points of the polygon.
- Save the plotted polygon by pressing the save button. This will change the polygon's colour to red, indicating that it has been saved.
- Toggle button switches the opacity of all saved polygon between 1 (default) and 0.
- Saved polygons can be edited by tapping on the polygons
  - Square markers on the polygon can be dragged to change the vertice's location.
  - Circle markers on the polygon can be dragged to create a new vertice.
  - Saved polygons can be deleted by tapping on the circle, followed by the delete button.

## Markers:

<p align="center">
    <img src="android\readme album\map\Marker_Trim_AdobeExpress.gif" width="240" height="480" />
</p>

- Tap on the screen to plot different markers.
- To add text beneath the markers, type the text in the textfield at the botttom of the screen. All the markers currently being plotted will have the same text.
- Save the plotted markers by pressing the save button.
- Toggle button switches the opacity of all saved markers between 1 (default) and 0.
- Saved markers can be tapped on for more information regarding the marker's position

## Circles:

<p align="center">
    <img src="android\readme album\map\Circle_Trim_AdobeExpress.gif" width="240" height="480" />
</p>

- Tap on the screen to plot a circle. (Only one circle can be plotted at a time)
- To adjust the radius of the circle, use the slider at the bottom of the screen. The radius in meters is shown beside the slider. (Max: 500m)
- Save the plotted circle by pressing the save button.
- Toggle button switches the opacity of all saved circles between 1 (default) and 0.
- Saved circles' radius can be adjusted by tapping on the circle on the map
- Saved circles can be deleted by tapping on the circle, followed by the delete button.

## Other Map Features:

- Scale Bar
  - Changes according to the current zoom of the map
- Compass
  - Rotates according to the phone's heading

<br>

## Object Detection

The objection detection module is accessible by clicking on the [Launch Camera Button](#app-bar-buttons).

<p align="center">
    <img src="android\readme album\detector\detector_setup.gif" width="240" height="480" />
    <img src="android\readme album\detector\od_setup.jpg" width="240" height="480" />
</p>

### Object Detector Setup

- Detection Switch
  - Toggle for the Object Detection to be on or off (default)
- Red Line Switch
  - Toggle for the Red Line function to be on (default) or off
- Calibration Switch
  - Toggle for Calibration Mode to be on or off (default)
  - Calibration Mode is used to calibrate the range estimator by setting the bounding box of a drone at a distance interval
- Confidence Threshold Slider
  - Tune the confidence threshold for detected results to be appear (default set to 30%)
- Model List
  - Select the custom trained model for the operation's requirement
- Processor List
  - Select which processor unit (CPU/GPU/NPU) to run the model on

<br>

### Red Line

**Drone Detection Map** has a Red Line feature where it can establish a detection cutoff area on the screen. This prevents any unwanted detections below the Red Line, which can be useful in the future for the Hunter Concept's Interceptor drone. This feature can be toggled on or off in the settings page.

<p align="center">
<img src="android\readme album\detector\redline_demo.gif" width="240" height="480" />
</p>

<br>

### Range & Geopositioning

The object detector module also comes equip with range and geopositioning capabilites.

<p align="center">
    <img src="android\readme album\detector\drone_straightline_large.gif" width="240" height="480" />
</p>

The distance between the phone and the detected drone is estimated using the bounding box size of the drone relative to its actual size, as well as the [Pinhole Camera Model](https://en.wikipedia.org/wiki/Pinhole_camera_model#:~:text=The%20pinhole%20camera%20model%20describes,are%20used%20to%20focus%20light.), enabling the 2D screen coordinates to 3D world coordinates conversion.

The bounding box's screen coordinates returned by the inference machine is with respect to the input image size, so additional scaling steps has to be done to factor for the model's input image size and the screen's physical size.

Finally, using the derived distance, the phone's orientation, hearings, current position and the drone's relative heading, we can find the resulting latitude and longitude (LatLong) of the detected drone.

The resulting LatLong can then be saved during detections to be plotted on the map module.

<p align="center">
    <img src="android\readme album\detector\drone_last_location.jpg" width="240" height="480" />
    <img src="android\readme album\detector\drone_flight_path.jpg" width="240" height="480" />
    <img src="android\readme album\detector\drone_flightpath_timelapse.gif" width="240" height="480" />
</p>

Clicking the [Drone View Mode Toggle](#app-bar-buttons) cycles through the different view for the detected drone's locations.

<br>

# Design & Architecture

We used BLoC to implement the MVVM architecture for the map.

## BLoC

Two different BLoCs were used. One for the application to decide which set of buttons and sliders to render on the screen, and when should it be rendered, and the other was used for handling on screen taps.

- New functions and features to be easily implemented in the future, just create new events & states within the bloc, and specifiy the widgets to only render when it the BLoC is in the new state.
- Testing and maintenance can also easily be done by tracking the module's state and events.

## MVVM

We have four main models used, namely `Circles`, `Polygons`, `Polylines`, and `Markers`. Each of these models are then controlled by a view-model, `ObjectMgr`.

- The models are not to be confused with the same objects within [Flutter Map](https://pub.dev/packages/flutter_map) itself.
- [Flutter Map](https://pub.dev/packages/flutter_map)'s objects are rendered based on the models that we have created.
  > If the user plots a new circle on the map, the model `Circles` is first created using the View-Model, then the map renders the `CircleMarker` based on the attributes on the Circles model.

<br>

# Libraries

This section includes useful libraries and plugins used within the Ground Sensor project.

Flutter Dependencies:

- [Flutter Map](https://pub.dev/packages/flutter_map)
- [Flutter Compass](https://pub.dev/packages/flutter_compass)
- [Flutter Map Marker Popup](https://pub.dev/packages/flutter_map_marker_popup)
- [Flutter Map Dragmarker](https://pub.dev/packages/flutter_map_dragmarker)
- [Flutter Map Line Editor](https://pub.dev/packages/flutter_map_line_editor)
- [Geodesy](https://pub.dev/packages/geodesy)
- [Geolocator](https://pub.dev/packages/geolocator)
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
- [Equatable](https://pub.dev/packages/equatable)
- [Permission Handler](https://pub.dev/packages/permission_handler)
- [Cupertino Icons](https://pub.dev/packages/cupertino_icons)

Native Android Libraries:

- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [RTSP Client](https://github.com/pedroSG94/rtmp-rtsp-stream-client-java)
- [RTSP Server](https://github.com/pedroSG94/RTSP-Server)
- [RTSP Simple Server](https://github.com/aler9/rtsp-simple-server)
