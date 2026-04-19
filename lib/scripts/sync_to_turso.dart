import 'dart:io';
import '../services/google_maps_service.dart';
import '../services/turso_service.dart';

void main() async {
  print('--- Starting Google Maps to Turso Sync ---');

  // 1. Manually parse .env file to avoid flutter dependencies in terminal
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found in the root directory.');
    return;
  }

  final lines = envFile.readAsLinesSync();
  final envVars = <String, String>{};
  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final index = line.indexOf('=');
    if (index > 0) {
      envVars[line.substring(0, index).trim()] = line.substring(index + 1).trim();
    }
  }

  final googleApiKey = envVars['GOOGLE_MAP_API'];
  final tursoUrl = envVars['TURSO_URL'];
  final tursoToken = envVars['TURSO_TOKEN'];

  if (googleApiKey == null || tursoUrl == null || tursoToken == null) {
    print('Error: Missing required environment variables in .env');
    return;
  }

  // 2. Initialize Services manually
  GoogleMapsService.loadEnvManual(googleApiKey);
  TursoService.loadEnvManual(tursoUrl, tursoToken);

  try {
    print('Fetching charging stations from Google Maps (Cambodia ONLY)...');
    final stations = await GoogleMapsService.fetchChargingStations();
    
    print('Found ${stations.length} stations in Cambodia bounds.');
    
    if (stations.isEmpty) {
      print('No stations found to sync. Exiting.');
      return;
    }

    print('Uploading stations to Turso DB...');
    await TursoService.uploadStations(stations);
    
    print('Sync Complete! Successfully upserted ${stations.length} stations into Turso.');

  } catch (e) {
    print('An error occurred during sync: $e');
  }
}
