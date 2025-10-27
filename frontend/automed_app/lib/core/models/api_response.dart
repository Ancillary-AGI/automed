import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;
  final String? timestamp;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Factory constructors for common response types
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory ApiResponse.loading() {
    return ApiResponse<T>(
      success: false,
      message: 'Loading...',
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  // Helper methods
  bool get isSuccess => success && data != null;
  bool get isError => !success;
  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  String get errorMessage => message ?? 'An unknown error occurred';
  
  List<String> get errorMessages {
    if (errors == null) return [errorMessage];
    
    final messages = <String>[];
    errors!.forEach((key, value) {
      if (value is List) {
        messages.addAll(value.cast<String>());
      } else if (value is String) {
        messages.add(value);
      }
    });
    
    return messages.isEmpty ? [errorMessage] : messages;
  }
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  // Helper methods
  bool get hasContent => content.isNotEmpty;
  bool get hasNextPage => !last;
  bool get hasPreviousPage => !first;
  int get nextPage => hasNextPage ? page + 1 : page;
  int get previousPage => hasPreviousPage ? page - 1 : page;
}

@JsonSerializable()
class ErrorResponse {
  final String message;
  final int statusCode;
  final String timestamp;
  final String path;
  final Map<String, dynamic>? details;

  ErrorResponse({
    required this.message,
    required this.statusCode,
    required this.timestamp,
    required this.path,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class ValidationError {
  final String field;
  final String message;
  final dynamic rejectedValue;

  ValidationError({
    required this.field,
    required this.message,
    this.rejectedValue,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}

// Response wrapper for handling different states
class ResourceState<T> {
  final T? data;
  final String? error;
  final bool isLoading;
  final bool isSuccess;
  final bool isError;

  const ResourceState._({
    this.data,
    this.error,
    required this.isLoading,
    required this.isSuccess,
    required this.isError,
  });

  const ResourceState.loading() : this._(
    isLoading: true,
    isSuccess: false,
    isError: false,
  );

  const ResourceState.success(T data) : this._(
    data: data,
    isLoading: false,
    isSuccess: true,
    isError: false,
  );

  const ResourceState.error(String error) : this._(
    error: error,
    isLoading: false,
    isSuccess: false,
    isError: true,
  );

  const ResourceState.idle() : this._(
    isLoading: false,
    isSuccess: false,
    isError: false,
  );

  // Helper methods
  bool get hasData => data != null;
  bool get isEmpty => !hasData && !isLoading && !isError;

  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String error) error,
    required R Function() idle,
  }) {
    if (isLoading) return loading();
    if (isSuccess && data != null) return success(data!);
    if (isError && this.error != null) return error(this.error!);
    return idle();
  }

  R maybeWhen<R>({
    R Function()? loading,
    R Function(T data)? success,
    R Function(String error)? error,
    R Function()? idle,
    required R Function() orElse,
  }) {
    if (isLoading && loading != null) return loading();
    if (isSuccess && data != null && success != null) return success(data!);
    if (isError && this.error != null && error != null) return error(this.error!);
    if (isEmpty && idle != null) return idle();
    return orElse();
  }
}