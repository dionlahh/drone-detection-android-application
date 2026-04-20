import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget overlay qui dessine une grille de coordonnées sur la carte
class GridOverlay extends StatelessWidget {
  final bool showGrid;
  final Color gridColor;
  final double gridOpacity;

  const GridOverlay({
    Key? key,
    required this.showGrid,
    this.gridColor = Colors.white,
    this.gridOpacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showGrid) {
      return const SizedBox.shrink();
    }

    final camera = MapCamera.maybeOf(context);
    if (camera == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: GridPainter(
        camera: camera,
        gridColor: gridColor,
        gridOpacity: gridOpacity,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final MapCamera camera;
  final Color gridColor;
  final double gridOpacity;

  GridPainter({
    required this.camera,
    required this.gridColor,
    required this.gridOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()
      ..color = gridColor.withOpacity(gridOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Obtenir les bounds de la carte visible
    final bounds = camera.visibleBounds;
    final mapSize = camera.size;
    final center = camera.center;
    final zoom = camera.zoom;
    
    // Calculer l'intervalle de grille en degrés (ajuster selon le niveau de zoom)
    double interval;
    
    if (zoom < 12) {
      interval = 0.01; // ~1.1 km
    } else if (zoom < 14) {
      interval = 0.005; // ~550 m
    } else if (zoom < 16) {
      interval = 0.001; // ~110 m
    } else {
      interval = 0.0005; // ~55 m
    }

    // Fonction pour convertir LatLng en coordonnées d'écran (projection Web Mercator)
    Offset latLngToPoint(LatLng point) {
      // Projection Web Mercator utilisée par les cartes en ligne (tuiles 256x256)
      final tilesPerZoom = 1 << zoom.toInt();
      final pixelsPerTile = 256.0;
      
      // Projection Mercator pour la longitude (simple linéaire)
      final x = (point.longitude + 180.0) / 360.0 * tilesPerZoom * pixelsPerTile;
      
      // Projection Mercator pour la latitude (formule standard)
      final latRad = point.latitude * math.pi / 180.0;
      final y = (1.0 - math.log(math.tan(math.pi / 4.0 + latRad / 2.0)) / math.pi) / 2.0 * tilesPerZoom * pixelsPerTile;
      
      // Convertir en coordonnées relatives au centre
      final centerX = (center.longitude + 180.0) / 360.0 * tilesPerZoom * pixelsPerTile;
      final centerLatRad = center.latitude * math.pi / 180.0;
      final centerY = (1.0 - math.log(math.tan(math.pi / 4.0 + centerLatRad / 2.0)) / math.pi) / 2.0 * tilesPerZoom * pixelsPerTile;
      
      // Coordonnées relatives à la vue (offset par rapport au centre)
      final screenX = mapSize.width / 2 + (x - centerX);
      final screenY = mapSize.height / 2 + (y - centerY);
      
      return Offset(screenX, screenY);
    }

    // Dessiner les lignes verticales (longitude)
    double startLng = (bounds.west / interval).floor() * interval;
    for (double lng = startLng; lng <= bounds.east; lng += interval) {
      try {
        final startPoint = latLngToPoint(LatLng(bounds.north, lng));
        final endPoint = latLngToPoint(LatLng(bounds.south, lng));
        
        // Clamp les points aux limites de la carte
        final y1 = startPoint.dy.clamp(0.0, mapSize.height);
        final y2 = endPoint.dy.clamp(0.0, mapSize.height);
        final x = startPoint.dx.clamp(0.0, mapSize.width);
        
        if (x >= 0 && x <= mapSize.width) {
          canvas.drawLine(
            Offset(x, y1),
            Offset(x, y2),
            paint,
          );
        }
      } catch (_) {
        // Ignore les erreurs de conversion si hors bounds
        continue;
      }
    }

    // Dessiner les lignes horizontales (latitude)
    double startLat = (bounds.south / interval).floor() * interval;
    for (double lat = startLat; lat <= bounds.north; lat += interval) {
      try {
        final startPoint = latLngToPoint(LatLng(lat, bounds.west));
        final endPoint = latLngToPoint(LatLng(lat, bounds.east));
        
        // Clamp les points aux limites de la carte
        final x1 = startPoint.dx.clamp(0.0, mapSize.width);
        final x2 = endPoint.dx.clamp(0.0, mapSize.width);
        final y = startPoint.dy.clamp(0.0, mapSize.height);
        
        if (y >= 0 && y <= mapSize.height) {
          canvas.drawLine(
            Offset(x1, y),
            Offset(x2, y),
            paint,
          );
        }
      } catch (_) {
        // Ignore les erreurs de conversion si hors bounds
        continue;
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.camera.zoom != camera.zoom ||
        oldDelegate.camera.center != camera.center ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.gridOpacity != gridOpacity;
  }
}
