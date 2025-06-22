import 'package:flexible_location_picker/src/widgets/location_marker_widget.dart';
import 'package:flexible_location_picker/src/widgets/map_controls_widget.dart';
import 'package:flexible_location_picker/src/widgets/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/location_picker_controller.dart';
import '../models/location_data.dart';
import '../models/location_picker_config.dart';

/// A customizable Flutter widget for picking a location on a Google Map.
///
/// This widget integrates map display, search functionality, location tracking,
/// and customizable UI elements for a comprehensive location selection experience.
class LocationPickerWidget extends StatefulWidget {
  /// Creates a [LocationPickerWidget].
  const LocationPickerWidget({
    super.key,
    required this.onLocationSelected,
    this.config = const LocationPickerConfig(),
    this.height,
  });

  /// Callback function invoked when a location is confirmed by the user.
  final Function(LocationData) onLocationSelected;

  /// Configuration options to customize the appearance and behavior of the picker.
  final LocationPickerConfig config;

  /// Optional height for the widget. If null, it expands to fit its parent constraints.
  final double? height;

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget>
    with TickerProviderStateMixin {
  /// The controller managing the map's state, location logic, and interactions.
  late LocationPickerController _controller;

  /// Animation controller for the central location marker.
  late AnimationController _markerAnimationController;

  /// Animation that controls the scale of the central marker.
  late Animation<double> _markerAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the provided configuration.
    _controller = LocationPickerController(config: widget.config);

    // Set up the animation controller for the marker.
    _markerAnimationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    // Define the marker animation range (e.g., subtle bounce).
    _markerAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Listen to changes in the controller to trigger UI updates.
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // Clean up listeners and controllers to prevent memory leaks.
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  /// Callback for changes in the [LocationPickerController].
  ///
  /// Triggers a UI rebuild and controls the marker's animation based on map movement.
  void _onControllerChanged() {
    if (_controller.isMapMoving) {
      _markerAnimationController
          .forward(); // Animate marker forward when map moves
    } else {
      _markerAnimationController
          .reverse(); // Animate marker back when map stops
    }
    setState(
      () {},
    ); // Rebuilds the widget to reflect controller's state changes
  }

  /// Handles the confirmation of the selected location.
  ///
  /// Invokes the `onLocationSelected` callback with the current [LocationData].
  void _onConfirmLocation() {
    final locationData = _controller.selectedLocationData;
    if (locationData != null) {
      widget.onLocationSelected(locationData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine colors based on config or theme defaults.
    final primaryColor = widget.config.primaryColor ?? theme.primaryColor;
    final backgroundColor =
        widget.config.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Container(
      height: widget.height,
      color: backgroundColor,
      // Conditionally render based on controller's loading/error state.
      child: _controller.isLoading
          ? _buildLoadingState() // Show loading indicator
          : _controller.error != null
          ? _buildErrorState() // Show error message and retry button
          : _buildMapContent(primaryColor), // Show map and its controls
    );
  }

  /// Builds the UI for the loading state.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: widget.config.primaryColor),
          const SizedBox(height: 16),
          Text(
            widget.config.loadingText,
            style: TextStyle(color: widget.config.textColor),
          ),
        ],
      ),
    );
  }

  /// Builds the UI for the error state.
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            _controller.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _controller.clearError(); // Clear previous error
              // Re-attempt to load the current position.
              _controller.loadCurrentPosition();
            },
            child: Text(
              widget.config.currentLocationText,
            ), // Label for retry button
          ),
        ],
      ),
    );
  }

  /// Builds the main content of the map picker, including the Google Map,
  /// marker, search field, and map controls.
  Widget _buildMapContent(Color primaryColor) {
    // Determine the initial target for the map camera.
    // It prioritizes the selected position, then current, then initial config, then a default (Paris).
    final initialMapTarget =
        _controller.selectedPosition ??
        _controller.currentPosition ??
        widget.config.initialPosition ??
        const LatLng(48.8566, 2.3522); // Default to Paris

    return Stack(
      children: [
        // --- Google Map ---
        GoogleMap(
          // The initial camera position. The controller will later animate
          // to the actual user's location once ready. This avoids direct
          // `animateCamera` calls during initial map creation, preventing channel errors.
          initialCameraPosition: CameraPosition(
            target: initialMapTarget,
            zoom: widget.config.initialZoom,
          ),
          style: widget.config.mapStyle, // Custom map style from config
          onMapCreated: _controller
              .setMapController, // Assigns the GoogleMapController to our picker controller
          onCameraMove:
              _controller.onCameraMove, // Handles camera movement events
          onCameraIdle: _controller.onCameraIdle, // Handles camera stop events
          myLocationEnabled:
              widget.config.enableMyLocation &&
              _controller.currentPosition != null,
          myLocationButtonEnabled: false, // Hide default "My Location" button
          mapType: widget.config.getMapType(), // Use map type from config
          minMaxZoomPreference: MinMaxZoomPreference(
            widget.config.minZoom,
            widget.config.maxZoom,
          ),
          zoomControlsEnabled: false, // Hide default zoom controls
          mapToolbarEnabled: false, // Hide default map toolbar
        ),

        // --- Central Animated Marker ---
        Center(
          child: LocationMarkerWidget(
            animation: _markerAnimation,
            locationData: _controller.selectedLocationData,
            isMoving: _controller.isMapMoving,
            config: widget.config,
          ),
        ),

        // --- Search Field ---
        // Display the search field if configured.
        if (widget.config.showSearchField)
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                16, // Position below status bar
            left: 16,
            right: 16,
            child: SearchFieldWidget(
              controller: _controller,
              config: widget.config,
            ),
          ),

        // --- Map Controls (Zoom, Current Location) ---
        // Display map controls if configured.
        if (widget.config.showZoomControls ||
            widget.config.showCurrentLocationButton)
          Positioned(
            right: 16,
            // Position above confirm button if present, otherwise at the bottom.
            bottom: widget.config.showConfirmButton ? 80 : 16,
            child: MapControlsWidget(
              controller: _controller,
              config: widget.config,
            ),
          ),

        // --- Confirmation Button ---
        // Display the confirmation button if configured.
        if (widget.config.showConfirmButton)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildConfirmButton(primaryColor),
          ),
      ],
    );
  }

  /// Builds the confirmation button at the bottom of the picker.
  Widget _buildConfirmButton(Color primaryColor) {
    // Button is disabled if no location data has been selected/resolved.
    final isLoading = _controller.selectedLocationData == null;

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : _onConfirmLocation, // Button is enabled only if not loading
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white, // White spinner on button
              ),
            )
          : const Icon(Icons.check), // Check icon when ready
      label: Text(widget.config.confirmButtonText), // Text from config
      // Apply custom button style or default ElevatedButton style.
      style:
          widget.config.confirmButtonStyle ??
          ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            minimumSize: const Size(
              double.infinity,
              48,
            ), // Full width, fixed height
          ),
    );
  }
}
