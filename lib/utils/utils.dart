import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

import 'result.dart';

/// Generic method to handle product-related API calls
Future<Result<T>> handleRequest<T>(
  Future<HttpResponse<T>> Function() request, [
  String requestName = "",
]) async {
  try {
    final httpResponse = await request();
    final response = httpResponse.response;

    // Log response details for debugging
    developer.log(
      'Response status code for $requestName: ${response.statusCode}',
      name: '+++Utils',
    );
    developer.log(
      'Request path: ${response.requestOptions.path}',
      name: '+++Utils',
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return Success(httpResponse.data);
    } else {
      // This handles cases where the server returns a non-200 status,
      // but Dio is configured not to throw an exception for it.
      final errorMessage = _extractDetailFromError(
        response.data,
        response.statusMessage,
      );

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: errorMessage,
        error: response.statusMessage,
      );
    }
  } on DioException catch (e) {
    // ✅ Ignore cancelled requests completely
    if (e.type == DioExceptionType.cancel) {
      developer.log('Request for $requestName was cancelled', name: '+++Utils');
      return Error(e); // or create a special Result.cancelled
    }

    developer.log(
      'DioException in $requestName: ${e.message}',
      name: '+++Utils',
      error: e,
    );
    final errorMessage = _extractDetailFromError(e.response?.data, e.message);

    return Error(
      DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: errorMessage,
        error: e.error,
        stackTrace: e.stackTrace,
        type: e.type,
      ),
    );
  }
}

/// Generic method to handle product-related API calls
Future<T> handleRequestThrow<T>(
  Future<HttpResponse<T>> Function() request, [
  String requestName = "",
]) async {
  try {
    final httpResponse = await request();
    final response = httpResponse.response;

    // Log response details for debugging
    developer.log(
      'Response status code for $requestName: ${response.statusCode}',
      name: '+++Utils',
    );
    developer.log(
      'Request path: ${response.requestOptions.path}',
      name: '+++Utils',
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return httpResponse.data;
    } else {
      // This handles cases where the server returns a non-200 status,
      // but Dio is configured not to throw an exception for it.
      final errorMessage = _extractDetailFromError(
        response.data,
        response.statusMessage,
      );

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: errorMessage,
        error: response.statusMessage,
      );
    }
  } on DioException catch (e) {
    developer.log(
      'DioException in $requestName: ${e.message}',
      name: '+++Utils',
      error: e,
    );

    final errorMessage = _extractDetailFromError(e.response?.data, e.message);

    throw DioException(
      requestOptions: e.requestOptions,
      response: e.response,
      message: errorMessage,
      error: e.error,
      stackTrace: e.stackTrace,
      type: e.type,
    );
  }
}

String _extractDetailFromError(dynamic errorData, String? defaultMessage) {
  try {
    if (errorData != null && errorData is Map<String, dynamic>) {
      if (errorData.containsKey("errors")) {
        final errors = errorData['errors'];

        if (errors is List && errors.isNotEmpty) {
          final firstError = errors.first;
          // Prioritize the 'detail' field.
          if (firstError is Map && firstError.containsKey('detail')) {
            return firstError['detail'] as String;
          }
          // Fallback to the 'title' field if 'detail' is not present.
          if (firstError is Map && firstError.containsKey('title')) {
            return firstError['title'] as String;
          }
        }
      }

      if (errorData.containsKey("message")) {
        final errorMessage = errorData['message'];

        if (errorMessage is String) {
          return errorMessage;
        }
      }
    }
  } catch (parseError) {
    developer.log(
      'Failed to parse DioException error response: $parseError',
      name: '+++Utils',
      error: parseError,
    );
    // If any parsing error occurs (e.g., unexpected format),
    // we'll fall back to the default message below.
  }
  return defaultMessage ?? 'An unknown error occurred.';
}
