import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app_theme.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _position;
  bool _loading = false;
  String? _errorMessage;


  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Please turn on Location Services.';
          _loading = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permission was denied.';
          _loading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permission is permanently denied. Please enable it in Settings.';
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _position = position;
        _loading = false;
      }
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Location error: $e';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPurple,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildLocationContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationContent() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.accentYellow,
            ),
            SizedBox(height: 20),
            Text(
              'Getting your location...',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off,
              color: AppColors.accentYellow,
              size: 55,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_position == null) {
      return const Center(
        child: Text(
          'Location unavailable',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
          ),
        ),
      );
    }

    final LatLng currentLocation = LatLng(
      _position!.latitude,
      _position!.longitude,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Your Location',
            style: TextStyle(
              color: AppColors.accentYellow,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // MAP
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 16,
              ),
              children: [
                // OpenStreetMap
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.womens_safety_platform_app',
                ),

                // Current location marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLocation,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentYellow.withOpacity(0.25),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Coordinates
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF141927),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _coordinateItem(
                'Latitude',
                _position!.latitude.toStringAsFixed(6),
              ),
              _coordinateItem(
                'Longitude',
                _position!.longitude.toStringAsFixed(6),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Refresh button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _getLocation,
            icon: const Icon(Icons.my_location),
            label: const Text(
              'Update My Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentYellow,
              foregroundColor: AppColors.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coordinateItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPurple.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}