// API Response Wrapper Model
// 
// Generic wrapper for API responses.
// Handles success/error states and data parsing.
// 
// TODO: Adjust field names based on your API response structure

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? meta;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });
  
  /// Create ApiResponse from JSON with a data parser
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    // Determine success based on various API response patterns
    final success = json['success'] == true || 
                   json['status'] == 'success' ||
                   json['status'] == true ||
                   (json['data'] != null && json['error'] == null);
    
    // Parse data if parser provided
    T? parsedData;
    if (dataParser != null && json['data'] != null) {
      parsedData = dataParser(json['data']);
    }
    
    // Parse pagination meta if present
    PaginationMeta? meta;
    if (json['meta'] != null) {
      meta = PaginationMeta.fromJson(json['meta']);
    } else if (json['pagination'] != null) {
      meta = PaginationMeta.fromJson(json['pagination']);
    }
    
    return ApiResponse(
      success: success,
      message: json['message'] ?? json['msg'],
      data: parsedData,
      errors: json['errors'],
      meta: meta,
    );
  }
  
  /// Create a success response
  factory ApiResponse.success({T? data, String? message, PaginationMeta? meta}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      meta: meta,
    );
  }
  
  /// Create an error response
  factory ApiResponse.error({String? message, Map<String, dynamic>? errors}) {
    return ApiResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
  
  /// Check if response has data
  bool get hasData => data != null;
  
  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  
  /// Check if response has pagination
  bool get hasPagination => meta != null;
  
  /// Get first error message from errors map
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstKey = errors!.keys.first;
    final firstValue = errors![firstKey];
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return firstValue?.toString();
  }
  
  /// Get all error messages as a list
  List<String> get allErrors {
    if (errors == null || errors!.isEmpty) return [];
    final messages = <String>[];
    errors!.forEach((key, value) {
      if (value is List) {
        messages.addAll(value.map((e) => e.toString()));
      } else {
        messages.add(value.toString());
      }
    });
    return messages;
  }
  
  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: $hasData)';
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  
  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });
  
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      lastPage: json['last_page'] ?? json['total_pages'] ?? 1,
      perPage: json['per_page'] ?? json['limit'] ?? 10,
      total: json['total'] ?? 0,
      from: json['from'],
      to: json['to'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
    };
  }
  
  /// Check if there are more pages
  bool get hasMorePages => currentPage < lastPage;
  
  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;
  
  /// Check if this is the last page
  bool get isLastPage => currentPage >= lastPage;
  
  /// Get next page number
  int get nextPage => hasMorePages ? currentPage + 1 : currentPage;
  
  /// Get previous page number
  int get previousPage => currentPage > 1 ? currentPage - 1 : 1;
  
  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage/$lastPage, total: $total)';
  }
}
