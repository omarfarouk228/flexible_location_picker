[![pub](https://img.shields.io/pub/v/flexible_location_picker?label=pub&logo=dart)](https://pub.dev/packages/flexible_location_picker/install) [![stars](https://img.shields.io/github/stars/omarfarouk228/flexible_location_picker?logo=github)](https://github.com/omarfarouk228/flexible_location_picker) [![issues](https://img.shields.io/github/issues/omarfarouk228/flexible_location_picker?logo=github)](https://github.com/omarfarouk228/flexible_location_picker/issues) [![commit](https://img.shields.io/github/last-commit/omarfarouk228/flexible_location_picker?logo=github)](https://github.com/omarfarouk228/flexible_location_picker/commits) <a href="https://codecov.io/gh/omarfarouk228/flexible_location_picker"><img src="https://codecov.io/gh/omarfarouk228/flexible_location_picker/branch/master/graph/badge.svg" alt="code coverage"></a>
  <a href="https://github.com/omarfarouk228#sponsor-me"><img src="https://img.shields.io/github/sponsors/omarfarouk228" alt="Sponsoring"></a>
  <a href="https://pub.dev/packages/flexible_location_picker/score"><img src="https://img.shields.io/pub/likes/flexible_location_picker" alt="likes"></a>
  <a href="https://pub.dev/packages/flexible_location_picker/score"><img src="https://img.shields.io/pub/points/flexible_location_picker" alt="pub points"></a>

<p align="center">
  <img src="https://github.com/user-attachments/assets/d3807b97-c25e-4d2f-a64a-418dc197ebdb" height="100" alt="Flutter Favorite" />
</p>

# Flexible Location Picker

A powerful, highly customizable, and performant Flutter package for location and address selection on a map. It offers a seamless user experience with search autocomplete, real-time geolocation, and flexible integration options.

## ✨ Features

- **Flexible Integration:** Embed the picker as a full page, a modal bottom sheet, or an integrated widget within any part of your UI.
- **Intuitive Address Search:** Fast and accurate address autocomplete powered by Google Places API.
- **Precise Geolocation:** Detects current device location with caching for optimal performance and robust error handling.
- **Animated Map Marker:** Smooth animations for the central map marker provide clear visual feedback during map interaction.
- **Customizable Map Controls:** Includes configurable zoom controls and a "My Location" button.
- **Performance Optimized:**
  - **Caching:** Caches location and address data to minimize redundant API calls.
  - **Debouncing:** Implements debouncing for search queries to prevent excessive API requests.
  - **Efficient Filtering:** Limits search results for responsiveness.
- **Granular Configuration:** Extensive options via `LocationPickerConfig` to customize colors, texts, map types, and behavior.
- **Clean Architecture:** Built with a modular structure, separating concerns with dedicated services (`LocationService`, `AddressService`) and a central `ChangeNotifier`-based controller for state management.
- **User-Friendly Error Handling:** Clear messages for location service issues, permission denials, and search errors.

## 📸 Demo : [See full demo](https://ofaroukk.com/demos/location_picker.gif)

<img src="https://github.com/user-attachments/assets/aeb1c01f-108e-458c-9661-a2d6d6dd34ac"  width="300">
&nbsp;&nbsp;&nbsp;
<img width="300" src="https://github.com/user-attachments/assets/4be32de1-4a61-4a26-aacc-dc84680c833a" />
&nbsp;&nbsp;&nbsp;
<img width="300" src="https://github.com/user-attachments/assets/628c4d73-7305-4a55-90c9-679d07543886" />
&nbsp;&nbsp;&nbsp;
<img width="300" src="https://github.com/user-attachments/assets/669259aa-2102-4eda-a2ef-1814d5a08245" />

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flexible_location_picker: ^latest_version # Replace with the actual latest version
```

Then, run `flutter pub get`.

**Important: API Key Setup**

To use Google Maps and Places API functionalities, you **must** obtain an API key from the Google Cloud Platform and enable the following APIs:

- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Places API**
- **Geocoding API** (used for reverse geocoding LatLng to address)

**Configure your API Key:**

- **Android (`android/app/src/main/AndroidManifest.xml`):**
  Place your API key inside the `<application>` tag:

  ```xml
  <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_Maps_API_KEY" />
  ```

  **Crucial:** Apply **Android app restrictions** to your API key in the Google Cloud Console, including your app's package name and SHA-1 certificate fingerprint.

- **iOS (`ios/Runner/AppDelegate.swift` or `AppDelegate.m`):**
  Add the API key before `GeneratedPluginRegistrant.register`:

  ```swift
  // AppDelegate.swift
  import GoogleMaps // Don't forget this import

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      GMSServices.provideAPIKey("YOUR_Maps_API_KEY")
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  ```

  **Crucial:** Apply **iOS app restrictions** to your API key in the Google Cloud Console, using your app's Bundle ID.

- **Pass API Key to `LocationPickerConfig`:**
  You must pass your Google Places API key directly to the `LocationPickerConfig` for the search functionality:

  ```dart
  LocationPickerWidget(
    config: LocationPickerConfig(
      googlePlacesApiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
      // ... other configurations
    ),
    // ...
  )
  ```

## 💻 Usage

The `flexible_location_picker` offers three primary integration modes:

### 1\. As a Full Page

```dart
import 'package:flexible_location_picker/flexible_location_picker.dart';
import 'package:flutter/material.dart';

class MyLocationSelectionPage extends StatelessWidget {
  const MyLocationSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LocationPickerWidget(
        config: LocationPickerConfig(
          googlePlacesApiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
          showSearchField: true,
          showCurrentLocationButton: true,
          initialZoom: 15.0,
          confirmButtonText: 'Select This Place', // Customize button text
          // ... more configurations
        ),
        onLocationSelected: (locationData) {
          // Handle the selected location data
          Navigator.pop(context, locationData); // Pop the page with the result
          print('Selected Location: ${locationData.address}');
        },
      ),
    );
  }
}

