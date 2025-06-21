import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents detailed geographic location data.
///
/// This class holds a specific [LatLng] position and its associated
/// address components, such as city, country, street, and postal code.
class LocationData {
  /// Creates a [LocationData] instance.
  ///
  /// [position] is the geographic coordinates (latitude and longitude).
  /// [address] is the full formatted address string.
  /// Other fields are optional and provide specific address components.
  const LocationData({
    required this.position,
    required this.address,
    this.city,
    this.country,
    this.postalCode,
    this.street,
    this.subLocality,
  });

  /// The geographic coordinates (latitude and longitude) of the location.
  final LatLng position;

  /// The full formatted address string (e.g., "1600 Amphitheatre Parkway, Mountain View, CA 94043").
  final String address;

  /// The city name, if available (e.g., "Mountain View").
  final String? city;

  /// The country name, if available (e.g., "United States").
  final String? country;

  /// The postal code, if available (e.g., "94043").
  final String? postalCode;

  /// The street name, if available (e.g., "Amphitheatre Parkway").
  final String? street;

  /// The sub-locality or neighborhood, if available.
  final String? subLocality;

  /// Creates a new [LocationData] instance with updated values.
  ///
  /// You can provide new values for any of the fields, and if a field is not
  /// provided, its value from the current instance will be used.
  LocationData copyWith({
    LatLng? position,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    String? street,
    String? subLocality,
  }) {
    return LocationData(
      position: position ?? this.position,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      subLocality: subLocality ?? this.subLocality,
    );
  }

  /// Converts this [LocationData] instance into a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'street': street,
      'subLocality': subLocality,
    };
  }

  /// Creates a [LocationData] instance from a JSON [Map].
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      street: json['street'],
      subLocality: json['subLocality'],
    );
  }

  @override
  String toString() {
    return 'LocationData{position: $position, address: $address, city: $city}';
  }

  /// Compares two [LocationData] instances for equality.
  ///
  /// Two [LocationData] objects are considered equal if their [position],
  /// [address], [city], and [country] properties are all equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.position == position &&
        other.address == address &&
        other.city == city &&
        other.country == country;
  }

  /// The hash code for this [LocationData] instance.
  ///
  /// Based on the [position], [address], [city], and [country] properties.
  @override
  int get hashCode {
    return position.hashCode ^
        address.hashCode ^
        city.hashCode ^
        country.hashCode;
  }
}
