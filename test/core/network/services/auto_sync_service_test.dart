import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techcare_assessment_app/core/network/queue/mutation_queue.dart';
import 'package:techcare_assessment_app/core/network/services/auto_sync_service.dart';
import 'package:techcare_assessment_app/core/network/services/connection_manager.dart';

/// Mock classes for dependencies
class MockMutationQueue extends Mock implements MutationQueue {}

class MockConnectionManager extends Mock implements ConnectionManager {}

/// Fake class for QueuedMutation to use with any() matcher
class FakeQueuedMutation extends Fake implements QueuedMutation {}

/// Unit tests for AutoSyncService
///
/// This test suite validates:
/// 1. Auto-sync triggers when connection is restored
/// 2. Manual sync functionality
/// 3. Sync with pending mutations
/// 4. Sync prevention when already syncing
/// 5. Error handling during sync
/// 6. Service lifecycle (start/stop/dispose)
/// 7. Status reporting (isSyncing, hasPendingMutations, pendingCount)
///
/// Testing Strategy:
/// - Mock MutationQueue and ConnectionManager
/// - Use StreamController to simulate connectivity changes
/// - Test async operations with proper awaiting
/// - Verify executor function calls
/// - Test edge cases (no executor, no pending mutations, errors)
void main() {
  // Register fake for any() matcher
  setUpAll(() {
    registerFallbackValue(FakeQueuedMutation());
  });

  group('AutoSyncService', () {
    late AutoSyncService autoSyncService;
    late MockMutationQueue mockMutationQueue;
    late MockConnectionManager mockConnectionManager;
    late StreamController<bool> connectivityStreamController;

    /// Setup runs before each test
    setUp(() {
      mockMutationQueue = MockMutationQueue();
      mockConnectionManager = MockConnectionManager();
      connectivityStreamController = StreamController<bool>.broadcast();

      // Setup default mock behaviors
      when(
        () => mockConnectionManager.connectivityStream,
      ).thenAnswer((_) => connectivityStreamController.stream);
      when(() => mockConnectionManager.isConnected).thenReturn(false);
      when(() => mockMutationQueue.hasPendingMutations).thenReturn(false);
      when(() => mockMutationQueue.queueSize).thenReturn(0);

      autoSyncService = AutoSyncService(
        mockMutationQueue,
        mockConnectionManager,
      );
    });

    /// Teardown runs after each test
    tearDown(() {
      autoSyncService.dispose();
      connectivityStreamController.close();
    });

    group('Service lifecycle', () {
      test('should start auto-sync service and listen to connectivity', () {
        // Arrange
        final executor = (QueuedMutation mutation) async => true;

        // Act
        autoSyncService.startAutoSync(executor: executor);

        // Assert: Should subscribe to connectivity stream
        verify(() => mockConnectionManager.connectivityStream).called(1);
        verify(() => mockConnectionManager.isConnected).called(1);
      });

      test(
        'should trigger sync immediately if already connected on start',
        () async {
          // Arrange
          when(() => mockConnectionManager.isConnected).thenReturn(true);
          when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);
          when(() => mockMutationQueue.queueSize).thenReturn(2);
          when(
            () => mockMutationQueue.processQueue(
              executor: any(named: 'executor'),
            ),
          ).thenAnswer((_) async => 2);

          final executor = (QueuedMutation mutation) async => true;

          // Act
          autoSyncService.startAutoSync(executor: executor);
          await Future.delayed(
            Duration(milliseconds: 100),
          ); // Allow async operations

          // Assert: Should process queue immediately
          verify(
            () => mockMutationQueue.processQueue(
              executor: any(named: 'executor'),
            ),
          ).called(1);
        },
      );

      test('should stop auto-sync service and cancel subscription', () {
        // Arrange
        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        autoSyncService.stopAutoSync();

        // Assert: Subscription should be cancelled (no more events processed)
        expect(autoSyncService.isSyncing, false);
      });

      test('should dispose and cleanup resources', () {
        // Arrange
        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        autoSyncService.dispose();

        // Assert: Should stop auto-sync
        expect(autoSyncService.isSyncing, false);
      });
    });

    group('Auto-sync on connectivity change', () {
      test('should sync when connection is restored', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);
        when(() => mockMutationQueue.queueSize).thenReturn(3);
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async => 3);

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act: Simulate connection restored
        connectivityStreamController.add(true);
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow async operations

        // Assert: Should process queue
        verify(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).called(1);
      });

      test('should not sync when connection lost', () async {
        // Arrange
        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act: Simulate connection lost
        connectivityStreamController.add(false);
        await Future.delayed(Duration(milliseconds: 100));

        // Assert: Should not process queue
        verifyNever(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        );
      });

      test('should not sync if no pending mutations', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(false);

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act: Simulate connection restored
        connectivityStreamController.add(true);
        await Future.delayed(Duration(milliseconds: 100));

        // Assert: Should not process queue (no pending mutations)
        verifyNever(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        );
      });

      test('should skip sync if already syncing', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);
        when(() => mockMutationQueue.queueSize).thenReturn(2);

        // Make first sync take time
        var callCount = 0;
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 200));
          return 2;
        });

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act: Trigger multiple connection events quickly
        connectivityStreamController.add(true);
        await Future.delayed(Duration(milliseconds: 50));
        connectivityStreamController.add(true); // Should be skipped
        await Future.delayed(Duration(milliseconds: 50));
        connectivityStreamController.add(true); // Should be skipped
        await Future.delayed(
          Duration(milliseconds: 200),
        ); // Wait for sync to complete

        // Assert: Should only process queue once (others skipped)
        expect(callCount, 1);
      });
    });

    group('Manual sync', () {
      test('should manually trigger sync successfully', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);
        when(() => mockMutationQueue.queueSize).thenReturn(5);
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async => 5);

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        final result = await autoSyncService.manualSync();

        // Assert
        expect(result, true);
        verify(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).called(1);
      });

      test('should return false if no executor configured', () async {
        // Arrange: Don't start auto-sync (no executor)

        // Act
        final result = await autoSyncService.manualSync();

        // Assert
        expect(result, false);
        verifyNever(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        );
      });

      test('should return false if no mutations were synced', () async {
        // Arrange
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async => 0); // No mutations synced

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        final result = await autoSyncService.manualSync();

        // Assert
        expect(result, false); // Returns false when successCount is 0
      });

      test('should handle errors during manual sync', () async {
        // Arrange
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenThrow(Exception('Sync error'));

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        final result = await autoSyncService.manualSync();

        // Assert: Should return false on error
        expect(result, false);
        expect(autoSyncService.isSyncing, false); // Should reset syncing flag
      });
    });

    group('Sync execution', () {
      test('should execute mutations and return success count', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);
        when(() => mockMutationQueue.queueSize).thenReturn(3);
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async => 3);

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        final result = await autoSyncService.manualSync();

        // Assert
        expect(result, true);
        verify(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).called(1);
      });

      test('should set isSyncing flag during sync', () async {
        // Arrange
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async {
          // Check flag during sync
          expect(autoSyncService.isSyncing, true);
          await Future.delayed(Duration(milliseconds: 100));
          return 2;
        });

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        expect(autoSyncService.isSyncing, false); // Before sync
        final syncFuture = autoSyncService.manualSync();
        await Future.delayed(Duration(milliseconds: 50));
        expect(autoSyncService.isSyncing, true); // During sync
        await syncFuture;
        expect(autoSyncService.isSyncing, false); // After sync
      });

      test('should reset isSyncing flag even on error', () async {
        // Arrange
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenThrow(Exception('Test error'));

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        await autoSyncService.manualSync();

        // Assert: Flag should be reset
        expect(autoSyncService.isSyncing, false);
      });
    });

    group('Status properties', () {
      test('should report syncing status correctly', () {
        expect(autoSyncService.isSyncing, false);
      });

      test('should report pending mutations status', () {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);

        // Assert
        expect(autoSyncService.hasPendingMutations, true);
        verify(() => mockMutationQueue.hasPendingMutations).called(1);
      });

      test('should report pending count', () {
        // Arrange
        when(() => mockMutationQueue.queueSize).thenReturn(7);

        // Assert
        expect(autoSyncService.pendingCount, 7);
        verify(() => mockMutationQueue.queueSize).called(1);
      });

      test(
        'should return false for hasPendingMutations when queue is empty',
        () {
          // Arrange
          when(() => mockMutationQueue.hasPendingMutations).thenReturn(false);

          // Assert
          expect(autoSyncService.hasPendingMutations, false);
        },
      );
    });

    group('Edge cases', () {
      test('should handle rapid connectivity changes', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(true);
        when(() => mockMutationQueue.queueSize).thenReturn(1);
        when(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        ).thenAnswer((_) async => 1);

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act: Rapid connectivity changes
        connectivityStreamController.add(true);
        connectivityStreamController.add(false);
        connectivityStreamController.add(true);
        connectivityStreamController.add(false);
        connectivityStreamController.add(true);

        await Future.delayed(Duration(milliseconds: 200));

        // Assert: Should handle without crashing
        expect(autoSyncService.isSyncing, false);
      });

      test('should handle empty queue gracefully', () async {
        // Arrange
        when(() => mockMutationQueue.hasPendingMutations).thenReturn(false);
        when(() => mockMutationQueue.queueSize).thenReturn(0);

        final executor = (QueuedMutation mutation) async => true;
        autoSyncService.startAutoSync(executor: executor);

        // Act
        connectivityStreamController.add(true);
        await Future.delayed(Duration(milliseconds: 100));

        // Assert: Should not attempt to process
        verifyNever(
          () =>
              mockMutationQueue.processQueue(executor: any(named: 'executor')),
        );
      });

      test('should handle multiple start calls', () {
        // Arrange
        final executor = (QueuedMutation mutation) async => true;

        // Act: Call startAutoSync multiple times
        autoSyncService.startAutoSync(executor: executor);
        autoSyncService.startAutoSync(executor: executor);
        autoSyncService.startAutoSync(executor: executor);

        // Assert: Should not crash (may create multiple subscriptions)
        expect(autoSyncService.isSyncing, false);
      });

      test('should handle stop before start', () {
        // Act: Stop without starting
        autoSyncService.stopAutoSync();

        // Assert: Should not crash
        expect(autoSyncService.isSyncing, false);
      });
    });
  });
}
