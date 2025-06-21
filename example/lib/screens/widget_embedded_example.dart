import 'package:example/constants.dart';
import 'package:flexible_location_picker/flexible_location_picker.dart';
import 'package:flutter/material.dart';

/// An example screen demonstrating how to embed the location picker directly as a widget
/// within another Flutter widget tree.
class WidgetEmbeddedExample extends StatefulWidget {
  /// Creates the [WidgetEmbeddedExample] screen.
  const WidgetEmbeddedExample({super.key});

  @override
  State<WidgetEmbeddedExample> createState() => _WidgetEmbeddedExampleState();
}

class _WidgetEmbeddedExampleState extends State<WidgetEmbeddedExample> {
  /// Controls the visibility of the embedded [LocationPickerWidget].
  bool showEmbedded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Button to toggle the visibility of the embedded location picker.
            ElevatedButton(
              onPressed: () => setState(() => showEmbedded = !showEmbedded),
              child: const Text("Toggle embedded"),
            ),
            const SizedBox(height: 50),
            // Display the LocationPickerWidget only if 'showEmbedded' is true.
            if (showEmbedded)
              LocationPickerWidget(
                config: LocationPickerConfig(
                  googlePlacesApiKey:
                      apiKey, // Your Google Places API key from constants.dart
                  showSearchField: true, // Enable the search input field
                  showCurrentLocationButton:
                      true, // Display the "My Location" button
                  showConfirmButton:
                      false, // Hide the confirm button as it's embedded
                  initialZoom: 16.0, // Set the initial map zoom level
                ),
                // Callback function when a location is selected within the embedded picker.
                onLocationSelected: (locationData) {
                  print('Selected location: ${locationData.address}');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Selected location: ${locationData.address}',
                      ),
                    ),
                  );
                },
                height: 400, // Explicitly set height for the embedded widget
              ),
          ],
        ),
      ),
    );
  }
}
