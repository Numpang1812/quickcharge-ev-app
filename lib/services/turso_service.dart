import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charging_station.dart';

class TursoService {
  static String? _url;
  static String? _token;

  // Initialize from pure dart script
  static void loadEnvManual(String url, String token) {
    _initVals(url, token);
  }

  static void _initVals(String? u, String? t) {
    if (u != null) {
      _url = u.replaceAll('libsql://', 'https://').replaceAll('wss://', 'https://');
    }
    _token = t;
  }

  static Future<Map<String, dynamic>> _execute(String sql, [List<dynamic> args = const []]) async {
    if (_url == null || _token == null) throw Exception("Turso credentials not loaded");

    final List<Map<String, dynamic>> tursoArgs = args.map((a) {
      if (a == null) return {"type": "null"};
      if (a is int) return {"type": "integer", "value": a.toString()};
      if (a is double) return {"type": "float", "value": a};
      if (a is bool) return {"type": "integer", "value": a ? "1" : "0"};
      return {"type": "text", "value": a.toString()};
    }).toList();

    final body = jsonEncode({
      "requests": [
        {
          "type": "execute",
          "stmt": {
            "sql": sql,
            "args": tursoArgs
          }
        },
        {"type": "close"}
      ]
    });

    final response = await http.post(
      Uri.parse('$_url/v2/pipeline'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Turso request failed: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List?;
    if (results == null || results.isEmpty) throw Exception('No result from Turso');
    
    final queryResult = results[0] as Map<String, dynamic>;
    if (queryResult['type'] == 'error') {
       throw Exception("Turso SQL error: ${queryResult['error']}");
    }

    final responseObj = queryResult['response'] as Map<String, dynamic>;
    return responseObj['result'] as Map<String, dynamic>;
  }

  static Future<void> createTableIfNotExists() async {
    await _execute('''
      CREATE TABLE IF NOT EXISTS charging_stations(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        operator TEXT,
        plug_types TEXT,
        charging_speed TEXT,
        is_available INTEGER DEFAULT 1,
        opening_hours TEXT,
        phone TEXT,
        address TEXT,
        website TEXT,
        fee TEXT
      )
    ''');
  }

  static Future<void> uploadStations(List<ChargingStation> stations) async {
    await createTableIfNotExists();
    
    for (var station in stations) {
      final map = station.toDbMap();
      await _execute('''
        INSERT INTO charging_stations(
          id, name, latitude, longitude, operator, plug_types, charging_speed, 
          is_available, opening_hours, phone, address, website, fee
        ) VALUES (
          ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
        ) ON CONFLICT(id) DO UPDATE SET
          name=excluded.name,
          latitude=excluded.latitude,
          longitude=excluded.longitude,
          operator=excluded.operator,
          plug_types=excluded.plug_types,
          charging_speed=excluded.charging_speed,
          is_available=excluded.is_available,
          opening_hours=excluded.opening_hours,
          phone=excluded.phone,
          address=excluded.address,
          website=excluded.website,
          fee=excluded.fee;
      ''', [
        map['id'], map['name'], map['latitude'], map['longitude'],
        map['operator'], map['plug_types'], map['charging_speed'],
        map['is_available'], map['opening_hours'], map['phone'],
        map['address'], map['website'], map['fee']
      ]);
    }
  }

  static Future<List<ChargingStation>> fetchStations() async {
    try {
      final result = await _execute('SELECT * FROM charging_stations');
      final cols = (result['cols'] as List).cast<Map<String, dynamic>>();
      final rows = (result['rows'] as List).cast<List<dynamic>>();
      
      final colNames = cols.map((c) => c['name'] as String).toList();
      
      return rows.map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < colNames.length; i++) {
          final val = row[i] as Map<String, dynamic>?;
          if (val != null && val['type'] != 'null') {
             if (val['type'] == 'float' || val['type'] == 'integer') {
                 map[colNames[i]] = num.tryParse(val['value'].toString());
             } else {
                 map[colNames[i]] = val['value'];
             }
          }
        }
        return ChargingStation.fromDbMap(map);
      }).toList();
    } catch (e) {
      // Table might not exist yet
      if (e.toString().contains('no such table')) {
         return [];
      }
      rethrow;
    }
  }
}
