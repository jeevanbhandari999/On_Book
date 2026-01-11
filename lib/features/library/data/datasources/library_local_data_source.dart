import 'dart:convert';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LibraryLocalDataSource {
  // Get the ceched userr booking lists
  Future<List<BookingModel>?> getCachedUserBookings(String userId);

  // Cache the user bookings lists
  Future<void> cacheUserBookings(String userId, List<BookingModel> bookings);

  // Clear cached bookings
  Future<void> clearCachedUserBookings(String userId);

  // Oganizations related
  // Get the ceched organizations booking lists
  Future<List<BookingModel>?> getCachedOrganizationBookings(
    String organizationId,
  );

  // Cache the user bookings lists
  Future<void> cacheOrganizationBookings(
    String organizationId,
    List<BookingModel> bookings,
  );

  // Clear cached bookings
  Future<void> clearCachedOrganizationBookings(String organizationId);

  /// Clear all cached announcements
  Future<void> clearAllCachedBookings();

  /// Get cache timestamp for an organization
  Future<DateTime?> getCacheTimestamp(String organizationId);

  /// Update cache timestamp for an organization
  Future<void> updateCacheTimestamp(String organizationId);

  /// Check if cache is expired for an organization
  Future<bool> isCacheExpired(
    String organizationId, {
    Duration maxAge = const Duration(hours: 1),
  });
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Storage keys
  static const String _bookingPrefix = 'library_booking_';
  static const String _bookingsPrefix = 'library_bookings_';
  static const String _timestampPrefix = 'bookings_timestamp_';

  LibraryLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> cacheUserBookings(
    String userId,
    List<BookingModel> bookings,
  ) async {
    try {
      final key = '$_bookingsPrefix$userId';
      final jsonString = jsonEncode(bookings.map((b) => b.toJson()).toList());
      await secureStorage.write(key: key, value: jsonString);
    } catch (e) {
      throw CacheException('Failed to cache library bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>?> getCachedUserBookings(String userId) async {
    try {
      final key = '$_bookingsPrefix$userId';
      final jsonString = await secureStorage.read(key: key);
      if (jsonString == null) return null;

      final List<dynamic> list = jsonDecode(jsonString);
      return list
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to read cached library bookings: $e');
    }
  }

  @override
  Future<void> clearCachedUserBookings(String userId) async {
    try {
      final key = '$_bookingsPrefix$userId';
      await secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException('Failed to cache library bookings: $e');
    }
  }

  @override
  Future<void> cacheOrganizationBookings(
    String organizationId,
    List<BookingModel> bookings,
  ) async {
    try {
      final key = '$_bookingsPrefix$organizationId';
      final jsonString = jsonEncode(bookings.map((b) => b.toJson()).toList());
      await secureStorage.write(key: key, value: jsonString);
    } catch (e) {
      throw CacheException('Failed to cache library organization bookings: $e');
    }
  }

  @override
  Future<void> clearCachedOrganizationBookings(String organizationId) async {
    try {
      final key = '$_bookingsPrefix$organizationId';
      await secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(
        'Failed to clear cached library organization bookings: $e',
      );
    }
  }

  @override
  Future<List<BookingModel>?> getCachedOrganizationBookings(
    String organizationId,
  ) async {
    try {
      final key = '$_bookingsPrefix$organizationId';
      final jsonString = await secureStorage.read(key: key);
      if (jsonString == null) return null;

      final List<dynamic> list = jsonDecode(jsonString);
      return list
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to read cached library bookings: $e');
    }
  }

  @override
  Future<void> clearAllCachedBookings() async {
    try {
      final allKeys = await secureStorage.readAll();

      final bookingKeys = allKeys.keys.where(
        (key) =>
            key.startsWith(_bookingPrefix) ||
            key.startsWith(_bookingsPrefix) ||
            key.startsWith(_timestampPrefix),
      );
      for (final key in bookingKeys) {
        await secureStorage.delete(key: key);
      }
    } catch (e) {
      throw CacheException('Failed to clear all cached bookings: $e');
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp(String organizationId) {
    // TODO: implement getCacheTimestamp
    throw UnimplementedError();
  }

  @override
  Future<bool> isCacheExpired(
    String organizationId, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    // TODO: implement isCacheExpired
    throw UnimplementedError();
  }

  @override
  Future<void> updateCacheTimestamp(String organizationId) {
    // TODO: implement updateCacheTimestamp
    throw UnimplementedError();
  }
}
