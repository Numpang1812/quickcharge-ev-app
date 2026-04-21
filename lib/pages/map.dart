import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/charging_station.dart';
import '../services/google_maps_service.dart';
import '../services/database_service.dart';
import '../services/route_service.dart';
import '../services/turso_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'filter_stations_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Center of Cambodia
  final LatLng _cambodiaCenter = const LatLng(12.5657, 104.9910);
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  final DatabaseService _databaseService = DatabaseService();

  List<ChargingStation> _stations = [];
  List<ChargingStation> _filteredStations = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter criteria
  String? _selectedOperator;
  String? _selectedPlug;
  String? _selectedSpeed;

  // Routing
  List<LatLng> _routePoints = [];
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await dotenv.load(fileName: ".env");
      
      final orsKey = dotenv.env['ORS_API_KEY'] ?? '';
      final mapsKey = dotenv.env['GOOGLE_MAP_API'] ?? '';
      final tursoUrl = dotenv.env['TURSO_URL'] ?? '';
      final tursoToken = dotenv.env['TURSO_TOKEN'] ?? '';
      
      RouteService.loadEnvManual(orsKey);
      GoogleMapsService.loadEnvManual(mapsKey);
      TursoService.loadEnvManual(tursoUrl, tursoToken);

      await _getCurrentLocation();
      await _loadStations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Check if a coordinate falls within Cambodia's bounding box
  /// (roughly lat 10.0–15.0, lng 102.0–108.5)
  bool _isInCambodia(double lat, double lng) {
    return lat >= 10.0 && lat <= 15.0 && lng >= 102.0 && lng <= 108.5;
  }

  Future<void> _getCurrentLocation() async {
    // For emulator or if GPS is unavailable, we default to Phnom Penh
    const LatLng phnomPenh = LatLng(11.5564, 104.9282);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services disabled, using Phnom Penh default.');
        setState(() => _currentLocation = phnomPenh);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied, using Phnom Penh default.');
          setState(() => _currentLocation = phnomPenh);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied, using Phnom Penh default.');
        setState(() => _currentLocation = phnomPenh);
        return;
      }

      // Try getting the last known position first — the emulator may already
      // have a manually-set location cached.
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      debugPrint('Last known position: ${lastKnown?.latitude}, ${lastKnown?.longitude}');

      // Now request a fresh fix using compatible parameters
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('GPS fix: (${position.latitude}, ${position.longitude})');

      // Decide which position to use. Prefer the fresh fix if it's in
      // Cambodia; otherwise fall back to lastKnown if *that* is in Cambodia.
      LatLng? chosen;

      if (_isInCambodia(position.latitude, position.longitude)) {
        chosen = LatLng(position.latitude, position.longitude);
        debugPrint('Fresh GPS fix is inside Cambodia — using it.');
      } else if (lastKnown != null &&
          _isInCambodia(lastKnown.latitude, lastKnown.longitude)) {
        chosen = LatLng(lastKnown.latitude, lastKnown.longitude);
        debugPrint(
          'Fresh fix outside Cambodia (${position.latitude}, ${position.longitude}), '
          'but last-known is inside Cambodia — using last-known.');
      }

      if (chosen != null) {
        setState(() => _currentLocation = chosen);
        // Move camera to the validated location if we're initializing
        if (_routePoints.isEmpty) {
           _mapController.move(chosen, 15.0);
        }
      } else {
        // Both fixes are outside Cambodia (e.g. emulator default 37.42, -122.08)
        debugPrint(
          'GPS fix (${position.latitude}, ${position.longitude}) is outside Cambodia '
          '(emulator default?). Falling back to Phnom Penh.');
        setState(() => _currentLocation = phnomPenh);
        _mapController.move(phnomPenh, 15.0);
      }
    } catch (e) {
      debugPrint('Error getting location, falling back to Phnom Penh: $e');
      setState(() => _currentLocation = phnomPenh);
    }
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to load from local database first
      final localStations = await _databaseService.getAllStations();

      if (localStations.isNotEmpty) {
        setState(() {
          _stations = localStations;
          _applyFilters();
          _isLoading = false;
        });
      }

      // Fetch fresh data from Turso API instead of Google Maps
      final apiStations = await TursoService.fetchStations();

      if (apiStations.isNotEmpty) {
        // Save to database
        await _databaseService.deleteAllStations();
        await _databaseService.insertStations(apiStations);

        setState(() {
          _stations = apiStations;
          _applyFilters();
          _isLoading = false;
        });
      } else if (localStations.isEmpty) {
        setState(() {
          _errorMessage = 'No charging stations found';
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, try to use cached data
      final localStations = await _databaseService.getAllStations();
      if (localStations.isNotEmpty) {
        setState(() {
          _stations = localStations;
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load stations: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    _filteredStations = _stations.where((station) {
      if (_selectedOperator != null && station.operator != _selectedOperator) {
        return false;
      }
      if (_selectedPlug != null && !station.plugTypes.contains(_selectedPlug)) {
        return false;
      }
      if (_selectedSpeed != null && station.chargingSpeed != _selectedSpeed) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _calculateRouteToDestination(LatLng destination) async {
    if (_currentLocation == null) {
      await _getCurrentLocation();
    }

    // Safety check for (0,0) or suspicious coordinates
    if (_currentLocation!.latitude.abs() < 0.01 &&
        _currentLocation!.longitude.abs() < 0.01) {
      setState(() => _errorMessage = 'Invalid current location (near 0,0).');
      return;
    }

    // Sanity check: if distance is > 5000km, it's almost certainly a coordinate error for Cambodia
    final double distanceMeters = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      destination.latitude,
      destination.longitude,
    );

    if (distanceMeters > 5000000) {
      setState(() {
        _errorMessage =
            'Destination too far (${(distanceMeters / 1000).toStringAsFixed(0)} km). '
            'Current: ${_currentLocation!.latitude.toStringAsFixed(2)},${_currentLocation!.longitude.toStringAsFixed(2)}. '
            'Dest: ${destination.latitude.toStringAsFixed(2)},${destination.longitude.toStringAsFixed(2)}.';
      });
      return;
    }

    setState(() {
      _isRouting = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Routing from ${_currentLocation!.latitude},${_currentLocation!.longitude} to ${destination.latitude},${destination.longitude}');
      final routeData = await RouteService.getRoute(
        _currentLocation!,
        destination,
      );

      // Extract and decode polyline from ORS response
      final routes = routeData['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final firstRoute = routes[0] as Map<String, dynamic>;
        final geometry = firstRoute['geometry'] as String?;
        if (geometry != null) {
          _routePoints = RouteService.decodePolyline(geometry);

          // Fit map to show entire route
          if (_routePoints.isNotEmpty) {
            final bounds = LatLngBounds.fromPoints(_routePoints);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to calculate route: $e';
      });
    } finally {
      setState(() {
        _isRouting = false;
      });
    }
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
    });
  }

  void _showStationDetails(ChargingStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Operator: ${station.operator}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Plug Types: ${station.plugTypes.join(', ')}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Charging Speed: ${station.chargingSpeed}',
                style: const TextStyle(fontSize: 16),
              ),
              if (station.address != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Address: ${station.address}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (station.phone != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Phone: ${station.phone}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (station.openingHours != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Hours: ${station.openingHours}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              if (station.website != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Website: ${station.website}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
              if (station.fee != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Fee: ${station.fee}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _calculateRouteToDestination(
                          LatLng(station.latitude, station.longitude),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _cambodiaCenter,
                initialZoom: 7.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.quickcharge_ev_app',
                ),
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _filteredStations
                      .map(
                        (station) => Marker(
                          point: LatLng(station.latitude, station.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () {
                              _showStationDetails(station);
                            },
                            child: const Icon(
                              Icons.ev_station,
                              color: Color(0xFF10B981),
                              size: 40,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
              ],
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            // Zoom control buttons
            Positioned(
              right: 16,
              top: 100,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'my_location',
                    mini: true,
                    onPressed: () async {
                      await _getCurrentLocation();
                      if (_currentLocation != null) {
                        _mapController.move(_currentLocation!, 15.0);
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),
                  if (_routePoints.isNotEmpty)
                    FloatingActionButton(
                      heroTag: 'clear_route',
                      mini: true,
                      onPressed: _clearRoute,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.close),
                    ),
                ],
              ),
            ),
            // Filter button floating at bottom
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute<Map<String, String>>(
                        builder: (context) => const FilterStationsScreen(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedOperator = result['operator'];
                        _selectedPlug = result['plug'];
                        _selectedSpeed = result['speed'];
                        _applyFilters();
                      });
                    }
                  },
                  icon: const Icon(Icons.filter_list, size: 22),
                  label: const Text(
                    'Filter Stations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF10B981).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
