import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:techcare_assessment_app/core/utils/throttle_droppable.dart';

/// Unit tests for throttleDroppable EventTransformer
///
/// This test suite validates:
/// 1. EventTransformer creation
/// 2. Event throttling behavior
/// 3. Event dropping during processing
/// 4. Integration with Stream processing
/// 5. Timing and delay behavior
///
/// Testing Strategy:
/// - Test throttleDroppable as an EventTransformer for BLoC
/// - Verify events are throttled by the specified duration
/// - Verify events are dropped during processing (droppable behavior)
/// - Test with different durations
/// - Test edge cases (no events, single event, rapid events)
void main() {
  group('throttleDroppable', () {
    group('EventTransformer creation', () {
      test('should create EventTransformer with specified duration', () {
        // Arrange
        const duration = Duration(milliseconds: 100);

        // Act
        final transformer = throttleDroppable<int>(duration);

        // Assert
        expect(transformer, isNotNull);
        expect(transformer, isA<Function>());
      });

      test('should create EventTransformer with default throttleDuration', () {
        // Arrange & Act
        final transformer = throttleDroppable<String>(throttleDuration);

        // Assert
        expect(transformer, isNotNull);
      });

      test('should work with different event types', () {
        // Arrange & Act
        final intTransformer = throttleDroppable<int>(
          Duration(milliseconds: 50),
        );
        final stringTransformer = throttleDroppable<String>(
          Duration(milliseconds: 50),
        );
        final boolTransformer = throttleDroppable<bool>(
          Duration(milliseconds: 50),
        );

        // Assert
        expect(intTransformer, isNotNull);
        expect(stringTransformer, isNotNull);
        expect(boolTransformer, isNotNull);
      });
    });

    group('Event throttling behavior', () {
      test('should throttle events by specified duration', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        // Listen to transformed stream
        transformedStream.listen((_) {});

        // Act: Add events rapidly
        controller.add(1);
        await Future.delayed(Duration(milliseconds: 50));
        controller.add(2); // Should be dropped (within throttle window)

        await Future.delayed(Duration(milliseconds: 60)); // Total 110ms
        controller.add(3); // Should be processed (after throttle)

        await Future.delayed(Duration(milliseconds: 150));

        // Assert: Only events 1 and 3 should be processed
        expect(processedEvents.length, 2);
        expect(processedEvents, containsAll([1, 3]));

        // Cleanup
        await controller.close();
      });

      test('should process first event immediately', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<String>();
        final processedEvents = <String>[];

        final transformer = throttleDroppable<String>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        // Act: Add first event
        controller.add('first');
        await Future.delayed(Duration(milliseconds: 10));

        // Assert: First event should be processed immediately
        expect(processedEvents, contains('first'));

        // Cleanup
        await controller.close();
      });

      test('should respect different throttle durations', () async {
        // Arrange
        const shortDuration = Duration(milliseconds: 50);
        const longDuration = Duration(milliseconds: 200);

        final shortController = StreamController<int>();
        final longController = StreamController<int>();

        final shortProcessed = <int>[];
        final longProcessed = <int>[];

        final shortTransformer = throttleDroppable<int>(shortDuration);
        final longTransformer = throttleDroppable<int>(longDuration);

        shortTransformer(
          shortController.stream,
          (e) => Stream.value(e).asyncMap((v) async {
            shortProcessed.add(v);
            return v;
          }),
        ).listen((_) {});

        longTransformer(
          longController.stream,
          (e) => Stream.value(e).asyncMap((v) async {
            longProcessed.add(v);
            return v;
          }),
        ).listen((_) {});

        // Act: Add events at same intervals
        shortController.add(1);
        longController.add(1);

        await Future.delayed(Duration(milliseconds: 100));

        shortController.add(2);
        longController.add(2);

        await Future.delayed(Duration(milliseconds: 150));

        // Assert: Short duration allows more events through
        expect(
          shortProcessed.length,
          greaterThanOrEqualTo(longProcessed.length),
        );

        // Cleanup
        await shortController.close();
        await longController.close();
      });
    });

    group('Event dropping behavior', () {
      test('should drop events that arrive during processing', () async {
        // Arrange
        const duration = Duration(milliseconds: 50);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            // Simulate processing time
            await Future.delayed(Duration(milliseconds: 30));
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        // Act: Add events rapidly (should drop some)
        controller.add(1);
        controller.add(2); // Likely dropped
        controller.add(3); // Likely dropped

        await Future.delayed(Duration(milliseconds: 200));

        // Assert: Should process fewer events than added
        expect(processedEvents.length, lessThan(3));
        expect(processedEvents.first, 1);

        // Cleanup
        await controller.close();
      });

      test('should not queue events during throttle period', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        // Act: Spam events
        for (int i = 0; i < 10; i++) {
          controller.add(i);
          await Future.delayed(Duration(milliseconds: 10));
        }

        await Future.delayed(Duration(milliseconds: 200));

        // Assert: Should only process a few events, not all 10
        expect(processedEvents.length, lessThan(10));
        expect(processedEvents.length, greaterThan(0));

        // Cleanup
        await controller.close();
      });
    });

    group('Edge cases', () {
      test('should handle no events', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        // Act: Don't add any events
        await Future.delayed(Duration(milliseconds: 200));

        // Assert
        expect(processedEvents, isEmpty);

        // Cleanup
        await controller.close();
      });

      test('should handle single event', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        // Act: Add single event
        controller.add(42);
        await Future.delayed(Duration(milliseconds: 150));

        // Assert
        expect(processedEvents, [42]);

        // Cleanup
        await controller.close();
      });

      test('should handle very short duration', () async {
        // Arrange
        const duration = Duration(milliseconds: 1);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        // Act: Add events
        controller.add(1);
        await Future.delayed(Duration(milliseconds: 5));
        controller.add(2);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert: Both should be processed with very short throttle
        expect(processedEvents.length, 2);

        // Cleanup
        await controller.close();
      });

      test('should handle stream errors', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<int>();
        final processedEvents = <int>[];
        final errors = <Object>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            if (e == 2) throw Exception('Test error');
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {}, onError: (e) => errors.add(e));

        // Act: Add events, one causing error
        controller.add(1);
        await Future.delayed(Duration(milliseconds: 120));
        controller.add(2); // Will cause error
        await Future.delayed(Duration(milliseconds: 120));
        controller.add(3);
        await Future.delayed(Duration(milliseconds: 150));

        // Assert: Error should be caught, other events processed
        expect(processedEvents, containsAll([1, 3]));
        expect(errors.length, 1);

        // Cleanup
        await controller.close();
      });

      test('should handle stream completion', () async {
        // Arrange
        const duration = Duration(milliseconds: 50);
        final controller = StreamController<int>();
        final processedEvents = <int>[];
        var completed = false;

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {}, onDone: () => completed = true);

        // Act: Add event and close stream
        controller.add(1);
        await Future.delayed(Duration(milliseconds: 100));
        await controller.close();
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        expect(processedEvents, contains(1));
        expect(completed, isTrue);
      });
    });

    group('Integration scenarios', () {
      test('should work as expected for search input throttling', () async {
        // Arrange: Simulate user typing in search box
        const duration = Duration(milliseconds: 300);
        final searchController = StreamController<String>();
        final searchQueries = <String>[];

        final transformer = throttleDroppable<String>(duration);
        final searchStream = transformer(
          searchController.stream,
          (query) => Stream.value(query).asyncMap((q) async {
            // Simulate API call
            await Future.delayed(Duration(milliseconds: 50));
            searchQueries.add(q);
            return q;
          }),
        );

        searchStream.listen((_) {});

        // Act: Simulate rapid typing
        searchController.add('f');
        await Future.delayed(Duration(milliseconds: 50));
        searchController.add('fl');
        await Future.delayed(Duration(milliseconds: 50));
        searchController.add('flu');
        await Future.delayed(Duration(milliseconds: 50));
        searchController.add('flut');
        await Future.delayed(Duration(milliseconds: 50));
        searchController.add('flutt');
        await Future.delayed(Duration(milliseconds: 50));
        searchController.add('flutte');
        await Future.delayed(Duration(milliseconds: 50));
        searchController.add('flutter'); // User stops typing

        await Future.delayed(Duration(milliseconds: 500));

        // Assert: Should only process a few queries, not all keystrokes
        expect(searchQueries.length, lessThan(7));
        expect(searchQueries, isNotEmpty);

        // Cleanup
        await searchController.close();
      });

      test('should prevent rapid button click spam', () async {
        // Arrange: Simulate button clicks
        const duration = Duration(milliseconds: 500);
        final clickController = StreamController<void>();
        var clickCount = 0;

        final transformer = throttleDroppable<void>(duration);
        final clickStream = transformer(
          clickController.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            clickCount++;
            return e;
          }),
        );

        clickStream.listen((_) {});

        // Act: Simulate rapid clicks (user mashing button)
        for (int i = 0; i < 20; i++) {
          clickController.add(null);
          await Future.delayed(Duration(milliseconds: 50));
        }

        await Future.delayed(Duration(milliseconds: 600));

        // Assert: Should only process a few clicks, not all 20
        expect(clickCount, lessThan(20));
        expect(clickCount, greaterThan(0));
        expect(
          clickCount,
          lessThan(5),
        ); // With 500ms throttle and 50ms intervals

        // Cleanup
        await clickController.close();
      });
    });

    group('Performance', () {
      test('should handle high-frequency events efficiently', () async {
        // Arrange
        const duration = Duration(milliseconds: 100);
        final controller = StreamController<int>();
        final processedEvents = <int>[];

        final transformer = throttleDroppable<int>(duration);
        final transformedStream = transformer(
          controller.stream,
          (event) => Stream.value(event).asyncMap((e) async {
            processedEvents.add(e);
            return e;
          }),
        );

        transformedStream.listen((_) {});

        final stopwatch = Stopwatch()..start();

        // Act: Add 100 events rapidly
        for (int i = 0; i < 100; i++) {
          controller.add(i);
        }

        await Future.delayed(Duration(milliseconds: 500));
        stopwatch.stop();

        // Assert: Should complete quickly and drop most events
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(processedEvents.length, lessThan(100));
        expect(processedEvents.length, greaterThan(0));

        // Cleanup
        await controller.close();
      });
    });
  });
}
