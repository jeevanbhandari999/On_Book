
part of 'location_cubit.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationShouldPrompt extends LocationState {
  const LocationShouldPrompt();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationGranted extends LocationState {
  final double latitude;
  final double longitude;
  final String cityName;

  const LocationGranted({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  @override
  List<Object?> get props => [latitude, longitude, cityName];
}

class LocationDenied extends LocationState {
  const LocationDenied();
}