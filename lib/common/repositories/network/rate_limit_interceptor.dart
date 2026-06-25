import 'package:dio/dio.dart';

/// A Dio [Interceptor] that limits requests to stay within Jikan API limits:
/// - Max 3 requests per second (min 334ms interval between request starts)
/// - Max 60 requests per minute (sliding window of 60 requests)
class RateLimitInterceptor extends Interceptor {
  // Max requests per minute
  static const int _maxRequestsPerMinute = 60;
  // Time window for minute limit (60 seconds)
  static const Duration _minuteWindow = Duration(seconds: 60);
  // Minimum delay between starting requests to respect the per-second limit.
  // 3 requests per second -> 1 request per ~333.3 milliseconds.
  // Using 334ms to be safe and avoid rounding issues.
  static const Duration _minIntervalBetweenRequests = Duration(milliseconds: 334);

  // Queue of scheduled timestamps of the requests
  final List<DateTime> _scheduledTimes = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final now = DateTime.now();

    // Determine the next allowed time for this request
    DateTime scheduledTime = now;

    // 1. Enforce minimum interval between consecutive requests (3 requests per second)
    if (_scheduledTimes.isNotEmpty) {
      final lastScheduled = _scheduledTimes.last;
      final earliestNext = lastScheduled.add(_minIntervalBetweenRequests);
      if (scheduledTime.isBefore(earliestNext)) {
        scheduledTime = earliestNext;
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
      await Future.delayed(delay);
    }

    super.onRequest(options, handler);
  }
}
