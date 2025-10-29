import 'package:equatable/equatable.dart';

class Organization extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? address;
  final String? phone;

  // ---- optional location fields (all nullable) ----
  final double? longitude;
  final double? latitude;

  final String createdBy; // auth.users.id
  final DateTime createdAt;
  final DateTime updatedAt;

  const Organization({
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

  Organization copyWith({
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
    return Organization(
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
