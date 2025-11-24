import 'dart:convert';

import 'package:emmu_tfg/location_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlaceAutocompleteService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        if (request.url.path.contains('autocomplete')) {
          final body = {
            'status': 'OK',
            'predictions': [
              {
                'place_id': 'place123',
                'description': 'Madrid, España',
              }
            ],
          };
          return http.Response(jsonEncode(body), 200);
        }

        if (request.url.path.contains('details')) {
          final body = {
            'status': 'OK',
            'result': {
              'formatted_address': 'Plaza Mayor, Madrid',
              'geometry': {
                'location': {'lat': 40.4168, 'lng': -3.7038}
              },
            }
          };
          return http.Response(jsonEncode(body), 200);
        }

        return http.Response('Not Found', 404);
      });
    });

    testWidgets('flujo completo de autocompletado', (tester) async {
      const query = 'Mad';
      final sessionToken = PlaceAutocompleteService.newSessionToken();

      final predictions = await PlaceAutocompleteService.fetchPredictions(
        query,
        sessionToken: sessionToken,
        client: mockClient,
      );

      expect(predictions, hasLength(1));
      expect(predictions.first.placeId, 'place123');
      expect(predictions.first.description, contains('Madrid'));

      final details = await PlaceAutocompleteService.fetchPlaceDetails(
        predictions.first.placeId,
        sessionToken: sessionToken,
        client: mockClient,
      );

      expect(details.description, contains('Plaza Mayor'));
      expect(details.latitude, closeTo(40.4168, 0.0001));
      expect(details.longitude, closeTo(-3.7038, 0.0001));
    });
  });
}

