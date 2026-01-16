/// A generic Result type for operations that can fail.
/// Provides a clean way to handle success/failure without exceptions.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a successful result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result.
  bool get isFailure => this is Failure<T>;

  /// Returns the value if success, or null if failure.
  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Failure() => null,
  };

  /// Returns the error if failure, or null if success.
  String? get errorOrNull => switch (this) {
    Success() => null,
    Failure(message: final m) => m,
  };

  /// Maps the success value to a new type.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(value: final v) => Success(transform(v)),
    Failure(message: final m, error: final e) => Failure(m, error: e),
  };

  /// Executes [onSuccess] if success, [onFailure] if failure.
  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Object? error) failure,
  }) => switch (this) {
    Success(value: final v) => success(v),
    Failure(message: final m, error: final e) => failure(m, e),
  };
}

/// Represents a successful result with a value.
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Represents a failed result with an error message.
final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}
