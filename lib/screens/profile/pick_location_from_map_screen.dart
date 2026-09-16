import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class PickLocationFromMapScreen extends StatefulWidget {
  const PickLocationFromMapScreen({super.key});

  @override
  State<PickLocationFromMapScreen> createState() => _PickLocationFromMapScreenState();
}

class _PickLocationFromMapScreenState extends State<PickLocationFromMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  bool _isLoadingLocation = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isLoadingLocation = true;
      _permissionDenied = false;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      bool? shouldRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permission Needed'),
            content: const Text(
                'Medy24 collects location data to enable picking your delivery address and finding nearby healthcare services on the map.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Deny', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Allow'),
              ),
            ],
          );
        },
      );

      if (shouldRequest != true) {
        setState(() {
          _isLoadingLocation = false;
          _permissionDenied = true;
        });
        return;
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoadingLocation = false;
          _permissionDenied = true;
        });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoadingLocation = false;
        _permissionDenied = true;
      });
      return;
    } 

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _selectedPosition = _currentPosition;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Pick Location',
        subtitle: 'Select delivery address',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Getting current location...', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    if (_permissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.location_slash, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Location permission denied',
              style: AppTextStyles.header,
            ),
            const SizedBox(height: 8),
            const Text('Please enable location permissions in settings.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _determinePosition,
              child: const Text('Try Again'),
            )
          ],
        ),
      );
    }

    final initialCenter = _currentPosition ?? const LatLng(28.6139, 77.2090);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialCenter,
            zoom: 15.0,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: (LatLng location) {
            setState(() {
              _selectedPosition = location;
            });
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _selectedPosition != null
              ? {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: _selectedPosition!,
                  )
                }
              : {},
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedPosition != null) ...[
                    Text(
                      'Selected Coordinates:',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const Text('Tap on the map to select a location', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedPosition == null
                          ? null
                          : () {
                              context.pop({
                                'lat': _selectedPosition!.latitude,
                                'lng': _selectedPosition!.longitude,
                              });
                            },
                      child: const Text('Confirm Location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 160,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              if (_currentPosition != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentPosition!, zoom: 15.0),
                  ),
                );
                setState(() {
                  _selectedPosition = _currentPosition;
                });
              } else {
                _determinePosition();
              }
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        )
      ],
    );
  }
}
