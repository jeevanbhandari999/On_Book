import 'package:app/app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class Another extends StatefulWidget {
  const Another({super.key});

  @override
  State<Another> createState() => _AnotherState();
}

class _AnotherState extends State<Another> {
  LatLng? selectedLocation;
  LatLng initialLocation = const LatLng(27.7172, 85.3240); // Kathmandu default

  final mapController = MapController();

  final String mapTilerKey = AppConfig.mapTilerKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MapTiler Demo')),
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
              // TileLayer(
              //   urlTemplate:
              //       'https://api.maptiler.com/maps/satellite/{z}/{x}/{y}.jpg?key=$mapTilerKey',
              //   userAgentPackageName: 'com.example.app',
              //   subdomains: const ['a', 'b', 'c', 'd'],
              // ),
              // TileLayer(
              //   urlTemplate:
              //       "https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.png?key=$mapTilerKey",
              //   userAgentPackageName: 'com.example.app',
              //   subdomains: const ['a', 'b', 'c', 'd'],
              // ),
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
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Current Location'),
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
              onPressed: () {
                Navigator.pop(context, selectedLocation);
              },
              child: const Icon(Icons.check),
            ),
    );
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final loc = await location.getLocation();
    final latLng = LatLng(loc.latitude!, loc.longitude!);

    setState(() {
      selectedLocation = latLng;
      mapController.move(latLng, 15);
    });
  }
}
