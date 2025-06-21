import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Configuration options for the `LocationPickerWidget`.
///
/// This class allows you to customize the appearance, behavior, and text
/// displayed within the location picker.
class LocationPickerConfig {
  /// Creates a [LocationPickerConfig] instance.
  const LocationPickerConfig({
    this.googlePlacesApiKey,
    this.initialPosition,
    this.initialZoom = 16.0,
    this.minZoom = 2.0,
    this.maxZoom = 20.0,
    this.showSearchField = true,
    this.showCurrentLocationButton = true,
    this.showConfirmButton = true,
    this.showZoomControls = true,
    this.enableMyLocation = true,
    this.mapType = 'normal',
    this.confirmButtonText = 'Confirm',
    this.searchHintText = 'Search for an address...',
    this.loadingText = 'Loading map...',
    this.errorText = 'Error loading map',
    this.noLocationText = 'Location not available',
    this.currentLocationText = 'My Location',
    this.markerColor,
    this.primaryColor,
    this.backgroundColor,
    this.textColor,
    this.searchFieldDecoration,
    this.confirmButtonStyle,
    this.mapStyle,
    this.debounceTime = const Duration(milliseconds: 500),
    this.animationDuration = const Duration(milliseconds: 300),
    this.searchRadius = 50000, // Default 50km radius for search biasing
    this.autoCompleteSessionToken,
  });

  // --- API Key ---
  /// Your Google Places API key, required for address search functionality.
  final String? googlePlacesApiKey;

  // --- Map Positioning and Zoom ---
  /// The initial geographic position where the map camera will be placed.
  final LatLng? initialPosition;

  /// The initial zoom level of the map.
  final double initialZoom;

  /// The minimum zoom level allowed on the map.
  final double minZoom;

  /// The maximum zoom level allowed on the map.
  final double maxZoom;

  /// The type of map to display.
  /// Valid values are 'normal', 'satellite', 'hybrid', 'terrain'.
  final String mapType;

  /// Custom JSON style string for the map.
  /// See Google Maps Platform documentation for style JSON format.
  final String? mapStyle;

  // --- Feature Visibility Controls ---
  /// Whether to display the search input field.
  final bool showSearchField;

  /// Whether to display the button to center the map on the current location.
  final bool showCurrentLocationButton;

  /// Whether to display the confirmation button at the bottom.
  final bool showConfirmButton;

  /// Whether to display the zoom in/out controls.
  final bool showZoomControls;

  /// Whether to enable the display of the user's current location dot on the map.
  /// Requires location permissions.
  final bool enableMyLocation;

  // --- Text Customization ---
  /// The text displayed on the confirmation button.
  final String confirmButtonText;

  /// The hint text displayed in the search input field.
  final String searchHintText;

  /// The text displayed while the map or location data is loading.
  final String loadingText;

  /// The text displayed when an error occurs during loading.
  final String errorText;

  /// The text displayed when the user's location is not available.
  final String noLocationText;

  /// The text displayed on the "My Location" button.
  final String currentLocationText;

  // --- Style Customization ---
  /// The color of the central marker on the map.
  final Color? markerColor;

  /// The primary color used for accents (e.g., loading indicators, default button color).
  final Color? primaryColor;

  /// The background color of the widget container.
  final Color? backgroundColor;

  /// The default text color for various labels within the widget.
  final Color? textColor;

  /// Custom decoration for the search input field.
  final InputDecoration? searchFieldDecoration;

  /// Custom style for the confirmation button.
  final ButtonStyle? confirmButtonStyle;

  // --- Performance & Animation ---
  /// The duration to wait after a camera movement before performing a reverse geocoding lookup.
  final Duration debounceTime;

  /// The duration for various animations within the picker, like marker movement.
  final Duration animationDuration;

  /// The search radius in meters to bias place autocomplete results towards a location.
  final double searchRadius;

  /// A session token for Google Places Autocomplete API, used for billing optimization.
  /// It should be generated per user search session.
  final String? autoCompleteSessionToken;

  /// Creates a new [LocationPickerConfig] instance with updated values.
  ///
  /// You can provide new values for any of the fields. If a field is not
  /// provided, its value from the current instance will be used.
  LocationPickerConfig copyWith({
    String? googlePlacesApiKey,
    LatLng? initialPosition,
    double? initialZoom,
    double? minZoom,
    double? maxZoom,
    MapType? mapType, // This parameter is now of type MapType
    String? mapStyle,
    bool? showSearchField,
    bool? showCurrentLocationButton,
    bool? showConfirmButton,
    bool? showZoomControls,
    bool? enableMyLocation,
    String? confirmButtonText,
    String? searchHintText,
    String? loadingText,
    String? errorText,
    String? noLocationText,
    String? currentLocationText,
    Color? markerColor,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    InputDecoration? searchFieldDecoration,
    ButtonStyle? confirmButtonStyle,
    Duration? debounceTime,
    Duration? animationDuration,
    double? searchRadius,
    String? autoCompleteSessionToken,
  }) {
    return LocationPickerConfig(
      googlePlacesApiKey: googlePlacesApiKey ?? this.googlePlacesApiKey,
      initialPosition: initialPosition ?? this.initialPosition,
      initialZoom: initialZoom ?? this.initialZoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      mapType: mapType != null
          ? _mapTypeToString(mapType)
          : this.mapType, // Convert MapType back to String
      mapStyle: mapStyle ?? this.mapStyle,
      showSearchField: showSearchField ?? this.showSearchField,
      showCurrentLocationButton:
          showCurrentLocationButton ?? this.showCurrentLocationButton,
      showConfirmButton: showConfirmButton ?? this.showConfirmButton,
      showZoomControls: showZoomControls ?? this.showZoomControls,
      enableMyLocation: enableMyLocation ?? this.enableMyLocation,
      confirmButtonText: confirmButtonText ?? this.confirmButtonText,
      searchHintText: searchHintText ?? this.searchHintText,
      loadingText: loadingText ?? this.loadingText,
      errorText: errorText ?? this.errorText,
      noLocationText: noLocationText ?? this.noLocationText,
      currentLocationText: currentLocationText ?? this.currentLocationText,
      markerColor: markerColor ?? this.markerColor,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      searchFieldDecoration:
          searchFieldDecoration ?? this.searchFieldDecoration,
      confirmButtonStyle: confirmButtonStyle ?? this.confirmButtonStyle,
      debounceTime: debounceTime ?? this.debounceTime,
      animationDuration: animationDuration ?? this.animationDuration,
      searchRadius: searchRadius ?? this.searchRadius,
      autoCompleteSessionToken:
          autoCompleteSessionToken ?? this.autoCompleteSessionToken,
    );
  }

  /// Converts the string [mapType] to a [Maps_flutter.MapType] enum.
  ///
  /// Returns [MapType.normal] by default if the string does not match.
  MapType getMapType() {
    switch (mapType) {
      case 'satellite':
        return MapType.satellite;
      case 'terrain':
        return MapType.terrain;
      case 'hybrid':
        return MapType.hybrid;
      default:
        return MapType.normal;
    }
  }

  /// Internal helper to convert MapType enum to its string representation.
  String _mapTypeToString(MapType mapType) {
    switch (mapType) {
      case MapType.satellite:
        return 'satellite';
      case MapType.terrain:
        return 'terrain';
      case MapType.hybrid:
        return 'hybrid';
      case MapType.normal:
      default:
        return 'normal';
    }
  }
}
