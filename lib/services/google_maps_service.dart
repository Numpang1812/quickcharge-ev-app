import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

class GoogleMapsService {
  static String? _apiKey;

  static void loadEnvManual(String apiKey) {
    _apiKey = apiKey;
  }

  static String? get apiKey => _apiKey;

  static Future<List<ChargingStation>> fetchChargingStations() async {
    if (_apiKey == null) {
      throw Exception('Google Maps API key not loaded');
    }

    final Map<String, ChargingStation> uniqueStations = {};

    // Search terms for EV charging stations
    final searchTerms = [
      'EV charging station',
      'electric vehicle charging',
      'EV charger',
      'charging station',
      'Tesla Supercharger',
      'CCS charging',
      'Type 2 charging',
    ];

    // Regional centers of Cambodia with radiuses to cover thoroughly
    final List<Map<String, double>> regions = [
      {'lat': 11.5564, 'lng': 104.9282, 'radius': 100000}, // Phnom Penh (Central)
      {'lat': 13.3611, 'lng': 103.8596, 'radius': 150000}, // Siem Reap (North West)
      {'lat': 10.6093, 'lng': 103.5296, 'radius': 150000}, // Sihanoukville (South West)
      {'lat': 13.7333, 'lng': 107.0000, 'radius': 200000}, // Ratanakiri (East)
      {'lat': 13.0957, 'lng': 103.2022, 'radius': 150000}, // Battambang (West)
    ];

    try {
      for (final region in regions) {
        for (final term in searchTerms) {
          String? nextPageToken;
          do {
            Uri url;
            if (nextPageToken == null) {
              url = Uri.parse(
                'https://maps.googleapis.com/maps/api/place/textsearch/json'
                '?query=${Uri.encodeComponent(term)}'
                '&location=${region['lat']},${region['lng']}'
                '&radius=${region['radius']!.toInt()}'
                '&language=en'
                '&region=KH'
                '&key=$_apiKey',
              );
            } else {
              // Wait 2 seconds before requesting the next page token as per Google Maps API requirements
              await Future.delayed(const Duration(seconds: 2));
              url = Uri.parse(
                'https://maps.googleapis.com/maps/api/place/textsearch/json'
                '?pagetoken=$nextPageToken'
                '&key=$_apiKey',
              );
            }

            final response = await http.get(url);
            if (response.statusCode == 200) {
              final data = json.decode(response.body) as Map<String, dynamic>;

              if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
                final results = data['results'] as List?;
                if (results != null) {
                  for (final result in results) {
                    if (result is Map<String, dynamic>) {
                      final geometry = result['geometry'] as Map<String, dynamic>?;
                      final location = geometry?['location'] as Map<String, dynamic>?;

                      if (location != null) {
                        final lat = location['lat'] as num?;
                        final lng = location['lng'] as num?;

                        if (lat != null && lng != null) {
                          final station = ChargingStation(
                            id: result['place_id'] as String? ?? '',
                            name: result['name'] as String? ?? 'Unknown Station',
                            latitude: lat.toDouble(),
                            longitude: lng.toDouble(),
                            operator: _extractOperator(result),
                            plugTypes: _extractPlugTypes(result),
                            chargingSpeed: _extractChargingSpeed(result),
                            openingHours: _extractOpeningHours(result),
                            phone: result['formatted_phone_number'] as String?,
                            address: result['formatted_address'] as String?,
                            website: result['website'] as String?,
                            fee: result['price_level'] != null
                                ? _extractPriceLevel(result['price_level'] as int)
                                : null,
                          );

                          // Validate location is within Cambodia bounds
                          if (_isWithinCambodia(station.latitude, station.longitude, station.address)) {
                            uniqueStations[station.id] = station;
                          }
                        }
                      }
                    }
                  }
                }
                nextPageToken = data['next_page_token'] as String?;
              } else {
                nextPageToken = null; // Stop if not OK (e.g. INVALID_REQUEST from token not ready)
              }
            } else {
              break; // HTTP error
            }
          } while (nextPageToken != null);
        }
      }
    } catch (e) {
      throw Exception('Error fetching stations from Google Maps: $e');
    }

    return uniqueStations.values.toList();
  }

  static bool _isWithinCambodia(double lat, double lng, String? address) {
    // Basic large bounding box check
    if (lat < 10.0 || lat > 15.0 || lng < 102.0 || lng > 108.0) return false;
    
    if (address != null) {
      final addrLower = address.toLowerCase();
      // Exclude neighboring countries manually just in case
      if (addrLower.contains('vietnam') || addrLower.contains('viet nam')) return false;
      if (addrLower.contains('thailand')) return false;
      if (addrLower.contains('laos')) return false;
      
      // If it explicitly says cambodia, allow it. Region is set to KH so most will be KH.
      if (addrLower.contains('cambodia')) return true;
    }
    
    // If we can't definitively exclude it or include it by address, check a tighter bounding box
    // specific to Cambodia's borders minus the extreme edges overlapping neighbors.
    // Tighter bounding box for central Cambodia:
    return lat >= 10.4 && lat <= 14.7 && lng >= 102.3 && lng <= 107.6;
  }

  static String _extractOperator(Map<String, dynamic> place) {
    final name = place['name'] as String?;
    if (name != null) {
      final nameLower = name.toLowerCase();
      if (nameLower.contains('tesla')) return 'Tesla';
      if (nameLower.contains('charge+')) return 'Charge+';
      if (nameLower.contains('evgo')) return 'EVgo';
      if (nameLower.contains('electrify america')) return 'Electrify America';
    }
    return 'Unknown';
  }

  static List<String> _extractPlugTypes(Map<String, dynamic> place) {
    final types = <String>[];

    final name = place['name'] as String?;
    if (name != null) {
      final nameLower = name.toLowerCase();
      if (nameLower.contains('tesla')) types.add('Tesla');
      if (nameLower.contains('ccs') || nameLower.contains('combo'))
        types.add('CCS');
      if (nameLower.contains('chademo')) types.add('CHAdeMO');
      if (nameLower.contains('type 2')) types.add('Type 2');
    }

    if (types.isEmpty) {
      types.add('Unknown');
    }

    return types;
  }

  static String _extractChargingSpeed(Map<String, dynamic> place) {
    final name = place['name'] as String?;
    if (name != null) {
      final nameLower = name.toLowerCase();
      if (nameLower.contains('supercharger') || nameLower.contains('ultra')) {
        return 'Ultra Fast';
      }
      if (nameLower.contains('fast')) {
        return 'Fast';
      }
    }

    return 'Normal';
  }

  static String? _extractOpeningHours(Map<String, dynamic> place) {
    final openingHours = place['opening_hours'] as Map<String, dynamic>?;
    if (openingHours != null) {
      final openNow = openingHours['open_now'] as bool?;
      if (openNow != null) {
        return openNow ? 'Open now' : 'Closed';
      }
    }
    return null;
  }

  static String _extractPriceLevel(int level) {
    switch (level) {
      case 0:
        return 'Free';
      case 1:
        return 'Inexpensive';
      case 2:
        return 'Moderate';
      case 3:
        return 'Expensive';
      case 4:
        return 'Very Expensive';
      default:
        return 'Unknown';
    }
  }
}
