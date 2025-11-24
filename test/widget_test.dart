// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmu_tfg/utils/geo_point_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Convierte mapa válido en GeoPoint', () {
    final result = parseDynamicToGeoPoint({'lat': 40.4, 'lng': -3.7});

    expect(result, isA<GeoPoint>());
    expect(result?.latitude, 40.4);
    expect(result?.longitude, -3.7);
  });

  test('Devuelve null con datos incompletos', () {
    final result = parseDynamicToGeoPoint({'lat': 40.4});

    expect(result, isNull);
  });
}
