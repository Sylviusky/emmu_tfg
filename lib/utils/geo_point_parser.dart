import 'package:cloud_firestore/cloud_firestore.dart';

GeoPoint? parseDynamicToGeoPoint(dynamic value) {
  if (value == null) return null;
  if (value is GeoPoint) return value;

  if (value is Map<String, dynamic>) {
    final possibleLatKeys = ['latitude', 'lat', '_latitude'];
    final possibleLngKeys = ['longitude', 'lng', '_longitude'];

    double? lat;
    double? lng;

    for (final key in possibleLatKeys) {
      final candidate = value[key];
      if (candidate is num) {
        lat = candidate.toDouble();
        break;
      }
      if (candidate is String) {
        lat = double.tryParse(candidate);
        if (lat != null) break;
      }
    }

    for (final key in possibleLngKeys) {
      final candidate = value[key];
      if (candidate is num) {
        lng = candidate.toDouble();
        break;
      }
      if (candidate is String) {
        lng = double.tryParse(candidate);
        if (lng != null) break;
      }
    }

    if (lat != null && lng != null) {
      return GeoPoint(lat, lng);
    }
  }

  if (value is List && value.length >= 2) {
    final lat = _parseDouble(value[0]);
    final lng = _parseDouble(value[1]);
    if (lat != null && lng != null) {
      return GeoPoint(lat, lng);
    }
  }

  if (value is String) {
    final cleaned = value.replaceAll(RegExp('[\\[\\](){}]'), '');
    final parts = cleaned.split(RegExp('[,;\\s]+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      final lat = double.tryParse(parts[0]);
      final lng = double.tryParse(parts[1]);
      if (lat != null && lng != null) {
        return GeoPoint(lat, lng);
      }
    }
  }

  return null;
}

double? _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

