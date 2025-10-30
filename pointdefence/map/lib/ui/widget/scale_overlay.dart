import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget overlay qui affiche une échelle linéaire en bas à gauche de la carte
class ScaleOverlay extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;

  const ScaleOverlay({
    Key? key,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.maybeOf(context);
    if (camera == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: _buildScale(context, camera),
      ),
    );
  }

  Widget _buildScale(BuildContext context, MapCamera camera) {
    final zoom = camera.zoom;
    final bounds = camera.visibleBounds;
    
    // Calculer la distance horizontale en mètres pour déterminer l'échelle
    final centerLat = bounds.center.latitude;
    final distance = const Distance();
    final metersPerPixel = distance.distance(
      LatLng(centerLat, bounds.west),
      LatLng(centerLat, bounds.east),
    ) / camera.size.width;
    
    // Choisir une longueur d'échelle appropriée (en pixels)
    double scaleLengthPixels = 100;
    double scaleMeters = scaleLengthPixels * metersPerPixel;
    
    // Arrondir à une valeur "ronde" (10, 50, 100, 500, 1000, etc.)
    double roundedScale = _roundScale(scaleMeters);
    double adjustedPixels = roundedScale / metersPerPixel;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 2,
              width: adjustedPixels,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Container(
              height: 2,
              width: 1,
              color: textColor,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _formatDistance(roundedScale),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _roundScale(double meters) {
    if (meters < 10) {
      return 1;
    } else if (meters < 50) {
      return ((meters / 10).round() * 10).toDouble();
    } else if (meters < 500) {
      return ((meters / 50).round() * 50).toDouble();
    } else if (meters < 5000) {
      return ((meters / 500).round() * 500).toDouble();
    } else {
      return ((meters / 1000).round() * 1000).toDouble();
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}

