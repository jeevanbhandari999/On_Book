import 'package:equatable/equatable.dart';
import 'package:app/features/auth/data/models/user_model.dart' show UserRole;

class User extends Equatable {
  final String id; // UUID from public.users.id
  final String userId; // References auth.users.id (UUID)
  final String fullName; // Required in DB
  final String? imageUrl; // Optional
  final String email; // Optional
  final UserRole role; // Enum: user, owner, admin, manager, worker
  final String? organizationId; // Nullable
  final String? phone; // Optional
  final String? address; // Optional
  final List<Map<String, dynamic>> contacts; // JSONB → List of contact objects
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.userId,
    required this.fullName,
    this.imageUrl,
    required this.email,
    required this.role,
    this.organizationId,
    this.phone,
    this.address,
    this.contacts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    imageUrl,
    role,
    email,
    organizationId,
    phone,
    address,
    contacts,
    createdAt,
    updatedAt,
  ];

  /// Create a copy with updated values
  User copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? imageUrl,
    String? email,
    UserRole? role,
    String? organizationId,
    String? phone,
    String? address,
    List<Map<String, dynamic>>? contacts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      contacts: contacts ?? this.contacts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Optional: Helper to check if profile is complete
  bool get isProfileComplete {
    return fullName.trim().isNotEmpty &&
        phone != null &&
        phone!.trim().isNotEmpty &&
        address != null &&
        address!.trim().isNotEmpty;
  }

  /// Optional: Check if user needs to create an organization
  bool get needsOrganizationCreation {
    return (role == UserRole.owner || role == UserRole.manager) &&
        organizationId == null;
  }
}
