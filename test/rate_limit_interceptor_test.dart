import 'package:anime_library_flutter/common/repositories/network/rate_limit_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// An interceptor that returns a successful response immediately
class _MockResponseInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {'status': 'ok'},
    ));
  }
}

void main() {
  group('RateLimitInterceptor Tests', () {
    late Dio dio;

    setUp(() {
      dio = Dio();
      dio.interceptors.addAll([
        RateLimitInterceptor(),
        _MockResponseInterceptor(),
      ]);
    });

    test('should space out rapid consecutive requests after exceeding sliding window', () async {
      final stopwatch = Stopwatch()..start();

      // Make 4 rapid requests. Under 3 req/sec limit, first 3 are instant, 4th waits 1s.
      final futures = List.generate(4, (_) => dio.get('/test'));
      await Future.wait(futures);

      stopwatch.stop();

      // Total elapsed time must be at least 1000ms.
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
    });

    test('should allow the first request to execute immediately without delay', () async {
      final stopwatch = Stopwatch()..start();

      await dio.get('/test');

      stopwatch.stop();

      // The first request should complete almost instantly since there are no prior requests
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should abort immediately and free up rate limit slot when request is cancelled during delay', () async {
      final cancelToken = CancelToken();

      // Send 3 requests (execute immediately, filling the sliding window)
      await Future.wait([
        dio.get('/test'),
        dio.get('/test'),
        dio.get('/test'),
      ]);

      final stopwatch = Stopwatch()..start();
      
      // Start the 4th request, which will have a 1-second delay
      final future1 = dio.get('/test', cancelToken: cancelToken);
      
      // Cancel the 4th request after 50ms
      await Future.delayed(const Duration(milliseconds: 50));
      cancelToken.cancel('User cancelled request');

      try {
        await future1;
      } on DioException catch (e) {
        expect(e.type, DioExceptionType.cancel);
      }

      final elapsedAfterCancel = stopwatch.elapsedMilliseconds;
      // Verified that the cancelled request aborted early (much sooner than 1000ms)
      expect(elapsedAfterCancel, lessThan(150));

      // Re-measure: because the cancelled 4th request reclaimed its slot,
      // we should be able to send Requests 5, 6, and 7 all scheduled for 1000ms.
      // If the slot was NOT reclaimed, Request 7 would be delayed to 2000ms.
      await Future.wait([
        dio.get('/test'),
        dio.get('/test'),
        dio.get('/test'),
      ]);

      stopwatch.stop();

      // Total elapsed time should be around 1000ms (less than 1300ms)
      // because Request 7 is allowed to run at 1000ms.
      expect(stopwatch.elapsedMilliseconds, lessThan(1300));
    });
  });
}
