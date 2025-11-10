sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Exception exception) error,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else if (this is Error<T>) {
      return error((this as Error<T>).exception);
    } else {
      throw Exception('Unsupported Result type');
    }
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.exception);

  final Exception exception;
}
