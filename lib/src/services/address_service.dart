import 'package:flutter/foundation.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/location_data.dart';

/// Manages address-related operations, including reverse geocoding and place search (autocomplete).
///
/// This service implements a singleton pattern and integrates with both
/// `geocoding` for coordinate-to-address conversion and
/// `Maps_webservice` for text-based place search using Google Places API.
class AddressService {
  // --- Singleton Pattern Implementation ---
  static AddressService? _instance;

  /// Provides access to the singleton instance of [AddressService].
  ///
  /// Throws an exception if the service has not been initialized with an API key
  /// using the factory constructor [AddressService()].
  static AddressService get instance {
    if (_instance == null) {
      // This ensures that the AddressService must be initialized via the factory
      // constructor (e.g., AddressService(apiKey: 'YOUR_KEY')) at its first use.
      throw Exception("AddressService must be initialized with an API key.");
    }
    return _instance!;
  }

  /// Private constructor used by the factory to create the singleton instance.
  /// It initializes the [GoogleMapsPlaces] client with the provided API key.
  AddressService._internal({required String apiKey})
    : _places = GoogleMapsPlaces(apiKey: apiKey);

  /// Factory constructor to create or retrieve the singleton instance of [AddressService].
  ///
  /// It ensures that only one instance of the service exists and that it is
  /// properly initialized with the Google Places API key.
  /// Throws an [ArgumentError] if the API key is null or empty on first initialization.
  factory AddressService({required String? apiKey}) {
    if (_instance == null) {
      if (apiKey == null || apiKey.isEmpty) {
        throw ArgumentError(
          "Google Places API Key must not be null or empty on first initialization.",
        );
      }
      _instance = AddressService._internal(apiKey: apiKey);
    }
    return _instance!;
  }

  // --- Google Places API Configuration ---
  /// The [GoogleMapsPlaces] client used for interacting with the Google Places API.
  late final GoogleMapsPlaces _places;

  // --- Address Cache for Reverse Geocoding ---
  /// A cache to store previously retrieved addresses based on their coordinates.
  final Map<String, LocationData> _addressCache = {};

  /// The maximum number of entries the address cache can hold.
  static const int _maxCacheSize = 100;

