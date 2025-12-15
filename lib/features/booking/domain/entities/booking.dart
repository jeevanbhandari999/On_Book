import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

enum PaymentStatus { pending, paid, refunded, failed }

class Booking extends Equatable {
  final String id;
  final String? postId;
  final String userId;
  final String? ownerId;
  final String organizationId;

  // snapshot fields
  final String title;
  final String? description;
  final String primaryImageUrl;
  final List<String> additionalImageUrls;
  final String? youtubeUrl;

  final double price;
  final double? area;
  final int? capacity;
  final String? roomType;
  final List<String>? amenities;
  final List<String>? tags;
  final double? latitude;
  final double? longitude;

  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final double totalAmount;

  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    this.postId,
    required this.userId,
    this.ownerId,
    required this.organizationId,
    required this.title,
    this.description,
    required this.primaryImageUrl,
    this.additionalImageUrls = const [],
    this.youtubeUrl,
    required this.price,
    this.area,
    this.capacity,
    this.roomType,
    this.amenities,
    this.tags,
    this.latitude,
    this.longitude,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.totalAmount,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Booking copyWith({
    String? id,
    String? postId,
    String? userId,
    String? ownerId,
    String? organizationId,

    // snapshot fields
    String? title,
    String? description,
    String? primaryImageUrl,
    List<String>? additionalImageUrls,
    String? youtubeUrl,

    double? price,
    double? area,
    int? capacity,
    String? roomType,
    List<String>? amenities,
    List<String>? tags,
    double? latitude,
    double? longitude,

    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? nights,
    double? totalAmount,

    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentId,
    String? notes,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      ownerId: ownerId ?? this.ownerId,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      description: description ?? this.description,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      additionalImageUrls: additionalImageUrls ?? this.additionalImageUrls,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      price: price ?? this.price,
      area: area ?? this.area,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      nights: nights ?? this.nights,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    ownerId,
    organizationId,
    title,
    description,
    primaryImageUrl,
    additionalImageUrls,
    youtubeUrl,
    price,
    area,
    capacity,
    roomType,
    amenities,
    tags,
    latitude,
    longitude,
    checkInDate,
    checkOutDate,
    nights,
    totalAmount,
    status,
    paymentStatus,
    paymentId,
    notes,
    createdAt,
    updatedAt,
  ];
}
