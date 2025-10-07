import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

// How long to wait before processing the next event
const throttleDuration = Duration(milliseconds: 100);

/// Prevents event spam by dropping extra events that come in too quickly.
///
/// Useful for things like search bars where you don't want to fire off
/// a new request for every single keystroke. This throttles events and
/// drops any that arrive while one is still being processed.
EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}
