import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLocation = const LatLng(22.5726, 88.3639); // Kolkata
  final MapController _mapController = MapController();
  bool _isLocating = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = latLng;
        _isLocating = false;
      });
      _mapController.move(latLng, 15);
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Select Location',
        subtitle: 'Drag the map to pinpoint',
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedLocation = position.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.medy24.app',
              ),
            ],
          ),
          // Static Marker at Center
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(
                Iconsax.location,
                color: AppColors.primary,
                size: 40,
              ).animate().shimmer(duration: 1000.ms),
            ),
          ),
          // Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton.extended(
                  onPressed: _isLocating ? null : _getCurrentLocation,
                  heroTag: 'my_location',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  icon: _isLocating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Iconsax.gps),
                  label: const Text('My Location'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'lat': _selectedLocation.latitude,
                        'lng': _selectedLocation.longitude,
                      });
                    },
                    child: const Text('Confirm Location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
