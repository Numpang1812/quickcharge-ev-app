import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

class OverpassService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';

  // Bounding box for Cambodia (more precise)
  // south, west, north, east
  static const String _cambodiaBbox = '10.4,102.3,14.7,107.6';

  static Future<List<ChargingStation>> fetchChargingStations() async {
    // Query for multiple tag variations to catch all charging stations
    final query =
        '''
      [out:json][timeout:180];
      (
        node["amenity"="charging_station"]($_cambodiaBbox);
        way["amenity"="charging_station"]($_cambodiaBbox);
        relation["amenity"="charging_station"]($_cambodiaBbox);
        node["charging_station"="yes"]($_cambodiaBbox);
        way["charging_station"="yes"]($_cambodiaBbox);
        node["motorcar_charging"="yes"]($_cambodiaBbox);
        way["motorcar_charging"="yes"]($_cambodiaBbox);
      );
      out center;
    ''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=$query',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _parseStations(data);
      } else {
        throw Exception('Failed to fetch stations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stations: $e');
    }
  }

  static List<ChargingStation> _parseStations(Map<String, dynamic> data) {
    final List<ChargingStation> stations = [];

    // Cambodia bounds for validation
    const double minLat = 10.0;
    const double maxLat = 15.0;
    const double minLon = 102.0;
    const double maxLon = 108.0;

    if (data['elements'] != null && data['elements'] is List) {
      for (var element in data['elements'] as List) {
        try {
          if (element is Map<String, dynamic>) {
            final station = ChargingStation.fromJson(element);

            // Validate location is within Cambodia bounds
            if (station.latitude >= minLat &&
                station.latitude <= maxLat &&
                station.longitude >= minLon &&
                station.longitude <= maxLon) {
              stations.add(station);
            }
          }
        } catch (e) {
          // Skip invalid stations
          continue;
        }
      }
    }

    return stations;
  }
}
