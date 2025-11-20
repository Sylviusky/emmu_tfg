import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'google_maps_api_key.dart';

class SelectedLocation {
  final double latitude;
  final double longitude;
  final String description;

  SelectedLocation({
    required this.latitude,
    required this.longitude,
    required this.description,
  });
}

class PlacePrediction {
  final String placeId;
  final String description;

  PlacePrediction({required this.placeId, required this.description});

  factory PlacePrediction.fromJson(Map<String, dynamic> json) =>
      PlacePrediction(
        placeId: json['place_id'] as String,
        description: json['description'] as String? ?? '',
      );
}

class PlaceDetails {
  final double latitude;
  final double longitude;
  final String description;

  PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.description,
  });
}

class PlaceAutocompleteService {
  static const _authority = 'maps.googleapis.com';
  static const _autocompletePath = '/maps/api/place/autocomplete/json';
  static const _detailsPath = '/maps/api/place/details/json';
  static const _uuid = Uuid();

  static String newSessionToken() => _uuid.v4();

  static Map<String, String> _baseParams({
    required String sessionToken,
    String language = 'es',
    Map<String, String>? extra,
  }) {
    return {
      'language': language,
      'sessiontoken': sessionToken,
      'key': googleMapsApiKey,
      ...?extra,
    };
  }

