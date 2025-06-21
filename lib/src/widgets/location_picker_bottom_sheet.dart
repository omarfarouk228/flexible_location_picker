import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../models/location_picker_config.dart';
import 'location_picker_widget.dart';

/// A utility class to display the location picker within a modal bottom sheet.
class LocationPickerBottomSheet {
  /// Shows the location picker as a modal bottom sheet.
  ///
  /// [context]: The BuildContext to display the bottom sheet over.
  /// [config]: Configuration options for the underlying [LocationPickerWidget].
  /// [height]: Optional height for the bottom sheet. Defaults to 80% of screen height.
  /// [isDismissible]: Whether the bottom sheet can be dismissed by tapping outside of it.
  /// [enableDrag]: Whether the bottom sheet can be dismissed by dragging it down.
  ///
  /// Returns a [Future] that resolves to the selected [LocationData]
  /// when the user confirms their selection, or `null` if dismissed.
  static Future<LocationData?> show({
    required BuildContext context,
    LocationPickerConfig config = const LocationPickerConfig(),
    double? height,
    bool isDismissible = true,
    bool enableDrag = false,
  }) async {
    return showModalBottomSheet<LocationData>(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take full screen height
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor:
          Colors.transparent, // Ensures the rounded corners are visible
      builder: (context) =>
          LocationPickerBottomSheetContent(config: config, height: height),
    );
  }
}

/// The content widget for the [LocationPickerBottomSheet].
///
/// It wraps the [LocationPickerWidget] and adds typical bottom sheet UI elements
/// like a draggable handle, title, and close button.
class LocationPickerBottomSheetContent extends StatelessWidget {
  /// Creates a [LocationPickerBottomSheetContent].
  const LocationPickerBottomSheetContent({
    super.key,
    required this.config,
    this.height,
  });

  /// The configuration for the location picker.
  final LocationPickerConfig config;

  /// The desired height for the bottom sheet.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate the actual height of the bottom sheet, defaulting to 80% of screen height.
    final bottomSheetHeight = height ?? screenHeight * 0.8;

    return Container(
      height: bottomSheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white, // Background color of the bottom sheet content
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ), // Rounded top corners
      ),
      child: Column(
        children: [
          // --- Bottom Sheet Handle ---
          // A visual indicator that the bottom sheet can be dragged.
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // Color of the handle
              borderRadius: BorderRadius.circular(
                2,
              ), // Rounded corners for the handle
            ),
          ),

          // --- Title and Close Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select a Location', // Title of the bottom sheet
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // Closes the bottom sheet
                  icon: const Icon(Icons.close), // Close icon
                ),
              ],
            ),
          ),

          const Divider(height: 1), // Separator line below the title
          // --- Location Picker Widget ---
          // The core location selection functionality.
          Expanded(
            child: LocationPickerWidget(
              // Ensure the confirm button is shown within the bottom sheet context.
              config: config.copyWith(showConfirmButton: true),
              // When a location is selected within the picker, pop the result back.
              onLocationSelected: (locationData) {
                Navigator.of(context).pop(locationData);
              },
            ),
          ),
        ],
      ),
    );
  }
}
