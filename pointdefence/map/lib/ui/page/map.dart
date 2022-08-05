// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:map/blocs/menu_bloc/menu_bloc.dart';
import 'package:map/blocs/object_bloc/draw_objects_bloc.dart';
import 'package:map/circles_mgr.dart';
import 'package:map/markers_mgr.dart';
import 'package:map/ui/common/droneCalc.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:flutter_map/plugin_api.dart';
import '../widget/scale_layer_plugin_option.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../widget/example_popup.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import '../widget/arc_painter.dart' as live;
import '../common/handleTap.dart' as tap;
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import '../../object_mgr.dart';
import '../widget/compass.dart' as compass;
import '../../network/model/arc.dart';
import '../common/droneCalc.dart';
import '../common/native_android_method_channel.dart';
import '../common/drone_icon_icons.dart';
// import '../common/objectCreator.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapPageState();
  }
}

class MapPageState extends State<MapPage> {
  final PopupController _popupLayerController = PopupController();
  final ObjectMgr objectMgr = ObjectMgr();
  Arc arc = Arc();
  bool showPolygon = true;
  bool showMarkers = true;
  bool showCircle = true;
  bool showLines = true;
  bool testMode = false;
  bool settings = false;
  bool grid = false;
  int layerSelection = 2;
  List<String> tileLayers = [
    // Default
    'https://maps-{s}.onemap.sg/v3/Default/{z}/{x}/{y}.png',
    'https://maps-{s}.onemap.sg/v3/Night/{z}/{x}/{y}.png',
    'https://maps-{s}.onemap.sg/v3/Grey/{z}/{x}/{y}.png',
    'https://maps-{s}.onemap.sg/v3/Original/{z}/{x}/{y}.png',
    // TileLayerOptions(
    //   // Offline
    //   tileProvider: const AssetTileProvider(),
    //   tileBuilder: tileBuilder,
    //   maxZoom: 14.0,
    //   urlTemplate: 'assets/map/anholt_osmbright/{z}/{x}/{y}.png',
    // ),
  ];
  double directionRad = 0;
  int droneViewSelection = 0;
  int droneIndex = 0;

// Handles grids
  Widget tileBuilder(BuildContext context, Widget tileWidget, Tile tile) {
    final coords = tile.coords;

    return Container(
      decoration: BoxDecoration(
        border: grid ? Border.all() : null,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          tileWidget,
          if (grid)
            Text(
              '${coords.x.floor()} : ${coords.y.floor()} : ${coords.z.floor()}',
              // style: Theme.of(context).textTheme.headline5,
            ),
        ],
      ),
    );
  }

