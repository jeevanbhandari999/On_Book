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
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Storage keys
  static const String _prefix = 'library_bookings_';

  LibraryLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
    : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> cacheUserBookings(
    String userId,
    List<BookingModel> bookings,
  ) async {
    try {
      final key = '$_prefix$userId';
      final jsonString = jsonEncode(bookings.map((b) => b.toJson()).toList());
      await secureStorage.write(key: key, value: jsonString);
    } catch (e) {
      throw CacheException('Failed to cache library bookings: $e');
    }
  }

  @override
  Future<List<BookingModel>?> getCachedUserBookings(String userId) async {
    try {
      final key = '$_prefix$userId';
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
      final key = '$_prefix$userId';
      await secureStorage.delete(key: key);
    } catch (_) {}
  }
}
