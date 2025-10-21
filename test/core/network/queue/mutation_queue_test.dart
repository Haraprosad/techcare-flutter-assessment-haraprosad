import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techcare_assessment_app/core/network/queue/mutation_queue.dart';
import 'package:test/test.dart';

/// Mock class for SharedPreferences to simulate persistent storage
class MockSharedPreferences extends Mock implements SharedPreferences {}

/// Unit tests for MutationQueue
///
/// This test suite validates:
/// 1. Mutation enqueueing with proper ID generation
/// 2. Queue processing with success/failure handling
/// 3. Retry logic (max 3 retries)
/// 4. Persistence to SharedPreferences
/// 5. Loading from disk on initialization
/// 6. Queue management (clear, size, pending mutations)
///
/// Testing Strategy:
/// - Mock SharedPreferences to avoid real disk I/O
/// - Test async queue operations
/// - Verify retry count increments
/// - Test edge cases (empty queue, max retries)
void main() {
  group('MutationQueue', () {
    late MutationQueue queue;
    late MockSharedPreferences mockPrefs;

    /// Setup runs before each test
    /// Creates fresh mock and queue instance
    setUp(() {
      mockPrefs = MockSharedPreferences();

      // Mock getString to return null (empty queue on startup)
      when(() => mockPrefs.getString(any())).thenReturn(null);

      // Mock setString to simulate successful persistence
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      queue = MutationQueue(mockPrefs);
    });

    group('Mutation enqueueing', () {
      test('should enqueue mutation and increment queue size', () async {
        // Arrange: Queue starts empty
        expect(queue.queueSize, 0);
        expect(queue.hasPendingMutations, false);

        // Act: Enqueue a mutation
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'amount': 100, 'description': 'Test transaction'},
        );

        // Assert: Queue size should increase
        expect(queue.queueSize, 1);
        expect(queue.hasPendingMutations, true);

        // Verify persistence was called
        verify(() => mockPrefs.setString(any(), any())).called(1);
      });

      test('should enqueue multiple mutations in order', () async {
        // Act: Enqueue multiple mutations
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'id': 1},
        );
        await queue.enqueueMutation(
          type: 'update',
          entity: 'transaction',
          data: {'id': 2},
        );
        await queue.enqueueMutation(
          type: 'delete',
          entity: 'transaction',
          data: {'id': 3},
        );

        // Assert: Queue should contain all mutations
        expect(queue.queueSize, 3);

        final pending = queue.pendingMutations;
        expect(pending[0].type, 'create');
        expect(pending[0].data['id'], 1);
        expect(pending[1].type, 'update');
        expect(pending[1].data['id'], 2);
        expect(pending[2].type, 'delete');
        expect(pending[2].data['id'], 3);
      });

      test('should generate unique IDs for each mutation', () async {
        // Act: Enqueue two mutations
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'amount': 100},
        );
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'amount': 200},
        );

        // Assert: IDs should be unique
        final pending = queue.pendingMutations;
        expect(pending[0].id, isNot(equals(pending[1].id)));
        expect(pending[0].id, startsWith('mut_'));
        expect(pending[1].id, startsWith('mut_'));
      });

      test('should set initial retry count to 0', () async {
        // Act
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'amount': 100},
        );

        // Assert
        final pending = queue.pendingMutations;
        expect(pending[0].retryCount, 0);
      });
    });

    group('Queue processing - Success scenarios', () {
      test('should process all mutations successfully', () async {
        // Arrange: Add mutations to queue
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'id': 1},
        );
        await queue.enqueueMutation(
          type: 'update',
          entity: 'transaction',
          data: {'id': 2},
        );

        // Act: Process with successful executor
        final successCount = await queue.processQueue(
          executor: (mutation) async {
            // Simulate successful execution
            return true;
          },
        );

        // Assert: All mutations should be processed and removed
        expect(successCount, 2);
        expect(queue.queueSize, 0);
        expect(queue.hasPendingMutations, false);
      });

      test('should process empty queue without errors', () async {
        // Arrange: Queue is empty
        expect(queue.queueSize, 0);

        // Act: Process empty queue
        final successCount = await queue.processQueue(
          executor: (mutation) async => true,
        );

        // Assert: Should return 0 successes
        expect(successCount, 0);
      });

      test('should call executor for each mutation in order', () async {
        // Arrange
        final processedMutations = <QueuedMutation>[];
        await queue.enqueueMutation(type: 'create', entity: 'tx1', data: {});
        await queue.enqueueMutation(type: 'update', entity: 'tx2', data: {});

        // Act
        await queue.processQueue(
          executor: (mutation) async {
            processedMutations.add(mutation);
            return true;
          },
        );

        // Assert: Executor should be called for each mutation in order
        expect(processedMutations.length, 2);
        expect(processedMutations[0].entity, 'tx1');
        expect(processedMutations[1].entity, 'tx2');
      });
    });

    group('Queue processing - Failure and retry logic', () {
      test('should retry failed mutation up to max retries', () async {
        // Arrange: Add one mutation
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'id': 1},
        );

        // Act: First attempt fails
        await queue.processQueue(executor: (mutation) async => false);

        // Assert: Mutation should still be in queue with retry count = 1
        expect(queue.queueSize, 1);
        expect(queue.pendingMutations[0].retryCount, 1);

        // Act: Second attempt fails
        await queue.processQueue(executor: (mutation) async => false);

        // Assert: Retry count should be 2
        expect(queue.queueSize, 1);
        expect(queue.pendingMutations[0].retryCount, 2);

        // Act: Third attempt fails (max retries = 3)
        await queue.processQueue(executor: (mutation) async => false);

        // Assert: Retry count should be 3
        expect(queue.queueSize, 1);
        expect(queue.pendingMutations[0].retryCount, 3);

        // Act: Fourth attempt fails (exceeds max retries)
        await queue.processQueue(executor: (mutation) async => false);

        // Assert: Mutation should be removed after exceeding max retries
        expect(queue.queueSize, 0);
      });

      test('should remove mutation after successful retry', () async {
        // Arrange: Add mutation
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'id': 1},
        );

        int attemptCount = 0;

        // Act: First two attempts fail, third succeeds
        await queue.processQueue(
          executor: (mutation) async {
            attemptCount++;
            return false; // First attempt fails
          },
        );

        expect(queue.queueSize, 1);
        expect(queue.pendingMutations[0].retryCount, 1);

        await queue.processQueue(
          executor: (mutation) async {
            attemptCount++;
            return true; // Second attempt succeeds
          },
        );

        // Assert: Mutation should be removed after successful retry
        expect(queue.queueSize, 0);
        expect(attemptCount, 2);
      });

      test('should handle mixed success and failure', () async {
        // Arrange: Add three mutations
        await queue.enqueueMutation(type: 'create', entity: 'tx1', data: {});
        await queue.enqueueMutation(type: 'create', entity: 'tx2', data: {});
        await queue.enqueueMutation(type: 'create', entity: 'tx3', data: {});

        // Act: Process with selective success
        final successCount = await queue.processQueue(
          executor: (mutation) async {
            // Only tx2 fails
            return mutation.entity != 'tx2';
          },
        );

        // Assert: 2 succeeded, 1 failed (with retry)
        expect(successCount, 2);
        expect(queue.queueSize, 1);
        expect(queue.pendingMutations[0].entity, 'tx2');
        expect(queue.pendingMutations[0].retryCount, 1);
      });

      test('should handle executor throwing exception', () async {
        // Arrange: Add mutation
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'id': 1},
        );

        // Act: Executor throws exception
        final successCount = await queue.processQueue(
          executor: (mutation) async {
            throw Exception('Network error');
          },
        );

        // Assert: Exception should be caught, mutation stays in queue
        expect(successCount, 0);
        expect(queue.queueSize, 1);
        // Mutation is not retried when exception is thrown (stays in queue)
      });
    });

    group('Queue persistence', () {
      test('should persist queue to SharedPreferences on enqueue', () async {
        // Act: Enqueue mutation
        await queue.enqueueMutation(
          type: 'create',
          entity: 'transaction',
          data: {'amount': 100},
        );

        // Assert: setString should be called with serialized queue
        final capturedCalls = verify(
          () => mockPrefs.setString('MUTATION_QUEUE', captureAny()),
        ).captured;

        expect(capturedCalls.length, greaterThan(0));
        final jsonString = capturedCalls.last as String;
        expect(jsonString, contains('"type":"create"'));
        expect(jsonString, contains('"entity":"transaction"'));
      });

      test('should persist queue after successful processing', () async {
        // Arrange: Add and process mutation
        await queue.enqueueMutation(type: 'create', entity: 'tx', data: {});

        // Clear captured calls from enqueue
        reset(mockPrefs);
        when(
          () => mockPrefs.setString(any(), any()),
        ).thenAnswer((_) async => true);

        // Act: Process queue
        await queue.processQueue(executor: (mutation) async => true);

        // Assert: Queue should be persisted after processing
        verify(() => mockPrefs.setString('MUTATION_QUEUE', any())).called(1);
      });

      test('should load queue from disk on initialization', () {
        // Arrange: Mock queue data in SharedPreferences
        final queueJson = '''
        [
          {
            "id": "mut_123",
            "type": "create",
            "entity": "transaction",
            "data": {"amount": 100},
            "timestamp": "2025-10-21T10:00:00.000Z",
            "retryCount": 0
          }
        ]
        ''';

        when(() => mockPrefs.getString('MUTATION_QUEUE')).thenReturn(queueJson);

        // Act: Create new queue instance (triggers load)
        final newQueue = MutationQueue(mockPrefs);

        // Assert: Queue should be loaded with data from disk
        expect(newQueue.queueSize, 1);
        expect(newQueue.pendingMutations[0].type, 'create');
        expect(newQueue.pendingMutations[0].entity, 'transaction');
      });

      test('should handle corrupted data gracefully on load', () {
        // Arrange: Mock corrupted JSON
        when(
          () => mockPrefs.getString('MUTATION_QUEUE'),
        ).thenReturn('invalid json {[}');

        // Act: Create queue (should not throw)
        final newQueue = MutationQueue(mockPrefs);

        // Assert: Queue should be empty (failed to load)
        expect(newQueue.queueSize, 0);
      });
    });

    group('Queue management', () {
      test('should clear all mutations from queue', () async {
        // Arrange: Add mutations
        await queue.enqueueMutation(type: 'create', entity: 'tx1', data: {});
        await queue.enqueueMutation(type: 'create', entity: 'tx2', data: {});
        expect(queue.queueSize, 2);

        // Act: Clear queue
        await queue.clearQueue();

        // Assert: Queue should be empty
        expect(queue.queueSize, 0);
        expect(queue.hasPendingMutations, false);

        // Verify persistence of empty queue
        verify(() => mockPrefs.setString('MUTATION_QUEUE', '[]')).called(1);
      });

      test('should return unmodifiable list of pending mutations', () async {
        // Arrange: Add mutation
        await queue.enqueueMutation(type: 'create', entity: 'tx', data: {});

        // Act: Get pending mutations
        final pending = queue.pendingMutations;

        // Assert: Should return unmodifiable list
        expect(pending, isA<List<QueuedMutation>>());
        expect(pending.length, 1);

        // Attempting to modify should throw (unmodifiable)
        expect(
          () => pending.add(
            QueuedMutation(
              id: 'test',
              type: 'create',
              entity: 'test',
              data: {},
              timestamp: DateTime.now(),
            ),
          ),
          throwsUnsupportedError,
        );
      });

      test('should correctly report queue size', () async {
        // Initial state
        expect(queue.queueSize, 0);

        // Add mutations
        await queue.enqueueMutation(type: 'create', entity: 'tx1', data: {});
        expect(queue.queueSize, 1);

        await queue.enqueueMutation(type: 'create', entity: 'tx2', data: {});
        expect(queue.queueSize, 2);

        // Process one successfully
        await queue.processQueue(
          executor: (mutation) async => mutation.entity == 'tx1',
        );
        expect(queue.queueSize, 1);

        // Clear
        await queue.clearQueue();
        expect(queue.queueSize, 0);
      });
    });

    group('QueuedMutation model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange: Create mutation
        final originalMutation = QueuedMutation(
          id: 'mut_123',
          type: 'update',
          entity: 'transaction',
          data: {'amount': 500, 'category': 'Food'},
          timestamp: DateTime.parse('2025-10-21T10:00:00.000Z'),
          retryCount: 2,
        );

        // Act: Convert to JSON and back
        final json = originalMutation.toJson();
        final deserializedMutation = QueuedMutation.fromJson(json);

        // Assert: Should match original
        expect(deserializedMutation.id, originalMutation.id);
        expect(deserializedMutation.type, originalMutation.type);
        expect(deserializedMutation.entity, originalMutation.entity);
        expect(deserializedMutation.data, originalMutation.data);
        expect(deserializedMutation.timestamp, originalMutation.timestamp);
        expect(deserializedMutation.retryCount, originalMutation.retryCount);
      });

      test('should increment retry count with copyWithRetry', () {
        // Arrange
        final mutation = QueuedMutation(
          id: 'mut_123',
          type: 'create',
          entity: 'transaction',
          data: {'amount': 100},
          timestamp: DateTime.now(),
          retryCount: 0,
        );

        // Act
        final retriedMutation = mutation.copyWithRetry();

        // Assert: Retry count should increment, other fields unchanged
        expect(retriedMutation.id, mutation.id);
        expect(retriedMutation.type, mutation.type);
        expect(retriedMutation.entity, mutation.entity);
        expect(retriedMutation.data, mutation.data);
        expect(retriedMutation.timestamp, mutation.timestamp);
        expect(retriedMutation.retryCount, 1);
      });

      test('should handle missing retryCount in JSON (defaults to 0)', () {
        // Arrange: JSON without retryCount
        final json = {
          'id': 'mut_123',
          'type': 'create',
          'entity': 'transaction',
          'data': {'amount': 100},
          'timestamp': '2025-10-21T10:00:00.000Z',
        };

        // Act
        final mutation = QueuedMutation.fromJson(json);

        // Assert: Should default to 0
        expect(mutation.retryCount, 0);
      });
    });
  });
}
