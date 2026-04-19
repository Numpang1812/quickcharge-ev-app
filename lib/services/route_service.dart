import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static String? _apiKey;
  static const String _baseUrl = 'https://api.openrouteservice.org';

  static void loadEnvManual(String apiKey) {
    _apiKey = apiKey;
  }

  static String get apiKey {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('ORS_API_KEY not found in .env file');
    }
    return _apiKey!;
  }

  static Future<Map<String, dynamic>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse('$_baseUrl/v2/directions/driving-car');

    final body = json.encode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': apiKey},
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting route: $e');
    }
  }

  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  static Future<List<Map<String, dynamic>>> getStationsAlongRoute(
    List<LatLng> route,
  ) async {
    // This would use the ORS POI endpoint to find charging stations along the route
    // For now, return empty list as this requires additional API configuration
    return [];
  }
}
