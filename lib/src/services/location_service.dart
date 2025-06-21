import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

// --- Custom Exceptions for better error handling ---
/// Exception thrown when location services are disabled on the device.
class LocationServiceDisabledException implements Exception {
  final String message = 'Location services are disabled on the device.';
  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

/// Exception thrown when location permission is denied by the user.
class LocationPermissionDeniedException implements Exception {
  final String message;

  LocationPermissionDeniedException([
    this.message = 'Location permission was denied.',
  ]);

  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}

/// Exception thrown when location permission is permanently denied by the user.
///
/// This usually means the user needs to enable the permission from app settings.
class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message =
      'Location permission permanently denied. Please enable from app settings.';

  @override
  String toString() => 'LocationPermissionPermanentlyDeniedException: $message';
}

// --- LocationService class ---
/// A service class for handling all location-related operations,
/// including getting current position, checking permissions, and caching.
///
/// This class utilizes `geolocator` and `permission_handler` packages.
class LocationService {
  // --- Singleton Pattern ---
  static LocationService? _instance;

  /// Provides access to the singleton instance of [LocationService].
  static LocationService get instance => _instance ??= LocationService._();

  // Private constructor for the singleton pattern.
  LocationService._();

  // --- Location Cache ---
  /// Caches the last known current position to avoid redundant API calls.
  LatLng? _cachedCurrentPosition;

  /// The timestamp of the last successful location update.
  DateTime? _lastLocationUpdate;

  /// The duration for which the cached location is considered valid.
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  /// Retrieves the user's current geographic position.
  ///
  /// This method handles permission checks, location service status,
  /// caching, and specific error conditions.
  ///
  /// [accuracy]: Desired accuracy of the location fix (e.g., [LocationAccuracy.high]).
  /// [timeLimit]: Optional maximum time to wait for a location fix. Defaults to 15 seconds.
  /// [forceRefresh]: If true, bypasses the cache and forces a new location lookup.
  ///
  /// Throws specific exceptions ([LocationServiceDisabledException],
  /// [LocationPermissionDeniedException], [LocationPermissionPermanentlyDeniedException])
  /// for detailed error handling by the caller.
  /// Throws a generic [Exception] for timeouts or unknown errors during location retrieval.
  Future<LatLng?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
    bool forceRefresh = false,
  }) async {
    // Determine the effective timeout for the location request.
    final effectiveTimeLimit = timeLimit ?? const Duration(seconds: 15);

    try {
      // Return cached location if valid and not forcing a refresh.
      if (!forceRefresh && _isLocationCacheValid()) {
        debugPrint('Returning cached location.');
        return _cachedCurrentPosition;
      }

      // Check if location services are enabled on the device.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled. Prompting user to enable.');
        // Optionally, uncomment to open device's location settings:
        // await Geolocator.openLocationSettings();
        throw LocationServiceDisabledException();
      }

      // Check and request location permissions.
      final permissionGranted = await _checkAndRequestLocationPermission();
      if (!permissionGranted) {
        // _checkAndRequestLocationPermission throws specific exceptions,
        // so if we reach here, it implies a denial other than permanent.
        throw LocationPermissionDeniedException();
      }

      // Attempt to get the current position with specified accuracy and timeout.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: effectiveTimeLimit,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);

      // Update the cache with the newly obtained position.
      _cachedCurrentPosition = latLng;
      _lastLocationUpdate = DateTime.now();

      return latLng;
    } on LocationServiceDisabledException {
      rethrow; // Re-throw our custom exception for specific handling by caller.
    } on LocationPermissionDeniedException {
      rethrow; // Re-throw our custom exception.
    } on LocationPermissionPermanentlyDeniedException {
      rethrow; // Re-throw our custom exception.
    } on TimeoutException catch (e) {
      debugPrint('Timeout getting current position: $e');
      throw Exception(
        'Failed to get location within ${effectiveTimeLimit.inSeconds} seconds. Check GPS signal or try again.',
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      throw Exception('An unknown error occurred while getting location: $e');
    }
  }

  /// Checks the current location permission status and requests it if denied.
  ///
  /// This method utilizes the `permission_handler` package.
  /// Throws specific exceptions for different denial states:
  /// [LocationPermissionDeniedException] if denied but can be re-requested.
  /// [LocationPermissionPermanentlyDeniedException] if permanently denied (requires manual settings change).
  /// Returns `true` if permission is granted, `false` otherwise (after throwing an exception).
  Future<bool> _checkAndRequestLocationPermission() async {
    var permissionStatus = await Permission.location.status;

    if (permissionStatus.isGranted) {
      return true;
    }

    if (permissionStatus.isDenied) {
      // Permission is denied but can be requested again.
      permissionStatus = await Permission.location.request();
      if (permissionStatus.isGranted) {
        return true;
      } else {
        throw LocationPermissionDeniedException();
      }
    }

    if (permissionStatus.isPermanentlyDenied) {
      // Permission is permanently denied; user needs to go to app settings.
      debugPrint('Location permission permanently denied. Opening settings.');
      // Optionally, uncomment to open app settings directly:
      // await openAppSettings();
      throw LocationPermissionPermanentlyDeniedException();
    }

    // This case should ideally not be reached under normal circumstances.
    throw LocationPermissionDeniedException('Unknown permission status.');
  }

  /// Checks if the cached location data is still valid based on its age.
  ///
  /// Returns `true` if a cached position exists and is within the
  /// [_cacheValidityDuration], otherwise returns `false`.
  bool _isLocationCacheValid() {
    if (_cachedCurrentPosition == null || _lastLocationUpdate == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastLocationUpdate!) < _cacheValidityDuration;
  }

  /// Provides a stream of continuous position updates.
  ///
  /// This can be used for real-time location tracking.
  /// [accuracy]: Desired accuracy for the stream.
  /// [distanceFilter]: Minimum distance (in meters) the device must move
  ///                   before a new position update is sent.
  Stream<LatLng> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    // Permission checks are typically handled before subscribing to the stream
    // or can be added within this method if desired.
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  /// Calculates the geodesic distance between two geographic points in meters.
  double distanceBetween(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Clears the cached current position and its last update timestamp.
  void clearCache() {
    _cachedCurrentPosition = null;
    _lastLocationUpdate = null;
  }
}
