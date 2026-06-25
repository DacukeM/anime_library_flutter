import 'dart:async';

import 'package:dio/dio.dart';

/// A Dio [Interceptor] that limits requests to stay within Jikan API limits:
/// - Max 3 requests per second (sliding window of 3 requests)
/// - Max 60 requests per minute (sliding window of 60 requests)
class RateLimitInterceptor extends Interceptor {
  // Max requests per minute
  static const int _maxRequestsPerMinute = 60;
  // Time window for minute limit (60 seconds)
  static const Duration _minuteWindow = Duration(seconds: 60);
  // Time window for second limit (1 second)
  static const Duration _secondWindow = Duration(seconds: 1);
  // Max requests per second
  static const int _maxRequestsPerSecond = 3;

  // Queue of scheduled timestamps of the requests
  final List<DateTime> _scheduledTimes = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final now = DateTime.now();

    // Determine the next allowed time for this request
    DateTime scheduledTime = now;

    // 1. Enforce max 3 requests per second (sliding window of 3 requests)
    if (_scheduledTimes.length >= _maxRequestsPerSecond) {
      final timeOfThirdRequestAgo = _scheduledTimes[_scheduledTimes.length - _maxRequestsPerSecond];
      final earliestNextBySecond = timeOfThirdRequestAgo.add(_secondWindow);
      if (scheduledTime.isBefore(earliestNextBySecond)) {
        scheduledTime = earliestNextBySecond;
      }
    }

    // 2. Enforce max requests per minute (60 requests per minute)
    if (_scheduledTimes.length >= _maxRequestsPerMinute) {
      // The timestamp of the request that occurred _maxRequestsPerMinute ago
      final timeOfSixtiethRequestAgo = _scheduledTimes[_scheduledTimes.length - _maxRequestsPerMinute];
      final earliestNextByMinute = timeOfSixtiethRequestAgo.add(_minuteWindow);
      if (scheduledTime.isBefore(earliestNextByMinute)) {
        scheduledTime = earliestNextByMinute;
      }
    }

    // Save scheduled time
    _scheduledTimes.add(scheduledTime);

    // Keep the queue size bounded. We only need the last _maxRequestsPerMinute timestamps.
    if (_scheduledTimes.length > _maxRequestsPerMinute) {
      _scheduledTimes.removeRange(0, _scheduledTimes.length - _maxRequestsPerMinute);
    }

    // Wait if the scheduled time is in the future
    final delay = scheduledTime.difference(DateTime.now());
    if (delay > Duration.zero) {
      final cancelToken = options.cancelToken;
      if (cancelToken != null) {
        if (cancelToken.isCancelled) {
          _scheduledTimes.remove(scheduledTime);
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: cancelToken.cancelError ?? "Request cancelled before delay",
          ));
          return;
        }

        final completer = Completer<void>();
        final timer = Timer(delay, () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        void onCancel() {
          if (!completer.isCompleted) {
            timer.cancel();
            completer.completeError(DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: cancelToken.cancelError ?? "Request cancelled during delay",
            ));
          }
        }

        // Listen for cancellation
        cancelToken.whenCancel.then((_) => onCancel());

        try {
          await completer.future;
        } catch (e) {
          _scheduledTimes.remove(scheduledTime);
          if (e is DioException) {
            handler.reject(e);
          } else {
            handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: e,
            ));
          }
          return;
        }
      } else {
        await Future.delayed(delay);
      }
    }

    super.onRequest(options, handler);
  }
}
