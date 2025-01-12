import 'dart:convert';
import 'package:http/http.dart' as http;

class MapBoxGeocodingService {
  static const String _baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  static const String _accessToken = 'pk.eyJ1IjoiYW5ha2FndW5nMjAwOSIsImEiOiJjbTV0Nmlrd3YwdWFmMmpweWtpNTJ0OW15In0.5NLUBqnnikkxiQ8P9PvZCg';

  static Future<List<dynamic>> reverseGeocoding(double latitude, double longitude) async {
    final url = '$_baseUrl/${longitude},${latitude}.json?access_token=$_accessToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['features'] ?? [];
      } else {
        throw Exception('Failed to load geocoding data');
      }
    } catch (e) {
      print('Geocoding error: $e');
      return [];
    }
  }

  static Future<String> getOptimizedCityName(double latitude, double longitude) async {
    final features = await reverseGeocoding(latitude, longitude);

    if (features.isNotEmpty) {
      // Prioritas pencarian nama kota dengan berbagai strategi
      final cityVariations = [
        // 1. Cari nama kota di context
            () {
          for (var feature in features) {
            final context = feature['context'] as List?;
            if (context != null) {
              // Cari entri place atau locality
              final placeEntries = context.where((ctx) =>
              (ctx['id'] as String?)?.startsWith('place.') == true ||
                  (ctx['id'] as String?)?.startsWith('locality.') == true
              ).toList();

              if (placeEntries.isNotEmpty) {
                return placeEntries.first['text'];
              }
            }
          }
          return null;
        }(),

        // 2. Ambil nama dari fitur dengan tipe 'place'
            () {
          final placeFeatures = features.where((feature) =>
          (feature['place_type'] as List?)?.contains('place') == true
          ).toList();

          if (placeFeatures.isNotEmpty) {
            return placeFeatures.first['text'];
          }
          return null;
        }(),

        // 3. Ambil nama dari place_name
        features[0]['place_name']?.split(',').first,

        // 4. Ambil text dari fitur pertama
        features[0]['text'],
      ];

      // Filter dan kembalikan variasi yang valid
      final validCityNames = cityVariations
          .where((city) =>
      city != null &&
          city.isNotEmpty &&
          city != 'Unnamed Road' &&
          city != 'Unnamed'
      )
          .toList();

      // Jika tidak ada nama kota valid, gunakan fallback
      if (validCityNames.isEmpty) {
        // Coba ekstrak negara
        final countryFeature = features.firstWhere(
                (feature) =>
            (feature['place_type'] as List?)?.contains('country') == true,
            orElse: () => null
        );

        return countryFeature != null
            ? countryFeature['text']
            : 'Unknown Location';
      }

      return validCityNames.first!;
    }

    return 'Unknown Location';
  }

  // Metode untuk debugging
  static Future<void> printGeocodeDetails(double latitude, double longitude) async {
    final features = await reverseGeocoding(latitude, longitude);

    if (features.isNotEmpty) {
      print('Geocode Features:');
      for (var feature in features) {
        print('Text: ${feature['text']}');
        print('Place Type: ${feature['place_type']}');
        print('Place Name: ${feature['place_name']}');

        final context = feature['context'] as List?;
        if (context != null) {
          print('Context:');
          for (var ctx in context) {
            print('  - ${ctx['id']}: ${ctx['text']}');
          }
        }
        print('---');
      }
    }
  }
}