  static Future<List<PlacePrediction>> fetchPredictions(
    String input, {
    required String sessionToken,
    String language = 'es',
    String? types,
    String? components,
    http.Client? client,
  }) async {
    if (!isGoogleMapsApiKeyConfigured) {
      throw Exception(
          'Configura tu API Key de Google Maps en google_maps_api_key.dart');
    }

    if (input.trim().length < 3) return [];

    final uri = Uri.https(
      _authority,
      _autocompletePath,
      _baseParams(
        sessionToken: sessionToken,
        language: language,
        extra: {
          'input': input,
          if (types != null) 'types': types,
          if (components != null) 'components': components,
        },
      ),
    );

    final http.Client httpClient = client ?? http.Client();
    http.Response response;
    try {
      response = await httpClient.get(uri);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'ERROR';

    if (status == 'OK') {
      return (data['predictions'] as List<dynamic>)
          .map((e) => PlacePrediction.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final message =
        data['error_message']?.toString() ?? 'Error al obtener sugerencias ($status)';
    throw Exception(message);
  }

  static Future<PlaceDetails> fetchPlaceDetails(
    String placeId, {
    required String sessionToken,
    String language = 'es',
    http.Client? client,
  }) async {
    if (!isGoogleMapsApiKeyConfigured) {
      throw Exception(
          'Configura tu API Key de Google Maps en google_maps_api_key.dart');
    }

    final uri = Uri.https(
      _authority,
      _detailsPath,
      _baseParams(
        sessionToken: sessionToken,
        language: language,
        extra: {
          'place_id': placeId,
          'fields': 'geometry,formatted_address',
        },
      ),
    );

    final http.Client httpClient = client ?? http.Client();
    http.Response response;
    try {
      response = await httpClient.get(uri);
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'ERROR';
    if (status != 'OK') {
      final message =
          data['error_message']?.toString() ?? 'Error al obtener los detalles ($status)';
      throw Exception(message);
    }

    final result = data['result'] as Map<String, dynamic>;
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;

    if (location == null) {
      throw Exception('La ubicación seleccionada no tiene coordenadas válidas.');
    }

    return PlaceDetails(
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      description: result['formatted_address']?.toString() ?? '',
    );
  }
}

class LocationPicker {
  static Future<SelectedLocation?> showAutocomplete({
    required BuildContext context,
    String? componentsFilter,
  }) async {
    final TextEditingController controller = TextEditingController();
    final navigator = Navigator.of(context);
    SelectedLocation? selectedLocation;
    List<PlacePrediction> predictions = [];
    bool isLoading = false;
    String? error;
    String sessionToken = PlaceAutocompleteService.newSessionToken();

    Future<void> fetchPredictions(
      String input,
      void Function(void Function()) setState,
    ) async {
      if (input.isEmpty) {
        setState(() {
          predictions = [];
          error = null;
        });
        return;
      }

      setState(() {
        isLoading = true;
        error = null;
      });

      try {
        final results = await PlaceAutocompleteService.fetchPredictions(
          input,
          sessionToken: sessionToken,
          components: componentsFilter,
          types: null, // No limitar por tipos para búsqueda flexible
        );
        setState(() {
          predictions = results;
          error = null;
        });
      } catch (e) {
        setState(() {
          error = e.toString();
          predictions = [];
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    Future<void> selectPrediction(
      PlacePrediction prediction,
      void Function(void Function()) setState,
    ) async {
      try {
        final details = await PlaceAutocompleteService.fetchPlaceDetails(
          prediction.placeId,
          sessionToken: sessionToken,
        );
        if (!navigator.mounted) return;
        selectedLocation = SelectedLocation(
          latitude: details.latitude,
          longitude: details.longitude,
          description: details.description.isNotEmpty
              ? details.description
              : prediction.description,
        );
        navigator.pop();
      } catch (e) {
        setState(() {
          error = e.toString();
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Busca una dirección'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Empieza a escribir...',
                    ),
                    onChanged: (value) => fetchPredictions(value, setState),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading) const LinearProgressIndicator(color: Colors.red),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: predictions.isEmpty
                        ? const Center(
                            child: Text('Sin resultados'),
                          )
                        : ListView.builder(
                            itemCount: predictions.length,
                            itemBuilder: (context, index) {
                              final prediction = predictions[index];
                              return ListTile(
                                leading:
                                    const Icon(Icons.place, color: Colors.red),
                                title: Text(prediction.description),
                                onTap: () =>
                                    selectPrediction(prediction, setState),
                              );
                            },
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );

    return selectedLocation;
  }
}

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<SelectedLocation>? onLocationSelected;
  final String? country;
  final String? label;
  final String? helperText;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    this.onLocationSelected,
    this.country,
    this.label,
    this.helperText,
  });

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  late String _sessionToken;
  bool _isFetchingDetails = false;

  @override
  void initState() {
    super.initState();
    _sessionToken = PlaceAutocompleteService.newSessionToken();
  }

  void _resetSessionToken() {
    _sessionToken = PlaceAutocompleteService.newSessionToken();
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<PlacePrediction>(
          controller: widget.controller,
          hideOnEmpty: true,
          debounceDuration: const Duration(milliseconds: 300),
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label ?? 'Ubicación',
                helperText: widget.helperText ??
                    'Escribe una dirección o lugar para ver sugerencias',
                suffixIcon: _isFetchingDetails
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.place, color: Colors.red),
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            try {
              return await PlaceAutocompleteService.fetchPredictions(
                pattern,
                sessionToken: _sessionToken,
                components:
                    widget.country != null ? 'country:${widget.country}' : null,
                types: null, // No limitar por tipos para búsqueda flexible (direcciones, negocios, lugares, etc.)
              );
            } catch (e) {
              if (!mounted) return [];
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return [];
            }
          },
          itemBuilder: (context, prediction) {
            return ListTile(
              leading: const Icon(Icons.place, color: Colors.red),
              title: Text(prediction.description),
            );
          },
          onSelected: (prediction) async {
            setState(() => _isFetchingDetails = true);
            try {
              final details = await PlaceAutocompleteService.fetchPlaceDetails(
                prediction.placeId,
                sessionToken: _sessionToken,
              );
              if (!mounted) return;
              widget.controller.text = details.description;
              widget.onLocationSelected?.call(
                SelectedLocation(
                  latitude: details.latitude,
                  longitude: details.longitude,
                  description: details.description,
                ),
              );
            } catch (e) {
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              if (mounted) {
                setState(() => _isFetchingDetails = false);
              }
              _resetSessionToken();
            }
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('No se encontraron coincidencias'),
          ),
          loadingBuilder: (context) =>
              const LinearProgressIndicator(color: Colors.red),
        ),
      ],
    );
  }
}
