import 'dart:io';
import 'package:app/app/app_config.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:go_router/go_router.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? selectedLocation;
  LatLng initialLocation = const LatLng(27.7172, 85.3240);

  final mapController = MapController();
  final String mapTilerKey = AppConfig.mapTilerKey;

  bool isLoadingLocation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: const Text('Pick Location', style: TextStyle(fontSize: 20)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialLocation,
              initialZoom: 10,
              minZoom: 3,
              maxZoom: 20,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.png?key=$mapTilerKey',
                userAgentPackageName: 'com.example.app',
                subdomains: const ['a', 'b', 'c', 'd'],
                maxZoom: 20,
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 50,
                      height: 50,
                      point: selectedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: isLoadingLocation ? null : _getCurrentLocation,
                  icon: isLoadingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    isLoadingLocation
                        ? 'Getting location...'
                        : 'Current Location',
                  ),
                ),
                const SizedBox(height: 10),
                if (selectedLocation != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white70,
                    child: Text(
                      'Lat: ${selectedLocation!.latitude.toStringAsFixed(6)}, '
                      'Lng: ${selectedLocation!.longitude.toStringAsFixed(6)}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: selectedLocation == null
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                if (context.canPop()) {
                  context.pop(selectedLocation);
                } else {
                  Navigator.of(context).pop(selectedLocation);
                }
              },
              child: const Icon(Icons.check, color: Colors.white),
            ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    // iOS — just fake a 1.5s fetch then drop pin at Kathmandu
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        selectedLocation = const LatLng(27.7172, 85.3240);
        isLoadingLocation = false;
      });
      mapController.move(const LatLng(27.7172, 85.3240), 15);
      return;
    }

    // Android — real location
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) throw Exception("Location services disabled.");
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception("Location permission denied.");
        }
      }

      final loc = await location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Location request timed out."),
      );

      final latLng = LatLng(loc.latitude!, loc.longitude!);

      setState(() {
        selectedLocation = latLng;
        mapController.move(latLng, 15);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoadingLocation = false);
    }
  }
}
