import 'package:equatable/equatable.dart';
import 'package:app/features/auth/domain/entities/organization.dart';

class OrganizationModel extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? address;
  final String? phone;
  final double? longitude;
  final double? latitude;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
    this.phone,
    this.longitude,
    this.latitude,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  //  FROM JSON (Supabase response)

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      longitude: _toDouble(json['longitude']),
      latitude: _toDouble(json['latitude']),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  //  TO JSON (INSERT / UPDATE)

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'phone': phone,
      'longitude': longitude,
      'latitude': latitude,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'phone': phone,
      'longitude': longitude,
      'latitude': latitude,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  //  COPY WITH

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? address,
    String? phone,
    double? longitude,
    double? latitude,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  //  VALIDATION

  bool isValid() {
    return id.isNotEmpty && name.trim().isNotEmpty;
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Organization ID is required');
    if (name.trim().isEmpty) errors.add('Organization name is required');
    return errors;
  }

  //  ENTITY CONVERSION

  Organization toEntity() {
    return Organization(
      id: id,
      name: name,
      logoUrl: logoUrl,
      address: address,
      phone: phone,
      longitude: longitude,
      latitude: latitude,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory OrganizationModel.fromEntity(Organization entity) {
    return OrganizationModel(
      id: entity.id,
      name: entity.name,
      logoUrl: entity.logoUrl,
      address: entity.address,
      phone: entity.phone,
      longitude: entity.longitude,
      latitude: entity.latitude,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  //  EQUATABLE

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    address,
    phone,
    longitude,
    latitude,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

// Helper – safely cast NUMERIC → double (handles null / int)

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
