import 'package:example/screens/bottom_sheet_example.dart';
import 'package:example/screens/full_page_example.dart';
import 'package:example/screens/widget_embedded_example.dart';
import 'package:flutter/material.dart';

/// The entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates the root widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Picker Example', // Title for the application
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ), // Define the app's color scheme
      ),
      home: const PickerExample(), // Set the initial screen
    );
  }
}

/// A screen demonstrating different ways to integrate the location picker.
class PickerExample extends StatelessWidget {
  /// Creates the picker example screen.
  const PickerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center widgets vertically
          spacing:
              10, // Spacing between children (note: `spacing` is not a standard `Column` property, consider `SizedBox` for spacing)
          children: [
            // --- Widget Embedded Example ---
            // Button to navigate to a screen where the location picker is embedded directly as a widget.
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WidgetEmbeddedExample(),
                ),
              ),
              child: const Text('Widget embedded'), // Button text
            ),

            // --- Full Page Embedded Example ---
            // Button to navigate to a screen where the location picker takes up a full page.
            ElevatedButton(
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FullPageExample(),
                    ),
                  ).then((locationData) {
                    // After the full page picker returns, show a Snackbar with the selected location.
                    if (locationData != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selected location: ${locationData.address}', // Display selected address
                          ),
                        ),
                      );
                    }
                  }),
              child: const Text('Page embedded'), // Button text
            ),

            // --- Bottom Sheet/Dialog Embedded Example ---
            // Button to navigate to a screen demonstrating the location picker within a bottom sheet (labeled as dialog here).
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomSheetExample(),
                ),
              ),
              child: const Text('Dialog embedded'), // Button text
            ),
          ],
        ),
      ),
    );
  }
}
