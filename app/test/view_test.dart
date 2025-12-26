import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praisethesun/praisethesun.dart';
import 'package:provider/provider.dart';

import 'mock_data.dart';
import 'mock_sun_api.dart';

void main() {
  late SunLocationModel model;
  late MockSunApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockSunApiClient();

    model = SunLocationModel(apiClient: mockApiClient);

    model.setStartPoint(mockData['mockInitialCenter']);
  });

  Future<void> pumpMapWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SunLocationModel>.value(
          value: model,
          child: MessageHandler(
            child: Scaffold(
              body: FlutterMap(
                options: MapOptions(
                  initialCenter: mockData['mockInitialCenter'],
                  initialZoom: 10.0,
                ),
                children: [SearchCircleLayer(), SunMarkerLayer()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Map is initialized with a FindSunButton visible', (
    WidgetTester tester,
  ) async {
    await pumpMapWidget(tester);
    expect(find.byType(FindSunButton), findsOneWidget);
  });

  testWidgets(
    'Tapping FindSunButton starts search, tapping again stops search',
    (WidgetTester tester) async {
      await pumpMapWidget(tester);
      final findSunButton = find.byType(FindSunButton);

      expect(mockApiClient.hasActivePendingSearch, isFalse);
      expect(model.isSearching, isFalse);

      await tester.tap(findSunButton);
      await tester.pump();

      expect(mockApiClient.hasActivePendingSearch, isTrue);
      expect(model.isSearching, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(findSunButton);
      await tester.pump();

      expect(mockApiClient.hasActivePendingSearch, isFalse);
      expect(model.isSearching, isFalse);
      expect(model.sunLocations, isEmpty);
      expect(model.currentSearchRadius, equals(0));
    },
  );

  testWidgets('errors handled gracefully by displaying error in snackbar', (
    WidgetTester tester,
  ) async {
    await pumpMapWidget(tester);

    final findSunButton = find.byType(FindSunButton);
    await tester.tap(findSunButton);
    await tester.pump();

    mockApiClient.completeWithError(MockFailureType.serverError);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
    'The search radius indicator circle is displayed on the map during searching',
    (WidgetTester tester) async {
      await pumpMapWidget(tester);

      model.returnSunLocations(200);
      await tester.pump();

      expect(mockApiClient.hasActivePendingSearch, isTrue);
      expect(model.isSearching, isTrue);
      expect(model.currentSearchRadius, equals(200));

      final circleLayerWidget = tester.widget<CircleLayer>(
        find.byType(CircleLayer),
      );
      final circleMarker = circleLayerWidget.circles.first;

      expect(circleMarker.useRadiusInMeter, isTrue);
      expect(circleMarker.radius, equals(model.currentSearchRadius * 1000));
    },
  );

  testWidgets(
    'Sun location markers are built and visible in the map view when search returns sun location data from the api',
    (WidgetTester tester) async {
      await pumpMapWidget(tester);

      model.returnSunLocations(200);
      await tester.pump();

      mockApiClient.completePendingSearch(returnData: true);
      await tester.pumpAndSettle();

      final markerLayerWidget = tester.widget<MarkerLayer>(
        find.byType(MarkerLayer),
      );

      final allMarkers = markerLayerWidget.markers;
      final sunMarkers = allMarkers
          .where((marker) => marker.child is SunMarkerButton)
          .toList();

      final int expectedSunMarkerCount = mockData['mockSunLocations'].length;
      expect(sunMarkers.length, equals(expectedSunMarkerCount));

      expect(
        sunMarkers[0].point.latitude,
        equals(mockData['mockSunLocations'][0].latitude),
      );
      expect(
        sunMarkers[0].point.longitude,
        equals(mockData['mockSunLocations'][0].longitude),
      );
    },
  );
}
