import 'package:example/constants.dart';
import 'package:flexible_location_picker/flexible_location_picker.dart';
import 'package:flutter/material.dart';

/// An example screen demonstrating how to use the location picker as a full page.
class FullPageExample extends StatelessWidget {
  /// Creates the [FullPageExample] screen.
  const FullPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LocationPickerWidget(
        config: LocationPickerConfig(
          googlePlacesApiKey:
              apiKey, // Your Google Places API key from constants.dart
          showSearchField: true, // Enable the search input field
          showCurrentLocationButton: true, // Display the "My Location" button
          initialZoom: 15.0, // Set the initial map zoom level
        ),
        // When a location is selected within the picker, pop the result back to the previous screen.
        onLocationSelected: (locationData) {
          Navigator.pop(context, locationData);
        },
      ),
    );
  }
}