// Live Location
  LocationData? _currentLocation;
  late final MapController _mapController;
  bool _liveUpdate = true;
  bool _permission = false;
  String? _serviceError = '';
  var interActiveFlags = InteractiveFlag.all;
  final Location _locationService = Location();
  late PolyEditor polyEditor;

  @override
  void initState() {
    super.initState();
    NativeAndroidMethodChannel().getCameraFOV();
    _mapController = MapController();
    initLocationService();
    Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        {
          droneIndex = (droneIndex + 1);
        }
      });
    });
  }

  void initLocationService() async {
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 10,
    );

    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        var permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                _currentLocation = result;
                DroneFunctions droneFunctions = DroneFunctions(
                    currentPos: LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!));
                droneFunctions.getDroneData();
                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  _mapController.moveAndRotate(
                      LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      _mapController.zoom,
                      directionRad * -1);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng;

    // ObjectCreator objectCreator = ObjectCreator(objectMgr);

    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.
    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      currentLatLng =
          LatLngBounds(LatLng(1.56073, 104.11475), LatLng(1.16, 103.502))
              .center;
    }

    return BlocBuilder<DrawObjectsBloc, DrawObjectsState>(
      builder: ((context, drawObjectState) {
        return BlocBuilder<MenuBloc, MenuState>(builder: (context, menuState) {
          if (drawObjectState is DrawObjectsInitial) {
            return const CircularProgressIndicator();
          }
          if (drawObjectState is DrawObjectsLoaded) {
            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                      onPressed: () => _liveUpdate = !_liveUpdate,
                      icon: Icon(_liveUpdate
                          ? Icons.location_disabled
                          : Icons.location_searching)),
                  IconButton(
                      onPressed: () => setState(() =>
                          droneViewSelection = (droneViewSelection + 1) % 3),
                      icon: const Icon(DroneIcon.kindpng_536873)),
                  IconButton(
                    onPressed: () => setState(() => grid = !grid),
                    icon: Icon(grid ? Icons.grid_off : Icons.grid_on),
                  ),
                  IconButton(
                      onPressed: () => setState(() => layerSelection =
                          (layerSelection + 1) % tileLayers.length),
                      icon: const Icon(Icons.layers)),
                  IconButton(
                      onPressed: () => setState(() {
                            NativeAndroidMethodChannel().getNativeBuild();
                          }),
                      icon: const Icon(Icons.camera)),
                  IconButton(
                      onPressed: () => setState(() => settings = !settings),
                      icon: const Icon(Icons.settings)),
                  // IconButton(
                  //     onPressed: () => setState(() => testMode = !testMode),
                  //     icon: const Text("-")),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    // if (testMode)
                    //   Container(
                    //     padding: const EdgeInsets.all(8.0),
                    //     alignment: Alignment.topRight,
                    //     child: Column(
                    //       children: [
                    //         Text(
                    //             "No of Circles: ${drawObjectState.circles.length}"),
                    //         Text(
                    //             "No of Markers: ${drawObjectState.markers.length}"),
                    //         Text(
                    //             "No of Polygons: ${drawObjectState.polygons.length}"),
                    //         Text(
                    //             "No of Polylines: ${drawObjectState.polylines.length}"),
                    //         Text(
                    //             "No of Circles2: ${objectMgr.getCircles().length}"),
                    //         Text(
                    //             "No of Markers2: ${objectMgr.getMarkers().length}"),
                    //         Text(
                    //             "No of Polygons2: ${objectMgr.getPolygons().length}"),
                    //         Text(
                    //             "No of Polylines2: ${objectMgr.getPolylines().length}"),
                    //       ],
                    //     ),
                    //   ),
                    Flexible(
                      child: _buildMap(
                        currentLatLng,
                      ),
                    ),
                    if (menuState is MarkerMenuState)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              // fillColor: Colors.transparent,
                              filled: false,
                              border: OutlineInputBorder(),
                              labelText: "Marker's Text",
                              isDense: true,
                            ),
                            onChanged: (value) => setState(() {
                              MarkersMgr.setUserInput(value);
                              objectMgr.clearTempMarkers();
                              for (var i = 0;
                                  i < ObjectMgr.tempTextCoordinates.length;
                                  i++) {
                                objectMgr.createTempMarker(
                                    ObjectMgr.tempTextCoordinates[i],
                                    80,
                                    80,
                                    true,
                                    MarkersMgr.getUserInput);
                              }
                            }),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              floatingActionButton: _buildButtons(currentLatLng),
            );
          } else {
            return const Text('Something went wrong!');
          }
        });
      }),
    );
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      var t = tap.HandleTap(latlng, objectMgr);
      t.handleTap();
    });
  }

  void _reset() {
    setState(() {
      ObjectMgr.tempPolygonPoints.clear();
      ObjectMgr.tempPolylinePoints.clear();
      ObjectMgr.polylinePoints.clear();
// circle stuff
      ObjectMgr.tempCircles.clear();
// text stuff
      ObjectMgr.tempPopupCoordinates.clear();

      ObjectMgr.tempTextCoordinates.clear();
      ObjectMgr.tempTextMarkers.clear();
      ObjectMgr.textMarkers.clear();
      ObjectMgr.tempPopupCoordinates.clear();
      ObjectMgr.tempPopupMarkers.clear();

      objectMgr.clearTemp();
      objectMgr.clear();
    });
  }

  Widget _buildMap(
    LatLng center,
  ) {
    var liveMarker = <Marker>[
      Marker(
        width: 5000,
        height: 5000,
        point: center,
        builder: (context) {
          MapState map = MapState.maybeOf(context)!;
          const double iconSize = 20;
          const double multiplier = 0.5;
          return StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error reading heading: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              directionRad = snapshot.data!.heading!;

              // if direction is null, then device does not support this sensor
              // show error message
              if (directionRad == null) {
                return const Center(
                  child: Text("Device does not have sensors !"),
                );
              }

              var pos = map.project(center);
              pos = pos.multiplyBy(map.getZoomScale(map.zoom, map.zoom)) -
                  map.getPixelOrigin();

              var r = const Distance().offset(center, arc.radiusOfArc, 180);
              var rpos = map.project(r);
              rpos = rpos.multiplyBy(map.getZoomScale(map.zoom, map.zoom)) -
                  map.getPixelOrigin();
              var realArcRadius = rpos.y - pos.y;

              return Material(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: Transform.rotate(
                      angle: (directionRad * (math.pi / 180)),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          CustomPaint(
                            size: Size(realArcRadius.toDouble() * 2,
                                realArcRadius.toDouble() * 2),
                            // size: Size(MediaQuery.of(context).size.width,
                            //     MediaQuery.of(context).size.height),
                            painter: live.ArcPainter(),
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: multiplier * iconSize,
                            child: Icon(
                              Icons.arrow_circle_up,
                              size: iconSize,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )));
            },
          );
        },
        anchorPos: AnchorPos.align(AnchorAlign.center),
      ),
    ];
    List<Marker> droneDetections = objectMgr.generateDroneMarkers();
    List<Polyline> dronePath = objectMgr.generateDronePath();

    return BlocBuilder<MenuBloc, MenuState>(builder: ((context, menuState) {
      return BlocBuilder<DrawObjectsBloc, DrawObjectsState>(
          builder: (context, drawObjectState) {
        if (drawObjectState is DrawObjectsLoaded) {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // bounds: LatLngBounds(LatLng(1.56073, 104.1147), LatLng(1.16, 103.502)),
              allowPanningOnScrollingParent: false,
              center: center,
              // maxZoom: 18.0,
              minZoom: 11.5,
              zoom: 18.0,
              // swPanBoundary: LatLng(56.6877, 11.5089),
              // nePanBoundary: LatLng(56.7378, 11.6644),
              onTap: _handleTap,
              interactiveFlags: interActiveFlags,
              plugins: [
                ScaleLayerPlugin(),
                DragMarkerPlugin(),
              ],
            ),
            nonRotatedLayers: [
              ScaleLayerPluginOption(
                lineColor: Colors.black,
                lineWidth: 2,
                textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                padding: const EdgeInsets.all(10),
              ),
            ],
            layers: [
              if (menuState is EditPolygonState)
                DragMarkerPluginOptions(
                    markers: PolyEditor(
                  addClosePathMarker: true,
                  points: objectMgr
                      .generatePolygons(
                          drawObjectState.polygons)[menuState.polygonID]
                      .points,
                  pointIcon: const Icon(Icons.crop_square, size: 23),
                  intermediateIcon:
                      const Icon(Icons.lens, size: 15, color: Colors.grey),
                  // callbackRefresh: () {
                  //   // sleep(Duration(seconds: 1));
                  //   setState(() {});
                  // },
                ).edit()),
            ],
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                  // Original
                  tileProvider: const NonCachingNetworkTileProvider(),
                  tileBuilder: tileBuilder,
                  urlTemplate: tileLayers[layerSelection],
                  subdomains: ['a', 'b', 'c'],
                ),
              ),

              // Saved Polylines
              Opacity(
                opacity: showLines ? 1.0 : 0.0,
                child: PolylineLayerWidget(
                    options: PolylineLayerOptions(
                        polylineCulling: false,
                        polylines: List<Polyline>.of(objectMgr
                            .generatePolylines(drawObjectState.polylines)))),
              ),

              // Temporary polylines to show when creating a new polyline
              PolylineLayerWidget(
                options: PolylineLayerOptions(polylines: [
                  Polyline(
                    points: ObjectMgr.tempPolylinePoints,
                    // color: const Color.fromARGB(86, 76, 175, 79),
                    borderColor: objectMgr.getGreenFill,
                    color: objectMgr.getGreenTransparent,
                    borderStrokeWidth: 2.0,
                    isDotted: false,
                  )
                ]),
              ),

              // Saved Polygons
              Opacity(
                opacity: showPolygon ? 1.0 : 0.0,
                child: PolygonLayerWidget(
                  options: PolygonLayerOptions(
                    polygons: List<Polygon>.of(objectMgr.generatePolygons(
                        drawObjectState.polygons)), //Saved Polygons
                  ),
                ),
              ),
              // Temporary polygons to show when creating a new polygon
              PolygonLayerWidget(
                options: PolygonLayerOptions(polygons: [
                  Polygon(
                    points: ObjectMgr.tempPolygonPoints,
                    color: objectMgr.getGreenTransparent,
                    borderColor: objectMgr.getGreenFill,
                    borderStrokeWidth: 2.0,
                    isDotted: false,
                  )
                ]),
              ),
              // Saved Circles
              Opacity(
                opacity: showCircle ? 1.0 : 0.0,
                child: CircleLayerWidget(
                  options: CircleLayerOptions(
                      circles:
                          objectMgr.generateCircles(drawObjectState.circles)),
                ),
              ),
              // Temporary circles to show when creating a new circle
              CircleLayerWidget(
                options: CircleLayerOptions(
                    circles: objectMgr.generateTempCircles()),
              ),

              // Temporary Markers
              MarkerLayerWidget(
                  options: MarkerLayerOptions(
                      markers: objectMgr.generateTempMarkers())),
              // Live Location Marker
              MarkerLayerWidget(
                options: MarkerLayerOptions(markers: liveMarker),
              ),

              // Last Drone Detection
              if (droneViewSelection == 0)
                PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markerCenterAnimation: const MarkerCenterAnimation(),
                    markers: droneDetections.isNotEmpty
                        ? [droneDetections.last]
                        : [],
                    popupBuilder: (BuildContext context, Marker marker) =>
                        ExamplePopup(marker, _currentLocation),
                    popupAnimation: const PopupAnimation.fade(
                        duration: Duration(milliseconds: 700)),
                    markerTapBehavior:
                        MarkerTapBehavior.togglePopupAndHideRest(),
                  ),
                ),

              // Drone Path
              if (droneViewSelection == 1)
                PolylineLayerWidget(
                  options: PolylineLayerOptions(polylines: dronePath),
                ),

              // Drone position with time
              if (droneViewSelection == 2)
                MarkerLayerWidget(
                  options: MarkerLayerOptions(
                      markers: droneDetections.isNotEmpty
                          ? [
                              droneDetections[
                                  droneIndex % droneDetections.length]
                            ]
                          : []),
                ),

              // Saved Markers
              Opacity(
                opacity: showMarkers ? 1.0 : 0.0,
                child: PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markerCenterAnimation: const MarkerCenterAnimation(),
                    markers: objectMgr.generateMarkers(drawObjectState.markers),
                    popupBuilder: (BuildContext context, Marker marker) =>
                        ExamplePopup(marker, _currentLocation),
                    popupAnimation: const PopupAnimation.fade(
                        duration: Duration(milliseconds: 700)),
                    markerTapBehavior:
                        MarkerTapBehavior.togglePopupAndHideRest(),
                  ),
                ),
              ),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      });
    }));
  }

  Widget _buildButtons(LatLng currentPos) {
    return BlocBuilder<DrawObjectsBloc, DrawObjectsState>(
      builder: ((context, drawObjectState) {
        return BlocBuilder<MenuBloc, MenuState>(
          builder: (context, menuState) {
            if (drawObjectState is DrawObjectsInitial) {
              return const CircularProgressIndicator();
            }
            if (drawObjectState is DrawObjectsLoaded) {
              if (settings == false) {
                return Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Main Menu
                        if (menuState is MainMenuState)
                          Column(
                            children: [
                              if (drawObjectState.circles.isNotEmpty ||
                                  drawObjectState.markers.isNotEmpty ||
                                  drawObjectState.polygons.isNotEmpty ||
                                  drawObjectState.polylines.isNotEmpty)
                                Column(
                                  children: [
                                    FloatingActionButton.extended(
                                        onPressed: () {
                                          _reset();
                                          drawObjectState.circles.clear();
                                          drawObjectState.markers.clear();
                                          drawObjectState.polygons.clear();
                                          drawObjectState.polylines.clear();
                                        },
                                        label: const Icon(
                                            Icons.delete_forever_rounded)),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  context
                                      .read<MenuBloc>()
                                      .add(PolylineMenuEvent());
                                },
                                label: const Icon(Icons.timeline),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  context
                                      .read<MenuBloc>()
                                      .add(PolygonMenuEvent());
                                },
                                label: const Icon(Icons.crop_square_sharp),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  context
                                      .read<MenuBloc>()
                                      .add(MarkerMenuEvent());
                                },
                                label: const Icon(Icons.text_fields_sharp),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  context
                                      .read<MenuBloc>()
                                      .add(CircleMenuEvent());
                                },
                                label: const Icon(Icons.circle_outlined),
                              ),
                              const SizedBox(height: 8),
                              const compass.BuildCompass(),
                            ],
                          ),
                        // Polyline Menu
                        if (menuState is PolylineMenuState)
                          Column(
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    ObjectMgr.polylinePoints.add([]);
                                    ObjectMgr.polylinePoints[
                                            drawObjectState.polylines.length] =
                                        ObjectMgr.tempPolylinePoints.toList();
                                    if (ObjectMgr
                                            .polylinePoints[drawObjectState
                                                .polylines.length]
                                            .length >
                                        1) {
                                      var p = objectMgr.createPolyline(
                                          ObjectMgr.polylinePoints[
                                              drawObjectState.polylines.length],
                                          1,
                                          objectMgr.getRedFill,
                                          2,
                                          objectMgr.getRedFill,
                                          false);
                                      ObjectMgr.tempPolylinePoints.clear();

                                      context
                                          .read<DrawObjectsBloc>()
                                          .add(AddPolylineEvent(polylines: p));
                                    }

                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Draw Polyline",
                                label: const Icon(Icons.check),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () =>
                                    setState(() => showLines = !showLines),
                                heroTag: "Toggle Polyline Visibility",
                                label: Icon(showLines
                                    ? Icons.toggle_off
                                    : Icons.toggle_on),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    ObjectMgr.tempPolylinePoints.clear();
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Cancel",
                                label: const Icon(Icons.cancel_outlined),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        // Polygon Menu
                        if (menuState is PolygonMenuState)
                          Column(
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    ObjectMgr.polygonPoints.add([]);
                                    ObjectMgr.polygonPoints[
                                            drawObjectState.polygons.length] =
                                        ObjectMgr.tempPolygonPoints.toList();
                                    if (ObjectMgr
                                            .polygonPoints[
                                                drawObjectState.polygons.length]
                                            .length >
                                        1) {
                                      var p = objectMgr.createPolygon(
                                          ObjectMgr.polygonPoints[
                                              drawObjectState.polygons.length],
                                          2,
                                          false);
                                      ObjectMgr.tempPolygonPoints.clear();

                                      context
                                          .read<DrawObjectsBloc>()
                                          .add(AddPolygonEvent(polygons: p));
                                    }

                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Draw Polygon",
                                label: const Icon(Icons.check),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () =>
                                    setState(() => showPolygon = !showPolygon),
                                heroTag: "Toggle Polygon Visibility",
                                label: Icon(showPolygon
                                    ? Icons.toggle_off
                                    : Icons.toggle_on),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    ObjectMgr.tempPolylinePoints.clear();
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Cancel",
                                label: const Icon(Icons.cancel_outlined),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        // Marker Menu
                        if (menuState is MarkerMenuState)
                          Column(
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    for (var i = 0;
                                        i <
                                            ObjectMgr
                                                .tempTextCoordinates.length;
                                        i++) {
                                      var tm = objectMgr.createMarker(
                                          ObjectMgr.tempTextCoordinates[i],
                                          80,
                                          80,
                                          true,
                                          MarkersMgr.getUserInput);
                                      context
                                          .read<DrawObjectsBloc>()
                                          .add(AddMarkerEvent(markers: tm));
                                    }
                                    ObjectMgr.tempTextCoordinates.clear();
                                    objectMgr.clearTemp();
                                    MarkersMgr.setUserInput("");
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Draw Marker",
                                label: const Icon(Icons.check),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () =>
                                    setState(() => showMarkers = !showMarkers),
                                heroTag: "Toggle Text Markers Visibility",
                                label: Icon(showMarkers
                                    ? Icons.toggle_off
                                    : Icons.toggle_on),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    ObjectMgr.tempTextCoordinates.clear();
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Cancel",
                                label: const Icon(Icons.cancel_outlined),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),

                        // Circle Menu
                        if (menuState is CircleMenuState)
                          Column(
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    if (objectMgr.getTempCircles().isNotEmpty) {
                                      var c = objectMgr.createCircle(
                                          objectMgr.getTempCircles()[0].point,
                                          objectMgr.getRedTransparent,
                                          objectMgr.getRedFill,
                                          objectMgr
                                              .getTempCircles()[0]
                                              .borderStrokeWidth,
                                          objectMgr
                                              .getTempCircles()[0]
                                              .useRadiusInMeter,
                                          objectMgr.getTempCircles()[0].radius);
                                      objectMgr.clearTemp();
                                      context
                                          .read<DrawObjectsBloc>()
                                          .add(AddCircleEvent(circles: c));
                                    }
                                    CirclesMgr.tempRadius =
                                        CirclesMgr.defaultRadius;
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Draw Circle",
                                label: const Icon(Icons.check),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () =>
                                    setState(() => showCircle = !showCircle),
                                heroTag: "Toggle Circle Visibility",
                                label: Icon(showCircle
                                    ? Icons.toggle_off
                                    : Icons.toggle_on),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    if (objectMgr.getTempCircles().isNotEmpty) {
                                      objectMgr.clearTempCircles();
                                    }
                                  });
                                  context.read<MenuBloc>().add(MainMenuEvent());
                                },
                                heroTag: "Cancel",
                                label: const Icon(Icons.cancel_outlined),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),

                        if (menuState is EditCircleState)
                          Column(
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    context.read<DrawObjectsBloc>().add(
                                        DeleteCircleEvent(
                                            position: menuState.circleID));
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Delete Circle",
                                label: const Icon(Icons.delete),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    objectMgr
                                        .toggleCircleColor(menuState.circleID);
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Save Circle Changes",
                                label: const Icon(Icons.check),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),

                        if (menuState is EditPolygonState)
                          Column(
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    context.read<DrawObjectsBloc>().add(
                                        DeletePolygonEvent(
                                            position: menuState.polygonID));
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Delete Polygon",
                                label: const Icon(Icons.delete),
                              ),
                              const SizedBox(height: 8),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  setState(() {
                                    objectMgr.togglePolygonColor(
                                        menuState.polygonID);
                                    context
                                        .read<MenuBloc>()
                                        .add(MainMenuEvent());
                                  });
                                },
                                heroTag: "Save Polygon Changes",
                                label: const Icon(Icons.check),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),

                        if ((menuState is CircleMenuState &&
                                objectMgr.getTempCircles().isNotEmpty) ||
                            menuState is EditCircleState)
                          Row(
                            children: [
                              SizedBox(
                                width: 0.8 * MediaQuery.of(context).size.width,
                                child: Slider(
                                  value: menuState is EditCircleState
                                      ? objectMgr
                                          .getCircles()[menuState.circleID]
                                          .radius
                                      : CirclesMgr.tempRadius,
                                  max: 500,
                                  label:
                                      CirclesMgr.tempRadius.round().toString(),
                                  onChanged: (double value) {
                                    setState(
                                      () {
                                        CirclesMgr.tempRadius = value;
                                        if (menuState is CircleMenuState) {
                                          objectMgr.createTempCircle(
                                              objectMgr
                                                  .getTempCircles()[0]
                                                  .point,
                                              objectMgr
                                                  .getTempCircles()[0]
                                                  .borderStrokeWidth,
                                              objectMgr
                                                  .getTempCircles()[0]
                                                  .useRadiusInMeter,
                                              value);
                                          // objectCreator.newTempCircle(
                                          //     GlobalData.tempPoint, GlobalData.tempRadius);
                                        } else if (menuState
                                            is EditCircleState) {
                                          objectMgr
                                              .getCircles()[menuState.circleID]
                                              .radius = value;
                                          // objectCreator.editCircle(
                                          // GlobalData.circleID, GlobalData.tempRadius);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              Text(
                                  "${CirclesMgr.tempRadius.toStringAsFixed(2)}m"),
                            ],
                          ),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 0.8 * MediaQuery.of(context).size.width,
                              child: Slider(
                                value: arc.radiusOfArc,
                                max: 1000,
                                label: null,
                                onChanged: (double value) {
                                  setState(
                                    () {
                                      arc.radiusOfArc = value;
                                    },
                                  );
                                },
                              ),
                            ),
                            Text("${arc.radiusOfArc.toStringAsFixed(2)}m"),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 0.8 * MediaQuery.of(context).size.width,
                              child: Slider(
                                value: arc.spanOfArc,
                                max: 360,
                                label: null,
                                onChanged: (double value) {
                                  setState(
                                    () {
                                      arc.spanOfArc = value;
                                    },
                                  );
                                },
                              ),
                            ),

                            // const Spacer(),
                            Text("${arc.spanOfArc.toStringAsFixed(2)}°"),
                          ],
                        ),
                      ],
                    ),
                    if (menuState is MarkerMenuState)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              // fillColor: Colors.transparent,
                              filled: false,
                              border: OutlineInputBorder(),
                              labelText: "Marker's Text",
                              isDense: true,
                            ),
                            onChanged: (value) => setState(() {
                              MarkersMgr.setUserInput(value);
                              objectMgr.clearTempMarkers();
                              for (var i = 0;
                                  i < ObjectMgr.tempTextCoordinates.length;
                                  i++) {
                                objectMgr.createTempMarker(
                                    ObjectMgr.tempTextCoordinates[i],
                                    80,
                                    80,
                                    true,
                                    MarkersMgr.getUserInput);
                              }
                            }),
                          ),
                        ],
                      ),
                  ],
                );
              }
            } else {
              return const Text("Something went wrong");
            }
          },
        );
      }),
    );
  }
}