// To open this page:
// final selectedLocation = await Navigator.push<LocationData?>(
//   context,
//   MaterialPageRoute(builder: (context) => const MyLocationSelectionPage()),
// );
// if (selectedLocation != null) { /* Do something with selectedLocation */ }
```

### 2\. As a Modal Bottom Sheet

```dart
import 'package:flexible_location_picker/flexible_location_picker.dart';
import 'package:flutter/material.dart';

// To show as a modal bottom sheet:
Future<void> _showLocationPickerBottomSheet(BuildContext context) async {
  final selectedLocation = await LocationPickerBottomSheet.show(
    context: context,
    height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
    isDismissible: true,
    enableDrag: true,
    config: LocationPickerConfig(
      googlePlacesApiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
      showSearchField: true,
      showCurrentLocationButton: true,
      initialZoom: 16.0,
      confirmButtonText: 'Confirm Selection',
      // ... more configurations
    ),
  );

  if (selectedLocation != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location selected: ${selectedLocation.address}')),
    );
  }
}

// Call this from a button or wherever needed:
// ElevatedButton(
//   onPressed: () => _showLocationPickerBottomSheet(context),
//   child: const Text('Pick Location (Bottom Sheet)'),
// )
```

### 3\. As an Integrated Widget

```dart
import 'package:flexible_location_picker/flexible_location_picker.dart';
import 'package:flutter/material.dart';

class MyEmbeddedPicker extends StatefulWidget {
  const MyEmbeddedPicker({super.key});

  @override
  State<MyEmbeddedPicker> createState() => _MyEmbeddedPickerState();
}

