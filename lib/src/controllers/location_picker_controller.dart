import 'dart:async';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_data.dart';
import '../models/location_picker_config.dart';
import '../services/location_service.dart';
import '../services/address_service.dart';

/// Controller for the location picker.
///
/// This class manages the state of the location picker, including the map,
/// user's current position, selected position, and search functionality.
class LocationPickerController extends ChangeNotifier {
  /// Creates a new [LocationPickerController].
  ///
  /// Requires a [LocationPickerConfig] to initialize services.
  LocationPickerController({required this.config}) {
    _addressService = AddressService(apiKey: config.googlePlacesApiKey);
  }

  /// Configuration for the location picker.
  final LocationPickerConfig config;

  /// Service to handle device location.
  final LocationService _locationService = LocationService.instance;

  /// Service to handle address lookups and searches.
  late final AddressService _addressService;

  /// Controller for the Google Map.
  GoogleMapController? _mapController;

  /// Timer for debouncing camera movements to avoid excessive API calls.
  Timer? _debounceTimer;

  /// Indicates if the native map is ready for commands.
  bool _isMapReady = false;

  /// Tracks if the initial location has already been set.
  bool _hasInitialLocationBeenSet = false;

  /// The user's current GPS position.
  LatLng? _currentPosition;

  /// The position currently selected at the center of the map.
  LatLng? _selectedPosition;

  /// The address data corresponding to the [_selectedPosition].
  LocationData? _selectedLocationData;

  /// Indicates if the controller is currently in a loading state.
  bool _isLoading = false;

  /// Indicates if the map camera is currently moving.
  bool _isMapMoving = false;

  /// Stores any error message that occurs.
  String? _error;

  /// A list of location data results from a search query.
  List<LocationData> _searchResults = [];

  /// Indicates if a search is currently in progress.
  bool _isSearching = false;

  /// The current search query string.
  String _searchQuery = '';

  // Getters
  GoogleMapController? get mapController => _mapController;
  LatLng? get currentPosition => _currentPosition;
  LatLng? get selectedPosition => _selectedPosition;
  LocationData? get selectedLocationData => _selectedLocationData;
  bool get isLoading => _isLoading;
  bool get isMapMoving => _isMapMoving;
  String? get error => _error;
  List<LocationData> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  /// Loads the user's current position.
  ///
  /// For the first load, it updates the position without animating the map,
  /// as the map will be positioned by its `initialCameraPosition`.
  /// For subsequent calls (e.g., "My Location" button), it animates the camera.
  Future<void> loadCurrentPosition() async {
    // If this is a user-triggered call AFTER the initial load.
    if (_hasInitialLocationBeenSet && !_isLoading) {
      await _loadAndAnimateToCurrentPosition(); // Use the method that animates.
      return;
    }

    // This is the first load, triggered by setMapController.
    _setLoading(true);
    _setError(null);

    try {
      final position = await _locationService.getCurrentPosition();
      _currentPosition = position;

      LatLng? targetPosition;
      if (position != null) {
        targetPosition = position;
      } else if (config.initialPosition != null) {
        targetPosition = config.initialPosition;
      } else {
        targetPosition = const LatLng(48.8566, 2.3522); // Default to Paris
      }

      _selectedPosition =
          targetPosition; // Update the selected position for the map.
      _hasInitialLocationBeenSet = true; // Mark the initial load as done.

      if (targetPosition != null) {
        await _loadAddressForPosition(
          targetPosition,
        ); // Load the address, which calls notifyListeners.
      }
      // VERY IMPORTANT: No call to animateCamera here for the first load.
      // The GoogleMap widget will use _selectedPosition for its initialCameraPosition.
    } on LocationServiceDisabledException {
      _setError('Please enable location services on your device.');
      // Optional: show a button to open location settings.
    } on LocationPermissionDeniedException {
      _setError('Location access denied. Please grant permission.');
      // Optional: show a button to request permission again.
    } on LocationPermissionPermanentlyDeniedException {
      _setError(
        'Location access permanently denied. Please enable it in the app settings.',
      );
      // Optional: show a button to open app settings.
    } on Exception catch (e) {
      // Catch the generic Exceptions thrown for timeout or unknown errors
      _setError(
        e.toString().replaceFirst('Exception: ', ''),
      ); // Clean up the message.
      debugPrint('Error caught in LocationPickerController: $e');
    } finally {
      _setLoading(false);
      notifyListeners(); // Notify to update loading state and map position.
    }
  }

