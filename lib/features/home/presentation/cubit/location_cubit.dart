
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:equatable/equatable.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final FlutterSecureStorage _storage;
  static const _key = 'location_permission_denied';

  LocationCubit({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const LocationInitial());

  // Call this on home page load
  Future<void> checkShouldPrompt() async {
    final denied = await _storage.read(key: _key);
    if (denied == 'true') {
      emit(const LocationDenied());
    } else if (denied == null) {
      emit(const LocationShouldPrompt()); // just emits — no OS popup
    } else {
      await _loadSavedLocation(); // just reads storage — no OS popup
    }
  }

  Future<void> _loadSavedLocation() async {
    final lat = await _storage.read(key: 'location_lat');
    final lng = await _storage.read(key: 'location_lng');
    final city = await _storage.read(key: 'location_city');
    if (lat != null && lng != null) {
      emit(
        LocationGranted(
          latitude: double.parse(lat),
          longitude: double.parse(lng),
          cityName: city ?? '',
        ),
      );
    } else {
      emit(const LocationShouldPrompt());
    }
  }

  Future<void> requestLocation() async {
    emit(const LocationLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _storage.write(key: _key, value: 'true');
        emit(const LocationDenied());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _storage.write(key: _key, value: 'true');
        emit(const LocationDenied());
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String cityName = '';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          cityName =
              placemarks.first.locality ??
              placemarks.first.subAdministrativeArea ??
              '';
        }
      } catch (_) {}

      // Save to secure storage
      await _storage.write(key: _key, value: 'false');
      await _storage.write(
        key: 'location_lat',
        value: position.latitude.toString(),
      );
      await _storage.write(
        key: 'location_lng',
        value: position.longitude.toString(),
      );
      await _storage.write(key: 'location_city', value: cityName);

      emit(
        LocationGranted(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: cityName,
        ),
      );
    } catch (e) {
      await _storage.write(key: _key, value: 'true');
      emit(const LocationDenied());
    }
  }

  void dismiss() {
    // User dismissed without deciding — treat as denied for this session only
    emit(const LocationDenied());
  }

  /// Called when user taps "Location off" to show the permission sheet again
  void promptAgain() {
    emit(const LocationShouldPrompt());
  }
}