class _MyEmbeddedPickerState extends State<MyEmbeddedPicker> {
  LocationData? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Optionally display current selection
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Current Pick: ${_selectedLocation!.address}'),
          ),
        Expanded( // Or provide a fixed height like height: 400
          child: LocationPickerWidget(
            config: LocationPickerConfig(
              googlePlacesApiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
              showSearchField: true,
              showCurrentLocationButton: true,
              showConfirmButton: false, // Often hidden when embedded
              initialZoom: 14.0,
              // ... more configurations
            ),
            onLocationSelected: (locationData) {
              setState(() {
                _selectedLocation = locationData;
              });
              print('Embedded picker selected: ${locationData.address}');
            },
          ),
        ),
      ],
    );
  }
}
```

## ⚙️ Configuration

The `LocationPickerConfig` class provides extensive customization options:

```dart
LocationPickerConfig(
  // API Key
  googlePlacesApiKey: 'YOUR_GOOGLE_PLACES_API_KEY', // Required for search

  // Map Initial State
  initialPosition: const LatLng(34.0522, -118.2437), // Los Angeles default
  initialZoom: 15.0,
  minZoom: 2.0,
  maxZoom: 20.0,
  mapType: 'normal', // 'normal', 'satellite', 'hybrid', 'terrain'
  mapStyle: '[{"featureType":"poi", "stylers":[{"visibility":"off"}]}]', // JSON style string

  // Feature Visibility
  showSearchField: true,
  showCurrentLocationButton: true,
  showConfirmButton: true,
  showZoomControls: true,
  enableMyLocation: true, // Shows blue dot for current location

  // Text Customization
  confirmButtonText: 'Select Location',
  searchHintText: 'Enter address or drag map...',
  loadingText: 'Fetching location...',
  errorText: 'Failed to load location.',
  noLocationText: 'Location not found.',
  currentLocationText: 'Use Current Location',

  // Style Customization
  markerColor: Colors.deepOrange,
  primaryColor: Colors.blue, // Primary accent color
  backgroundColor: Colors.white,
  textColor: Colors.black87,
  searchFieldDecoration: const InputDecoration( // Custom InputDecoration for search field
    filled: true,
    fillColor: Colors.white,
    hintText: 'Search...',
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
  ),
  confirmButtonStyle: ElevatedButton.styleFrom( // Custom ButtonStyle for confirm button
    backgroundColor: Colors.blueAccent,
    foregroundColor: Colors.white,
  ),

  // Performance & Animation
  debounceTime: const Duration(milliseconds: 800), // Delay for reverse geocoding after map move
  animationDuration: const Duration(milliseconds: 300), // Marker animation duration
  searchRadius: 50000, // Search bias radius in meters (50 km)
  // autoCompleteSessionToken: 'custom_session_token', // Advanced: for billing optimization if managing manually
)
```

## 🛠️ Advanced Usage

### Custom Map Styling

You can provide a JSON string to `mapStyle` in `LocationPickerConfig` for granular control over map appearance. Generate styles using [Google Cloud's styling wizard](https://mapstyle.withgoogle.com/).

### Billing Optimization with Session Tokens

The package internally generates session tokens for Google Places API calls (`autocomplete` and `getDetailsByPlaceId`) to ensure optimal billing (a session counts as one billable transaction). You generally do not need to manage `autoCompleteSessionToken` manually unless you have a specific advanced use case.

### Error Handling

The `LocationPickerController` provides detailed error messages accessible via `controller.error`. Your UI (like `_buildErrorState` in `LocationPickerWidget`) can leverage these messages to inform users about permission issues, disabled location services, or API errors.

## 🏃 Example

Explore the `/example` folder in the repository for a complete demonstration of all features and integration types.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

Remember to configure your Google Maps API key in the `example/constants.dart` file and the Android/iOS native project files as described in the Installation section.

## 🤝 Contributing

Contributions are warmly welcome\! If you have ideas for improvements, new features, or bug fixes, please feel free to open an issue or submit a Pull Request.

1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/your-awesome-feature`)
3.  Commit your changes (`git commit -m 'feat: Add some awesome feature'`)
4.  Push to the branch (`git push origin feature/your-awesome-feature`)
5.  Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

## 🧑‍💻 About the Author

Created by [Omar Farouk](https://github.com/omarfarouk228)
