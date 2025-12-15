import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

class BookingModel extends Equatable {
  final String id;
  final String? postId;
  final String userId;
  final String? ownerId;
  final String organizationId;

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
  final double? longitude;
  final double? latitude;

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

  const BookingModel({
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
    this.longitude,
    this.latitude,
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

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      postId: json['post_id'] as String?,
      userId: json['user_id'] as String,
      ownerId: json['owner_id'] as String?,
      organizationId: json['organization_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      primaryImageUrl: json['primary_image_url'] as String,
      additionalImageUrls:
          (json['additional_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      youtubeUrl: json['youtube_url'] as String?,
      price: (json['price'] as num).toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      capacity: json['capacity'] as int?,
      roomType: json['room_type'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      nights: json['nights'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: BookingStatus.values.byName(json['status']),
      paymentStatus: PaymentStatus.values.byName(json['payment_status']),
      paymentId: json['payment_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'owner_id': ownerId,
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'primary_image_url': primaryImageUrl,
      'additional_image_urls': additionalImageUrls,
      'youtube_url': youtubeUrl,
      'price': price,
      'area': area,
      'capacity': capacity,
      'room_type': roomType,
      'amenities': amenities,
      'tags': tags,
      'longitude': longitude,
      'latitude': latitude,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'nights': nights,
      'total_amount': totalAmount,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'payment_id': paymentId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'owner_id': ownerId,
      'organization_id': organizationId,
      'title': title,
      'description': description,
      'primary_image_url': primaryImageUrl,
      'additional_image_urls': additionalImageUrls,
      'youtube_url': youtubeUrl,
      'price': price,
      'area': area,
      'capacity': capacity,
      'room_type': roomType,
      'amenities': amenities,
      'tags': tags,
      'longitude': longitude,
      'latitude': latitude,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'total_amount': totalAmount,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'status': status.name,
      'payment_status': paymentStatus.name,
      'payment_id': paymentId,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? ownerId,
    String? organizationId,
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
    double? longitude,
    double? latitude,
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
    return BookingModel(
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
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
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

  Booking toEntity() => Booking(
    id: id,
    postId: postId,
    userId: userId,
    ownerId: ownerId,
    organizationId: organizationId,
    title: title,
    description: description,
    primaryImageUrl: primaryImageUrl,
    additionalImageUrls: additionalImageUrls,
    youtubeUrl: youtubeUrl,
    price: price,
    area: area,
    capacity: capacity,
    roomType: roomType,
    amenities: amenities,
    tags: tags,
    longitude: longitude,
    latitude: latitude,
    checkInDate: checkInDate,
    checkOutDate: checkOutDate,
    nights: nights,
    totalAmount: totalAmount,
    status: status,
    paymentStatus: paymentStatus,
    paymentId: paymentId,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory BookingModel.fromEntity(Booking booking) {
    return BookingModel(
      id: booking.id,
      postId: booking.postId,
      userId: booking.userId,
      ownerId: booking.ownerId,
      organizationId: booking.organizationId,
      title: booking.title,
      description: booking.description,
      primaryImageUrl: booking.primaryImageUrl,
      additionalImageUrls: booking.additionalImageUrls,
      youtubeUrl: booking.youtubeUrl,
      price: booking.price,
      area: booking.area,
      capacity: booking.capacity,
      roomType: booking.roomType,
      amenities: booking.amenities,
      tags: booking.tags,
      longitude: booking.longitude,
      latitude: booking.latitude,
      checkInDate: booking.checkInDate,
      checkOutDate: booking.checkOutDate,
      nights: booking.nights,
      totalAmount: booking.totalAmount,
      status: booking.status,
      paymentStatus: booking.paymentStatus,
      paymentId: booking.paymentId,
      notes: booking.notes,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
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
    longitude,
    latitude,
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
