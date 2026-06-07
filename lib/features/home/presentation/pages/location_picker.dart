import 'package:app/app/app_config.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import 'package:app/features/home/presentation/cubit/location_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<LocationCubit>(),
      child: BlocListener<LocationCubit, LocationState>(
        listener: (context, state) {
          // When LocationCubit gets real location, move map to it
          if (state is LocationGranted) {
            final latLng = LatLng(state.latitude, state.longitude);
            setState(() => selectedLocation = latLng);
            mapController.move(latLng, 15);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // ── Map ──────────────────────────────────────────────────────
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: initialLocation,
                  initialZoom: 10,
                  minZoom: 3,
                  maxZoom: 20,
                  onTap: (tapPosition, point) {
                    setState(() => selectedLocation = point);
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
                            color: AppColors.primary,
                            size: 42,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // ── My Location FAB ──────────────────────────────────────────
              BlocBuilder<LocationCubit, LocationState>(
                builder: (context, state) {
                  final isLoading = state is LocationLoading;
                  return Positioned(
                    bottom: 235,
                    right: 12,
                    child: FloatingActionButton(
                      heroTag: 'myLocation',
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: isLoading
                          ? null
                          : () =>
                                context.read<LocationCubit>().requestLocation(),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: AppColors.primary,
                            ),
                    ),
                  );
                },
              ),

              // ── Back FAB ─────────────────────────────────────────────────
              Positioned(
                bottom: 235,
                left: 12,
                child: FloatingActionButton(
                  heroTag: 'back',
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(Icons.arrow_back, color: AppColors.primary),
                ),
              ),

              // ── Bottom Sheet ─────────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      const Text(
                        'Pick Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Coordinates or hint
                      if (selectedLocation == null)
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tap on the map to drop a pin',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lat: ${selectedLocation!.latitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Lng: ${selectedLocation!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Action buttons
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, state) {
                          final isLoading = state is LocationLoading;
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () => context
                                            .read<LocationCubit>()
                                            .requestLocation(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.my_location,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                  label: Text(
                                    isLoading ? 'Locating...' : 'My Location',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: selectedLocation == null
                                      ? null
                                      : () {
                                          if (context.canPop()) {
                                            context.pop(selectedLocation);
                                          } else {
                                            Navigator.of(
                                              context,
                                            ).pop(selectedLocation);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade200,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text(
                                    'Confirm',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
