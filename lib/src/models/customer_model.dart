import 'card_model.dart';

/// Modelo que representa un cliente en OpenPay
class CustomerModel {
  /// Identificador único del cliente en OpenPay
  final String? id;
  
  /// Fecha de creación del cliente
  final DateTime? creationDate;
  
  /// Nombre del cliente
  final String name;
  
  /// Apellido del cliente
  final String? lastName;
  
  /// Email del cliente
  final String email;
  
  /// Número de teléfono
  final String? phoneNumber;
  
  /// Identificador externo del cliente
  final String? externalId;
  
  /// Dirección del cliente
  final AddressModel? address;
  
  /// Indica si el cliente requiere verificación de cuenta
  final bool? requiresAccount;
  
  /// Estado del cliente
  final String? status;
  
  /// Saldo actual del cliente
  final double? balance;
  
  const CustomerModel({
    this.id,
    this.creationDate,
    required this.name,
    this.lastName,
    required this.email,
    this.phoneNumber,
    this.externalId,
    this.address,
    this.requiresAccount,
    this.status,
    this.balance,
  });
  
  /// Crear instancia desde JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String?,
      creationDate: _parseDate(json['creation_date'] ?? json['creationDate']),
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? json['lastName'],
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      externalId: json['external_id'] ?? json['externalId'],
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      requiresAccount: json['requires_account'] ?? json['requiresAccount'],
      status: json['status'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (creationDate != null) 'creation_date': creationDate!.toIso8601String(),
      'name': name,
      if (lastName != null) 'last_name': lastName,
      'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (externalId != null) 'external_id': externalId,
      if (address != null) 'address': address!.toJson(),
      if (requiresAccount != null) 'requires_account': requiresAccount,
      if (status != null) 'status': status,
      if (balance != null) 'balance': balance,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
  
  /// Obtener nombre completo del cliente
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$name $lastName';
    }
    return name;
  }
  
  /// Verificar si el cliente tiene información completa
  bool get isComplete {
    return name.isNotEmpty &&
           email.isNotEmpty &&
           _isValidEmail(email);
  }
  
  /// Verificar si el email es válido
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  /// Crear una copia del modelo con campos actualizados
  CustomerModel copyWith({
    String? id,
    DateTime? creationDate,
    String? name,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? externalId,
    AddressModel? address,
    bool? requiresAccount,
    String? status,
    double? balance,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      creationDate: creationDate ?? this.creationDate,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      externalId: externalId ?? this.externalId,
      address: address ?? this.address,
      requiresAccount: requiresAccount ?? this.requiresAccount,
      status: status ?? this.status,
      balance: balance ?? this.balance,
    );
  }
  
  @override
  String toString() {
    return 'CustomerModel(id: $id, name: $fullName, email: $email, phoneNumber: $phoneNumber)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CustomerModel &&
        other.id == id &&
        other.creationDate == creationDate &&
        other.name == name &&
        other.lastName == lastName &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.externalId == externalId &&
        other.address == address &&
        other.requiresAccount == requiresAccount &&
        other.status == status &&
        other.balance == balance;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        creationDate.hashCode ^
        name.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        externalId.hashCode ^
        address.hashCode ^
        requiresAccount.hashCode ^
        status.hashCode ^
        balance.hashCode;
  }
}