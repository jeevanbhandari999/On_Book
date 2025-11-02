import 'package:app/app/dependency_injection.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/auth/domain/entities/user.dart';

/// Enum for user roles - matches your CHECK constraint
enum UserRole { user, owner, admin, manager, worker }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.owner:
        return 'owner';
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.worker:
        return 'worker';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'worker':
        return UserRole.worker;
      default:
        return UserRole.user;
    }
  }
}

/// UserModel - mirrors Supabase `public.users` table (without `location`)
class UserModel extends Equatable {
  final String id;
  final String userId; // Supabase auth.users.id
  // this is for getting the email
  final String? email;
  final String fullName;
  final String? imageUrl;
  final UserRole role;
  final String? organizationId;
  final String? phone;
  final String? address;
  final List<Map<String, dynamic>> contacts; // JSONB → List of maps
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email,
    this.imageUrl,
    required this.role,
    this.organizationId,
    this.phone,
    this.address,
    this.contacts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory from Supabase JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email']?.toString(),
      imageUrl: json['image_url'] as String?,
      role: UserRoleExtension.fromString(json['role'] as String? ?? 'user'),
      organizationId: json['organization_id'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      contacts: _parseContacts(json['contacts']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'image_url': imageUrl,
      'role': role.value,
      'organization_id': organizationId,
      'phone': phone,
      'address': address,
      'contacts': contacts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  UserModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? imageUrl,
    UserRole? role,
    String? organizationId,
    String? phone,
    String? address,
    List<Map<String, dynamic>>? contacts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      contacts: contacts ?? this.contacts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to Domain Entity
  User toEntity() {
    return User(
      id: id,
      userId: userId,
      fullName: fullName,
      imageUrl: imageUrl,
      role: role,
      organizationId: organizationId,
      phone: phone,
      address: address,
      contacts: contacts,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return fullName.trim().isNotEmpty &&
        phone != null &&
        phone!.trim().isNotEmpty &&
        address != null &&
        address!.trim().isNotEmpty;
  }

  /// Check if user needs to create organization (owner/manager without org)
  bool get needsOrganizationCreation {
    return (role == UserRole.owner || role == UserRole.manager) &&
        organizationId == null;
  }

  /// Validate user data
  bool isValid() {
    return id.isNotEmpty && userId.isNotEmpty && fullName.trim().isNotEmpty;
  }

  /// Extract email from userId (fallback if not in model)
  String? get emailFromUserId {
    // Supabase auth.users.id is UUID, not email
    // So email is NOT in this model — get from auth separately
    final authService = DependencyInjection.get<AuthService>();
    final email = authService.currentUser!.email;
    if (email == null) throw Exception('Email not found');
    return email;
  }

  List<String> getValidationErrors() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('User ID is required');
    if (userId.isEmpty) errors.add('Auth User ID is required');
    if (fullName.trim().isEmpty) errors.add('Full name is required');

    return errors;
  }

  /// Helper: Parse JSONB contacts safely
  static List<Map<String, dynamic>> _parseContacts(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .cast<Map<String, dynamic>?>()
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    imageUrl,
    role,
    organizationId,
    phone,
    address,
    contacts,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'UserModel{id: $id, fullName: $fullName, role: $role, org: $organizationId}';
  }
}
