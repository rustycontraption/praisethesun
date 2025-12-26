# Praise the Sun 🌞

This Flutter application started as a simple need to see the sun during the long, dark winters in my hometown of Seattle.  I wanted to keep the app as simple as possible; just tap anywhere on the map to start a search for the nearest location with sun.  At first this seemed like a simple proposition but proved interesting and complex, from managing the high number of API calls required to defining what "nearest location" even means.

## Features

- **Interactive Map**: Built with `flutter_map` for smooth map interactions
- **Location Search**: Tap any point on the map to set a search starting point
- **Expanding Search**: Automatic search with increasing radius to find sun locations
- **Real-time Updates**: Live updates of search progress with visual feedback
- **Animated Markers**: Smooth animations for map markers and search circles
- **Error Handling**: Robust error handling with user-friendly messages
- **Cross-platform**: Supports Android, iOS, and Web

## Architecture

### Core Components

- **SunLocationModel**: State management using Provider pattern for location data and search state
- **SunApiClient**: HTTP client using Dio for API communication with backend services
- **Interactive Map Widgets**: Modular map components including markers, circles, and search controls
- **Logging System**: Comprehensive logging for debugging and monitoring

### Key Dependencies

- `flutter_map` - Interactive map widget
- `provider` - State management
- `dio` - HTTP client for API calls
- `latlong2` - Geographic coordinate handling
- `flutter_map_animations` - Smooth map animations
- `logging` - Application logging

## Getting Started with Local Development

### Prerequisites

- Flutter SDK (>=3.9.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Backend API service running (default: `http://10.0.2.2:8000/sun/`)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rustycontraption/praisethesun.git
   cd praisethesun
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure the backend API** (if different from default):
   - Update the `sunAPIUrl` in `lib/src/model/sun_api_client.dart`
   - Default points to `http://10.0.2.2:8000/sun/` (Android emulator localhost)

4. **Run the application**:
   ```bash
   flutter run
   ```

## Development

### Project Structure

```
lib/
├── main.dart                     # App entry point
├── src/
    ├── app.dart                  # Main app widget
    ├── model/
    │   ├── model.dart            # Core data model and state management
    │   └── sun_api_client.dart   # API client for backend communication
    ├── services/
    │   ├── sun_logging.dart      # Logging configuration
    │   └── system_message_handler.dart
    ├── widgets/
    │   ├── circle_layer.dart     # Map circle overlays
    │   ├── find_sun_button.dart  # Search control button
    │   ├── map.dart              # Main map widget
    │   ├── marker_layer.dart     # Map marker management
    │   ├── snackbar_message.dart # User notifications
    │   └── sun_marker.dart       # Custom map markers
```

### Running Tests

```bash
# Run unit tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## API Integration

The app communicates with a backend service that provides sun location data:

- **Endpoint**: `/sun/`
- **Parameters**: 
  - `start_point_lat`: Starting latitude
  - `start_point_lng`: Starting longitude
  - `search_radius_km`: Search radius in kilometers
- **Response**: Array of latitude/longitude coordinates

### API Client Features

- Configurable timeout settings
- Request cancellation support
- Comprehensive error handling
- Automatic retry logic

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for consistent formatting
- Run `dart analyze` to check for issues

## License

This project is licensed under the MIT License.

## Acknowledgments
- Map tile data from [OpenStreetMap](https://www.openstreetmap.org/)
- Weather data from [Open-Meteo](https://open-meteo.com/)
- Built with [Flutter](https://flutter.dev/)
- Map functionality powered by [flutter_map](https://pub.dev/packages/flutter_map)
- State management with [Provider](https://pub.dev/packages/provider)
- Network requests via [Dio](https://pub.dev/packages/dio)