  /// Retrieves a detailed address from geographic coordinates (reverse geocoding).
  ///
  /// This method uses the `geocoding` package. Results are cached to
  /// improve performance for repeated lookups of the same coordinates.
  ///
  /// [position]: The [LatLng] coordinates for which to find the address.
  /// [timeout]: Optional duration for the geocoding request to complete.
  /// Returns a [LocationData] object containing the position and address details.
  Future<LocationData> getAddressFromCoordinates(
    LatLng position, {
    Duration? timeout,
  }) async {
    final cacheKey =
        '${position.latitude.toStringAsFixed(6)}_${position.longitude.toStringAsFixed(6)}';

    // Check if the address is already in the cache.
    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey]!;
    }

    try {
      // Fetch placemarks (address details) from coordinates.
      // `localeIdentifier` can be added (e.g., 'fr_FR') if specific locale results are needed.
      final placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(timeout ?? const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final locationData = _buildLocationDataFromPlacemark(
          position,
          placemark,
        );

        // Add the retrieved address to the cache.
        _addToCache(cacheKey, locationData);

        return locationData;
      } else {
        // Return a default "address not found" if no placemarks are returned.
        return LocationData(position: position, address: 'Address not found');
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      // Return a default error message if an exception occurs.
      return LocationData(
        position: position,
        address: 'Error retrieving address',
      );
    }
  }

  /// Searches for addresses using text input (autocomplete feature).
  ///
  /// This method leverages the Google Places API for improved performance and
  /// more relevant search results compared to basic geocoding.
  ///
  /// [query]: The text query entered by the user (e.g., "Eiffel Tower").
  /// [bias]: Optional [LatLng] to bias results towards a specific geographic location.
  /// [radius]: Optional radius in meters for location biasing.
  /// [timeout]: Optional time limit for the HTTP request to the Places API.
  /// [language]: Optional language code for results (e.g., 'en', 'fr'). Defaults to 'fr'.
  /// [country]: Optional ISO 3166-1 Alpha-2 code to bias results to a specific country (e.g., 'us', 'fr').
  /// Returns a list of [LocationData] suggestions.
  Future<List<LocationData>> searchAddresses(
    String query, {
    LatLng? bias,
    double? radius,
    Duration? timeout,
    String? language = 'fr',
    String? country = 'fr',
  }) async {
    debugPrint('Searching for addresses via Places API: $query');

    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Prepare location bias if provided.
      Location? locationBias;
      if (bias != null) {
        locationBias = Location(lat: bias.latitude, lng: bias.longitude);
      }

      debugPrint('Bias: $locationBias');

      // Perform the autocomplete request using Google Places API.
      // A new session token is generated for each search session for billing optimization.
      final PlacesAutocompleteResponse response = await _places.autocomplete(
        query,
        language: language,
        // The `components` parameter is commented out as it strictly filters by country.
        // If strict country filtering is desired, uncomment and adjust.
        components: [], //[Component(Component.country, country!)],
        location: locationBias, // Bias results towards this location.
        radius: radius, // Radius (in meters) around the biased location.
        strictbounds:
            false, // Set to true to restrict results strictly to bounds.
        sessionToken: Uuid().v4(), // Unique session token for billing.
      );

      debugPrint('Places API Autocomplete Response: ${response.toJson()}');

      if (response.isOkay) {
        final List<LocationData> results = [];
        for (final prediction in response.predictions) {
          debugPrint('Processing Prediction: ${prediction.toJson()}');

          // For each prediction, fetch place details to get precise LatLng and full address components.
          // Fields are specified to limit data fetched, optimizing performance and cost.
          final PlacesDetailsResponse
          details = await _places.getDetailsByPlaceId(
            prediction.placeId!,
            // fields: ['geometry', 'address_component', 'formatted_address', 'name'],
            // Note: If you uncomment fields, ensure your API key has access to them and they are billed.
          );

          debugPrint('Place Details Response: $details');

          if (details.isOkay) {
            final place = details.result;
            final latLng = LatLng(
              place.geometry!.location.lat,
              place.geometry!.location.lng,
            );

            // Map the Places API result to your custom LocationData model.
            results.add(
              LocationData(
                position: latLng,
                address: place.formattedAddress ?? prediction.description ?? '',
                city: _findAddressComponent(
                  place.addressComponents,
                  'locality',
                ),
                country: _findAddressComponent(
                  place.addressComponents,
                  'country',
                ),
                postalCode: _findAddressComponent(
                  place.addressComponents,
                  'postal_code',
                ),
                street: _findStreet(place.addressComponents),
                subLocality: _findAddressComponent(
                  place.addressComponents,
                  'sublocality',
                ),
                // Uncomment if 'name' field is added to LocationData and desired.
                // name: prediction.structuredFormatting?.mainText,
              ),
            );
          }
        }
        return results;
      } else {
        // Log specific error message from Places API response.
        debugPrint('Places API Error: ${response.errorMessage}');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching addresses with Places API: $e');
      return [];
    }
  }

  /// Helper method to extract a specific address component (e.g., city, postal code)
  /// from a list of [AddressComponent] objects provided by Places API details.
  ///
  /// [components]: The list of address components from a Place Details result.
  /// [type]: The type of address component to find (e.g., 'locality', 'country').
  /// Returns the long name of the component, or null if not found.
  String? _findAddressComponent(
    List<AddressComponent>? components,
    String type,
  ) {
    if (components == null) return null;
    for (var comp in components) {
      if (comp.types.contains(type)) {
        return comp.longName;
      }
    }
    return null;
  }

  /// Helper method to construct a full street address from route and street number components.
  ///
  /// [components]: The list of address components from a Place Details result.
  /// Returns the formatted street string (e.g., "1600 Amphitheatre Pkwy"), or null if not found.
  String? _findStreet(List<AddressComponent>? components) {
    if (components == null) return null;
    String? streetNumber = _findAddressComponent(components, 'street_number');
    String? route = _findAddressComponent(
      components,
      'route',
    ); // This is the street name
    if (route != null && streetNumber != null) {
      return '$streetNumber $route';
    } else if (route != null) {
      return route;
    }
    return null;
  }

  /// Constructs a [LocationData] object from a [LatLng] position and a `geocoding.Placemark`.
  ///
  /// This is specifically used for reverse geocoding results.
  LocationData _buildLocationDataFromPlacemark(
    LatLng position,
    geocoding.Placemark placemark,
  ) {
    final addressParts = <String>[];

    // Build a coherent address string from available placemark components.
    if (placemark.street?.isNotEmpty == true) {
      addressParts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true &&
        placemark.subLocality != placemark.locality) {
      addressParts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }

    final address = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Address not available';

    return LocationData(
      position: position,
      address: address,
      city: placemark.locality,
      country: placemark.country,
      postalCode: placemark.postalCode,
      street: placemark.street,
      subLocality: placemark.subLocality,
    );
  }

  /// Adds a [LocationData] entry to the address cache.
  ///
  /// Manages cache size by removing the oldest entry if the maximum size is exceeded.
  /// [key]: The cache key (typically formatted LatLng string).
  /// [data]: The [LocationData] to cache.
  void _addToCache(String key, LocationData data) {
    if (_addressCache.length >= _maxCacheSize) {
      // Remove the oldest entry to make space.
      final firstKey = _addressCache.keys.first;
      _addressCache.remove(firstKey);
    }
    _addressCache[key] = data;
  }

  /// Clears all entries from the address cache.
  void clearCache() {
    _addressCache.clear();
  }
}
