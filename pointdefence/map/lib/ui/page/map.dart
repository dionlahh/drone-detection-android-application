// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map/blocs/menu_bloc/menu_bloc.dart';
import 'package:map/blocs/object_bloc/draw_objects_bloc.dart';
import 'package:map/circles_mgr.dart';
import 'package:map/markers_mgr.dart';
import 'package:map/ui/common/droneCalc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../widget/example_popup.dart';
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
import '../widget/grid_overlay.dart';
import '../widget/scale_overlay.dart';
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
    // OpenStreetMap - public and reliable
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    // CartoDB Dark Matter
    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    // CartoDB Voyager
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    // Stamen Terrain
    'https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.png',
  ];
  double directionRad = 0;
  int droneViewSelection = 0;
  int droneIndex = 0;

// Handles grids
  // tileBuilder removed for flutter_map 8 migration

  // Live Location
  LocationData? _currentLocation;
  late final MapController _mapController;
  double _currentZoom = 18.0;
  bool _liveUpdate = true;
  bool _permission = false;
  String? _serviceError = '';
  var interActiveFlags = InteractiveFlag.all;
  final Location _locationService = Location();
  final ImagePicker _imagePicker = ImagePicker();
  // Poly editor removed during flutter_map 8 migration

  @override
  void initState() {
    super.initState();
    // Safely fire-and-forget native call; ignore if plugin not registered
    // (e.g., when running as a module without host implementation)
    // ignore: unawaited_futures
    NativeAndroidMethodChannel().getCameraFOV().catchError((_) {});
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
    // Ensure runtime location permission is granted before starting updates
    final phStatus = await ph.Permission.location.request();
    if (!phStatus.isGranted) {
      _permission = false;
      return;
    }

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
                if (_liveUpdate && _currentLocation != null) {
                  _mapController.move(
                    LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                    _currentZoom,
                  );
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
                      tooltip: _liveUpdate ? 'Désactiver suivi' : 'Activer suivi',
                      onPressed: () {
                        debugPrint('Live update button pressed: $_liveUpdate -> ${!_liveUpdate}');
                        setState(() {
                          _liveUpdate = !_liveUpdate;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_liveUpdate 
                                ? 'Suivi localisation activé' 
                                : 'Suivi localisation désactivé'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icon(_liveUpdate
                          ? Icons.location_disabled
                          : Icons.location_searching)),
                  IconButton(
                      tooltip: 'Vue drone (${droneViewSelection + 1}/3)',
                      onPressed: () {
                        final newSelection = (droneViewSelection + 1) % 3;
                        debugPrint('Drone view button pressed: $droneViewSelection -> $newSelection');
                        setState(() {
                          droneViewSelection = newSelection;
                        });
                        final modeNames = ['Dernière détection', 'Trajectoire', 'Animation'];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Vue drone: ${modeNames[newSelection]}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icon(DroneIcon.kindpng_536873)),
                  IconButton(
                    tooltip: grid ? 'Masquer grille' : 'Afficher grille',
                    onPressed: () {
                      debugPrint('Grid button pressed: $grid -> ${!grid}');
                      setState(() {
                        grid = !grid;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(grid ? 'Grille affichée' : 'Grille masquée'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(grid ? Icons.grid_off : Icons.grid_on),
                  ),
                  IconButton(
                      tooltip: 'Changer carte (${layerSelection + 1}/${tileLayers.length})',
                      onPressed: () {
                        final newSelection = (layerSelection + 1) % tileLayers.length;
                        debugPrint('Layer button pressed: $layerSelection -> $newSelection');
                        setState(() {
                          layerSelection = newSelection;
                        });
                        final layerNames = ['OpenStreetMap', 'CartoDB Dark', 'CartoDB Voyager', 'Stamen Terrain'];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Carte: ${layerNames[newSelection]}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.layers)),
                  IconButton(
                      tooltip: 'Ouvrir la détection de drones',
                      onPressed: () async {
                        debugPrint('🎯 Bouton caméra cliqué');
                        
                        final result = await NativeAndroidMethodChannel().getNativeBuild();
                        
                        if (!mounted) return;
                        
                        if (result == 'APP_NOT_INSTALLED') {
                          // L'application de détection n'est pas installée
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Application non installée'),
                              content: const Text(
                                'L\'application de détection de drones n\'est pas installée sur cet appareil.\n\n'
                                'Veuillez installer l\'application "Point Defence" depuis le projet Android natif.'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else if (result == 'ERROR') {
                          // Erreur lors du lancement
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erreur lors de l\'ouverture de la caméra'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (result == 'APP_LAUNCHED') {
                          // Succès - l'app native s'est ouverte
                          debugPrint('✅ Application de détection lancée avec succès');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Application de détection lancée'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.camera)),
                  IconButton(
                      tooltip: settings ? 'Masquer paramètres' : 'Afficher paramètres',
                      onPressed: () {
                        debugPrint('Settings button pressed: $settings -> ${!settings}');
                        setState(() {
                          settings = !settings;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(settings ? 'Paramètres affichés' : 'Paramètres masqués'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icon(settings ? Icons.settings : Icons.settings_outlined)),
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

  void _handleTap(dynamic tapPosition, LatLng latlng) {
    setState(() {
      var t = tap.HandleTap(latlng, objectMgr);
      t.handleTap();
    });
  }

  Future<void> _takePicture() async {
    try {
      // Demander la permission caméra
      final cameraStatus = await ph.Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission caméra nécessaire pour prendre une photo'),
            ),
          );
        }
        return;
      }

      // Prendre une photo
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo prise: ${photo.path}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // Ici vous pouvez traiter l'image : la sauvegarder, l'envoyer, etc.
        // Par exemple : await photo.saveTo('path/to/save');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la prise de photo: $e'),
          ),
        );
      }
    }
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
        width: 40,
        height: 40,
        point: center,
        alignment: Alignment.center,
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final heading = snapshot.data!.heading ?? 0.0;
            return Transform.rotate(
              angle: heading * (math.pi / 180),
              child: const Icon(Icons.navigation, color: Colors.blue),
            );
          },
        ),
      ),
    ];
    List<Marker> droneDetections = objectMgr.generateDroneMarkers();
    List<Polyline> dronePath = objectMgr.generateDronePath();

    return BlocBuilder<MenuBloc, MenuState>(builder: ((context, menuState) {
      return BlocBuilder<DrawObjectsBloc, DrawObjectsState>(
          builder: (context, drawObjectState) {
        if (drawObjectState is DrawObjectsLoaded) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  // bounds: LatLngBounds(LatLng(1.56073, 104.1147), LatLng(1.16, 103.502)),
                  initialCenter: center,
                  // maxZoom: 18.0,
                  minZoom: 11.5,
                  initialZoom: _currentZoom,
                  // swPanBoundary: LatLng(56.6877, 11.5089),
                  // nePanBoundary: LatLng(56.7378, 11.6644),
                  onTap: _handleTap,
                  onMapEvent: (MapEvent mapEvent) {
                    if (mapEvent is MapEventMove) {
                      setState(() {
                        _currentZoom = mapEvent.camera.zoom;
                      });
                    }
                  },
                  // plugins removed during migration
                ),
                // scale and edit layers removed during migration
                // nonRotatedLayers: [...]
                // layers: [...]
                children: [
              TileLayer(
                urlTemplate: tileLayers[layerSelection],
                subdomains: layerSelection == 0 
                    ? const <String>[]  // OpenStreetMap doesn't use subdomains
                    : const ['a', 'b', 'c'],
              ),

              // Saved Polylines
              if (showLines)
                PolylineLayer(
                  polylines: objectMgr
                      .generatePolylines(drawObjectState.polylines)
                      .where((pl) => pl.points.isNotEmpty)
                      .toList(),
                ),

              // Temporary polylines to show when creating a new polyline
              if (ObjectMgr.tempPolylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: ObjectMgr.tempPolylinePoints,
                      borderColor: objectMgr.getGreenFill,
                      color: objectMgr.getGreenTransparent,
                      borderStrokeWidth: 2.0,
                      strokeWidth: 3.0,
                    )
                  ],
                ),

              // Saved Polygons
              if (showPolygon)
                PolygonLayer(
                  polygons: objectMgr
                      .generatePolygons(drawObjectState.polygons)
                      .where((pg) => pg.points.isNotEmpty)
                      .toList(),
                ),
              // Temporary polygons to show when creating a new polygon
              if (ObjectMgr.tempPolygonPoints.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: ObjectMgr.tempPolygonPoints,
                      color: objectMgr.getGreenTransparent,
                      borderColor: objectMgr.getGreenFill,
                      borderStrokeWidth: 2.0,
                    )
                  ],
                ),
              // Saved Circles
              if (showCircle)
                CircleLayer(
                  circles:
                      objectMgr.generateCircles(drawObjectState.circles),
                ),
              // Temporary circles to show when creating a new circle
              CircleLayer(
                circles: objectMgr.generateTempCircles(),
              ),

              // Temporary Markers
              MarkerLayer(markers: objectMgr.generateTempMarkers()),
              // Live Location Marker
              MarkerLayer(markers: liveMarker),

              // Last Drone Detection
              if (droneViewSelection == 0)
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markerCenterAnimation: const MarkerCenterAnimation(),
                    markers:
                        droneDetections.isNotEmpty ? [droneDetections.last] : [],
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) =>
                          ExamplePopup(marker, _currentLocation),
                    ),
                    // popup animation removed for compatibility
                    markerTapBehavior:
                        MarkerTapBehavior.togglePopupAndHideRest(),
                  ),
                ),

              // Drone Path
              if (droneViewSelection == 1)
                PolylineLayer(polylines: dronePath),

              // Drone position with time
              if (droneViewSelection == 2)
                MarkerLayer(
                  markers: droneDetections.isNotEmpty
                      ? [
                          droneDetections[
                              droneIndex % droneDetections.length]
                        ]
                      : [],
                ),

              // Saved Markers
              if (showMarkers)
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markerCenterAnimation: const MarkerCenterAnimation(),
                    markers: objectMgr.generateMarkers(drawObjectState.markers),
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) =>
                          ExamplePopup(marker, _currentLocation),
                    ),
                    // popup animation removed for compatibility
                    markerTapBehavior:
                        MarkerTapBehavior.togglePopupAndHideRest(),
                  ),
                ),
            ],
              ),
              // Grid overlay
              Builder(
                builder: (context) {
                  return Positioned.fill(
                    child: GridOverlay(
                      showGrid: grid,
                      gridColor: Colors.white,
                      gridOpacity: 0.3,
                    ),
                  );
                },
              ),
              // Scale overlay
              ScaleOverlay(
                backgroundColor: Colors.white,
                textColor: Colors.black87,
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
