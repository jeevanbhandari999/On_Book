import 'package:app/app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:convert';

class PostDetailsPage extends StatelessWidget {
  final String title;
  final String
  postGisLocation; // e.g. "0101000020E6100000DBF97E6ABC545540F2B0506B9AB73B40"

  const PostDetailsPage({
    super.key,
    required this.title,
    required this.postGisLocation,
  });

  // Parse PostGIS hex string → LatLng
  LatLng? get location =>
      parsePostGisPoint('0101000020E6100000DBF97E6ABC545540F2B0506B9AB73B40');
  // LatLng? get location => parsePostGisPoint(postGisLocation);

  @override
  Widget build(BuildContext context) {
    print(location);
    final latLng = location;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Location Section
            Text(
              'Location',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Mini Map
            if (latLng != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: latLng,
                      initialZoom: 15,
                      maxZoom: 20,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${AppConfig.mapTilerKey}',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLng,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 50,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('No location available')),
              ),

            const SizedBox(height: 16),

            // Coordinates Text
            if (latLng != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.pin_drop, color: Colors.blue),
                  title: Text(
                    'Coordinates',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Lat: ${latLng.latitude.toStringAsFixed(6)}\nLng: ${latLng.longitude.toStringAsFixed(6)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Optional: copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coordinates copied!')),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

LatLng? parsePostGisPoint(String postGisHex) {
  try {
    // 1. Clean string
    final hex = postGisHex.replaceAll(RegExp(r'\s+'), '');

    // 2. Must start with this exact prefix (SRID 4326 + little-endian)
    if (!hex.startsWith('0101000020E6100000')) {
      print('Invalid PostGIS header');
      return null;
    }

    // 3. Skip the 20-byte (40 hex chars) header → coordinates start at index 40
    if (hex.length < 72) {
      print('String too short');
      return null;
    }

    final coordsHex = hex.substring(40); // This is the key fix!

    // 4. First 16 hex chars = longitude, next 16 = latitude (little-endian)
    final lonHex = coordsHex.substring(0, 16);
    final latHex = coordsHex.substring(16, 32);

    // 5. Convert hex → bytes
    double parseDouble(String h) {
      final bytes = <int>[];
      for (int i = 0; i < 16; i += 2) {
        bytes.add(int.parse(h.substring(i, i + 2), radix: 16));
      }
      return ByteData.sublistView(
        Uint8List.fromList(bytes),
      ).getFloat64(0, Endian.little);
    }

    final longitude = parseDouble(lonHex);
    final latitude = parseDouble(latHex);

    print(
      'Parsed: Lat $latitude, Lng $longitude',
    ); // You will see this in console
    return LatLng(latitude, longitude);
  } catch (e, s) {
    print('PostGIS parse error: $e\n$s');
    return null;
  }
}
