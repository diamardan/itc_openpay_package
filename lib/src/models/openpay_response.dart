/// Respuesta genérica de la API de OpenPay
class OpenPayResponse<T> {
  /// Datos de la respuesta
  final T? data;
  
  /// Indica si la operación fue exitosa
  final bool success;
  
  /// Mensaje de la respuesta
  final String? message;
  
  /// Código de estado HTTP
  final int statusCode;
  
  /// Información adicional de la respuesta
  final Map<String, dynamic>? metadata;
  
  const OpenPayResponse({
    this.data,
    required this.success,
    this.message,
    required this.statusCode,
    this.metadata,
  });
  
  /// Crear instancia desde JSON
  factory OpenPayResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return OpenPayResponse<T>(
      data: json['data'] == null ? null : fromJsonT(json['data']),
      success: json['success'] ?? false,
      message: json['message'] as String?,
      statusCode: json['status_code'] ?? json['statusCode'] ?? 200,
      metadata: json['metadata'] == null
          ? null
          : Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      if (data != null) 'data': toJsonT(data as T),
      'success': success,
      if (message != null) 'message': message,
      'status_code': statusCode,
      if (metadata != null) 'metadata': metadata,
    };
  }
  
  /// Crear respuesta exitosa
  factory OpenPayResponse.success({
    T? data,
    String? message,
    int statusCode = 200,
    Map<String, dynamic>? metadata,
  }) {
    return OpenPayResponse<T>(
      data: data,
      success: true,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }
  
  /// Crear respuesta de error
  factory OpenPayResponse.error({
    String? message,
    int statusCode = 400,
    Map<String, dynamic>? metadata,
  }) {
    return OpenPayResponse<T>(
      data: null,
      success: false,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }
  
  /// Verificar si la respuesta es exitosa
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  
  /// Verificar si la respuesta es un error
  bool get isError => !success || statusCode >= 400;
  
  /// Verificar si hay datos en la respuesta
  bool get hasData => data != null;
  
  @override
  String toString() {
    return 'OpenPayResponse(success: $success, statusCode: $statusCode, message: $message, hasData: $hasData)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OpenPayResponse<T> &&
        other.data == data &&
        other.success == success &&
        other.message == message &&
        other.statusCode == statusCode;
  }
  
  @override
  int get hashCode {
    return data.hashCode ^
        success.hashCode ^
        message.hashCode ^
        statusCode.hashCode;
  }
}

/// Respuesta paginada de OpenPay
class OpenPayPaginatedResponse<T> {
  /// Lista de elementos
  final List<T> items;
  
  /// Número total de elementos
  final int total;
  
  /// Página actual
  final int page;
  
  /// Número de elementos por página
  final int perPage;
  
  /// Número total de páginas
  final int totalPages;
  
  /// Indica si hay página siguiente
  final bool hasNext;
  
  /// Indica si hay página anterior
  final bool hasPrevious;
  
  const OpenPayPaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
  
  /// Crear instancia desde JSON
  factory OpenPayPaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final List<dynamic> rawItems = json['items'] is List ? json['items'] as List : [];
    return OpenPayPaginatedResponse<T>(
      items: rawItems.map((item) => fromJsonT(item)).toList(),
      total: json['total'] ?? rawItems.length,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? json['perPage'] ?? rawItems.length,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      hasNext: json['has_next'] ?? json['hasNext'] ?? false,
      hasPrevious: json['has_previous'] ?? json['hasPrevious'] ?? false,
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'total': total,
      'page': page,
      'per_page': perPage,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
  
  /// Verificar si está vacía
  bool get isEmpty => items.isEmpty;
  
  /// Verificar si no está vacía
  bool get isNotEmpty => items.isNotEmpty;
  
  /// Obtener el número de elementos en la página actual
  int get count => items.length;
  
  @override
  String toString() {
    return 'OpenPayPaginatedResponse(total: $total, page: $page, perPage: $perPage, count: $count)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OpenPayPaginatedResponse<T> &&
        other.items == items &&
        other.total == total &&
        other.page == page &&
        other.perPage == perPage &&
        other.totalPages == totalPages &&
        other.hasNext == hasNext &&
        other.hasPrevious == hasPrevious;
  }
  
  @override
  int get hashCode {
    return items.hashCode ^
        total.hashCode ^
        page.hashCode ^
        perPage.hashCode ^
        totalPages.hashCode ^
        hasNext.hashCode ^
        hasPrevious.hashCode;
  }
}