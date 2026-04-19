class ChargingStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String operator;
  final List<String> plugTypes;
  final String chargingSpeed;
  final bool isAvailable;
  final String? openingHours;
  final String? phone;
  final String? address;
  final String? website;
  final String? fee;
  final Map<String, dynamic>? additionalTags;

  ChargingStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.operator,
    required this.plugTypes,
    required this.chargingSpeed,
    this.isAvailable = true,
    this.openingHours,
    this.phone,
    this.address,
    this.website,
    this.fee,
    this.additionalTags,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>?;
    return ChargingStation(
      id: json['id']?.toString() ?? json['id']?.toString() ?? '',
      name:
          (json['name'] as String?) ??
          tags?['name'] as String? ??
          'Unknown Station',
      latitude: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0.0,
      operator: tags?['operator'] as String? ?? 'Unknown',
      plugTypes: _parsePlugTypes(tags),
      chargingSpeed: _parseChargingSpeed(tags),
      openingHours: tags?['opening_hours'] as String?,
      phone: tags?['phone'] as String?,
      address: _parseAddress(tags),
      website: tags?['website'] as String?,
      fee: tags?['fee'] as String?,
      additionalTags: tags,
    );
  }

  static String? _parseAddress(Map<String, dynamic>? tags) {
    if (tags == null) return null;

    final housenumber = tags['addr:housenumber'] as String?;
    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String?;
    final fullAddress = tags['addr:full'] as String?;

    if (fullAddress != null) return fullAddress;

    if (street != null) {
      final parts = <String>[];
      if (housenumber != null) parts.add(housenumber);
      parts.add(street);
      if (city != null) parts.add(city);
      return parts.join(', ');
    }

    return null;
  }

  static List<String> _parsePlugTypes(Map<String, dynamic>? tags) {
    if (tags == null) return ['Unknown'];

    final List<String> types = [];

    if (tags['socket:type2'] != null) types.add('Type 2');
    if (tags['socket:chademo'] != null) types.add('CHAdeMO');
    if (tags['socket:tesla_supercharger'] != null) types.add('Tesla');
    if (tags['socket:ccs'] != null || tags['socket:type2_combo'] != null) {
      types.add('CCS');
    }

    return types.isEmpty ? ['Unknown'] : types;
  }

  static String _parseChargingSpeed(Map<String, dynamic>? tags) {
    if (tags == null) return 'Normal';

    final power = tags['capacity'] ?? tags['output'];
    if (power != null) {
      final powerValue = double.tryParse(power.toString()) ?? 0;
      if (powerValue >= 150) return 'Ultra Fast';
      if (powerValue >= 50) return 'Fast';
    }

    return 'Normal';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'operator': operator,
      'plugTypes': plugTypes,
      'chargingSpeed': chargingSpeed,
      'isAvailable': isAvailable,
      'openingHours': openingHours,
      'phone': phone,
      'address': address,
      'website': website,
      'fee': fee,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'operator': operator,
      'plug_types': plugTypes.join(','),
      'charging_speed': chargingSpeed,
      'is_available': isAvailable ? 1 : 0,
      'opening_hours': openingHours,
      'phone': phone,
      'address': address,
      'website': website,
      'fee': fee,
    };
  }

  factory ChargingStation.fromDbMap(Map<String, dynamic> map) {
    return ChargingStation(
      id: (map['id'] as String?)?.toString() ?? '',
      name: (map['name'] as String?) ?? 'Unknown Station',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      operator: (map['operator'] as String?) ?? 'Unknown',
      plugTypes: ((map['plug_types'] as String?) ?? 'Unknown').split(','),
      chargingSpeed: (map['charging_speed'] as String?) ?? 'Normal',
      isAvailable: ((map['is_available'] as int?) ?? 1) == 1,
      openingHours: map['opening_hours'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      website: map['website'] as String?,
      fee: map['fee'] as String?,
    );
  }
}
