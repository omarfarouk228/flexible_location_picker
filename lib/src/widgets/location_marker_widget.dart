import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../models/location_picker_config.dart';

/// A widget that displays a customizable map marker with an optional address bubble.
///
/// The marker can animate based on the provided [animation] and
/// change appearance based on whether the map is currently moving.
class LocationMarkerWidget extends StatelessWidget {
  /// Creates a [LocationMarkerWidget].
  const LocationMarkerWidget({
    super.key,
    required this.animation,
    this.locationData,
    required this.isMoving,
    required this.config,
  });

  /// The animation controller for scaling the marker.
  final Animation<double> animation;

  /// The [LocationData] to display in the address bubble. If null, no bubble is shown.
  final LocationData? locationData;

  /// A boolean indicating if the map is currently being moved by the user.
  /// Affects the marker's appearance (e.g., opacity).
  final bool isMoving;

  /// The configuration for the location picker, providing styling options for the marker.
  final LocationPickerConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine the marker color, using config.markerColor if provided, otherwise theme's primary color.
    final markerColor = config.markerColor ?? theme.primaryColor;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Apply a scale transformation based on the animation's current value.
        return Transform.scale(
          scale: animation.value,
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Ensures the column only takes up necessary vertical space.
            children: [
              // --- Address Bubble ---
              // Display the address bubble only if locationData is available.
              if (locationData != null)
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 250,
                  ), // Constrain the bubble's width.
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87, // Dark background for the bubble.
                    borderRadius: BorderRadius.circular(12), // Rounded corners.
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    locationData!.address, // Display the formatted address.
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Limit text to 2 lines.
                    overflow: TextOverflow
                        .ellipsis, // Add ellipsis if text overflows.
                  ),
                ),

              // Add vertical spacing between the bubble and the icon if the bubble is shown.
              if (locationData != null) const SizedBox(height: 4),

              // --- Location Icon ---
              Icon(
                Icons.location_pin, // The pin icon for the marker.
                size: 40, // Size of the icon.
                // Adjust color opacity based on whether the map is moving, creating a subtle animation.
                color: isMoving ? markerColor.withOpacity(0.8) : markerColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
