import 'package:example/constants.dart';
import 'package:flexible_location_picker/flexible_location_picker.dart';
import 'package:flutter/material.dart';

/// An example screen demonstrating how to use the location picker within a bottom sheet.
class BottomSheetExample extends StatelessWidget {
  /// Creates the [BottomSheetExample] screen.
  const BottomSheetExample({super.key});

  /// Displays the location picker as a modal bottom sheet.
  ///
  /// It configures the picker with a Google Places API key,
  /// search field, current location button, and an initial zoom level.
  /// After a location is selected, a [SnackBar] is shown with the selected address.
  void _showLocationPicker(BuildContext context) async {
    final result = await LocationPickerBottomSheet.show(
      context: context,
      config: LocationPickerConfig(
        googlePlacesApiKey:
            apiKey, // Your Google Places API key from constants.dart
        showSearchField: true, // Enable the search input field
        showCurrentLocationButton: true, // Display the "My Location" button
        initialZoom: 15.0, // Set the initial map zoom level
      ),
    );

    // If a location was selected (i.e., the bottom sheet wasn't dismissed),
    // display a SnackBar with the selected address.
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected location: ${result.address}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            // Button to trigger the display of the location picker bottom sheet.
            ElevatedButton(
              onPressed: () => _showLocationPicker(context),
              child: const Text("Show location picker"), // Button text
            ),
          ],
        ),
      ),
    );
  }
}