  /// Internal method to load the current position and animate the map to it.
  ///
  /// Used for user-triggered movements after the initial load.
  Future<void> _loadAndAnimateToCurrentPosition() async {
    if (_mapController == null || !_isMapReady) {
      _setError('Map not initialized or not ready for animation.');
      return;
    }
    // _setLoading(true);
    _setError(null);

    try {
      final position = await _locationService.getCurrentPosition(
        forceRefresh: true,
      );
      if (position != null) {
        _currentPosition = position;
        _selectedPosition = position; // Update the selected position.
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(position, config.initialZoom),
        );
        await _loadAddressForPosition(
          position, // Load the address for the new position.
        );
      } else {
        _setError('Could not get the current position.');
      }
    } on LocationServiceDisabledException {
      _setError('Please enable location services on your device.');
    } on LocationPermissionDeniedException {
      _setError('Location access denied. Please grant permission.');
    } on LocationPermissionPermanentlyDeniedException {
      _setError(
        'Location access permanently denied. Please enable it in the app settings.',
      );
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      debugPrint('Error caught in _loadAndAnimateToCurrentPosition: $e');
    } finally {
      //_setLoading(false);
      notifyListeners();
    }
  }

  /// Sets the map controller. Called when the map is created and ready.
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true; // Indicate that the native map is ready.

    if (config.mapStyle != null) {
      controller.setMapStyle(config.mapStyle!);
    }

    // Trigger the initial position loading only once the map is ready
    // and if the initial position has not been set yet.
    if (!_hasInitialLocationBeenSet) {
      loadCurrentPosition(); // This call will NOT animate the camera on the first run.
    }
  }

  /// Called when the camera starts moving.
  void onCameraMove(CameraPosition position) {
    _isMapMoving = true;
    _selectedPosition = position.target;

    // Debounce the address loading to avoid too many API calls.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(config.debounceTime, () {
      _loadAddressForPosition(position.target);
    });

    notifyListeners();
  }

  /// Called when the camera stops moving.
  void onCameraIdle() {
    _isMapMoving = false;
    notifyListeners();
  }

  /// Loads the address for a given position.
  Future<void> _loadAddressForPosition(LatLng position) async {
    try {
      final locationData = await _addressService.getAddressFromCoordinates(
        position,
      );
      _selectedLocationData = locationData;
      notifyListeners(); // Notify listeners that address data has changed.
    } catch (e) {
      debugPrint('Error loading address: $e');
      // Optional: handle address lookup error, e.g., set a default address.
      _selectedLocationData = LocationData(
        position: position,
        address: 'Address not found',
      );
      notifyListeners();
    }
  }

  /// Public method to move the map to the user's current location.
  Future<void> goToCurrentLocation() => _loadAndAnimateToCurrentPosition();

  /// Searches for addresses based on a query.
  Future<void> searchAddresses(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await _addressService.searchAddresses(
        query,
        bias: _selectedPosition ?? _currentPosition,
        radius: config.searchRadius,
      );
      _searchResults = results;
    } catch (e) {
      debugPrint('Error searching addresses: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Selects an address from the search results.
  Future<void> selectSearchResult(LocationData locationData) async {
    if (_mapController == null || !_isMapReady) {
      _setError('Map not initialized or not ready.');
      return;
    }

    _searchResults = [];
    _searchQuery = '';
    _selectedLocationData = locationData;
    _selectedPosition = locationData.position;

    // Animate the camera to the selected location.
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(locationData.position, config.initialZoom),
    );

    notifyListeners();
  }

  /// Zooms in the map.
  Future<void> zoomIn() async {
    if (_mapController == null || !_isMapReady) return;
    await _mapController!.animateCamera(CameraUpdate.zoomIn());
  }

  /// Zooms out the map.
  Future<void> zoomOut() async {
    if (_mapController == null || !_isMapReady) return;
    await _mapController!.animateCamera(CameraUpdate.zoomOut());
  }

  /// Sets the loading state.
  void _setLoading(bool loading) {
    _isLoading = loading;
    // No notifyListeners() here. State updates are notified
    // after the full async operations complete.
  }

  /// Sets the error message.
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Resets the error message.
  void clearError() {
    _setError(null);
  }

  /// Clears the search results and query.
  void clearSearchResults() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancel the timer to prevent memory leaks.
    _debounceTimer?.cancel();
    super.dispose();
  }
}
