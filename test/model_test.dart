import 'package:flutter_test/flutter_test.dart';
import 'package:praisethesun/src/model/model.dart';

import 'mock_data.dart';
import 'mock_sun_api.dart';

void main() {
  group('SunLocationModel', () {
    late SunLocationModel model;
    late MockSunApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockSunApiClient();
      model = SunLocationModel(apiClient: mockApiClient);
    });

    test('initial state is correct', () {
      expect(model.startPoint.latitude, 47.60621);
      expect(model.startPoint.longitude, -122.33207);
      expect(model.sunLocations, isEmpty);
      expect(model.isSearching, false);
      expect(model.currentSearchRadius, 0);
    });

    group('returnSunLocations', () {
      final int searchRadius = 100;
      test(
        'the model updates correctly as the search radius increases',
        () async {
          // First iteration
          model.returnSunLocations(searchRadius);
          await Future.delayed(Duration.zero);

          expect(model.currentSearchRadius, searchRadius);

          mockApiClient.completePendingSearch(returnData: false);
          await Future.delayed(Duration.zero);

          // Second iteration
          expect(model.currentSearchRadius, searchRadius + 100);

          // Complete the second search to avoid hanging
          mockApiClient.cancelPendingSearch();
        },
      );

      test('successfully returns sun locations and updates state', () async {
        final future = model.returnSunLocations(100);
        await Future.delayed(Duration.zero);

        mockApiClient.completePendingSearch(returnData: true);
        await future;

        expect(model.isSearching, false);
        expect(model.sunLocations, equals(mockData['mockSunLocations']));
      });

      test('stops search when radius reaches a set upper limit', () async {
        await model.returnSunLocations(1000);

        expect(model.isSearching, false);
        expect(model.currentSearchRadius, equals(0));
        expect(model.sunLocations, isEmpty);
      });

      test('handles errors properly', () async {
        final future = model.returnSunLocations(100);
        await Future.delayed(Duration.zero);

        mockApiClient.completeWithError(MockFailureType.serverError);
        await future;

        expect(model.isSearching, false);
        expect(model.currentSearchRadius, 0);
        expect(model.sunLocations, isEmpty);
        expect(model.errorMessage, isNotNull);
      });

      test('notifies listeners on state changes', () async {
        var notificationCount = 0;
        model.addListener(() {
          notificationCount++;
        });

        final future = model.returnSunLocations(100);
        await Future.delayed(Duration.zero);

        final startNotifications = notificationCount;
        expect(startNotifications, greaterThan(0));

        mockApiClient.completePendingSearch(returnData: true);
        await future;

        expect(notificationCount, greaterThan(startNotifications));
      });
    });
  });
}
