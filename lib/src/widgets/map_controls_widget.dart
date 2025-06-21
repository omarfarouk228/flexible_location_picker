import 'package:flutter/material.dart';
import '../controllers/location_picker_controller.dart';
import '../models/location_picker_config.dart';

/// A widget that displays map control buttons, such as zoom in/out and current location.
///
/// These controls are typically positioned over the map and interact with the
/// [LocationPickerController] to perform actions.
class MapControlsWidget extends StatelessWidget {
  /// Creates a [MapControlsWidget].
  const MapControlsWidget({
    super.key,
    required this.controller,
    required this.config,
  });

  /// The controller managing the map's state and actions.
  final LocationPickerController controller;

  /// The configuration for the location picker, dictating which controls to show.
  final LocationPickerConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize
          .min, // Ensures the column only takes up needed vertical space
      children: [
        // --- Zoom Controls ---
        // Display zoom in/out buttons if configured to do so.
        if (config.showZoomControls) ...[
          FloatingActionButton.small(
            backgroundColor: Colors.white,
            heroTag:
                'zoom_in', // Unique tag for hero animations, important when multiple FABs are present
            onPressed:
                controller.zoomIn, // Calls the zoomIn method on the controller
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8), // Spacing between buttons
          FloatingActionButton.small(
            backgroundColor: Colors.white,
            heroTag: 'zoom_out', // Unique tag for hero animations
            onPressed: controller
                .zoomOut, // Calls the zoomOut method on the controller
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8), // Spacing after zoom controls
        ],

        // --- Current Location Button ---
        // Display the "My Location" button if configured and if a current position is available.
        if (config.showCurrentLocationButton &&
            controller.currentPosition != null)
          FloatingActionButton.small(
            backgroundColor: Colors.white,
            heroTag: 'current_location', // Unique tag for hero animations
            onPressed: controller
                .goToCurrentLocation, // Calls the goToCurrentLocation method on the controller
            // Show a loading indicator if the controller is currently loading location data,
            // otherwise display the "my location" icon.
            child: controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ), // Loading indicator
                  )
                : const Icon(Icons.my_location), // Default icon
          ),
      ],
    );
  }
}
