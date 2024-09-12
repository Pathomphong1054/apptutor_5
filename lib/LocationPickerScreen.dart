import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({Key? key, required this.initialLocation})
      : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  LatLng _initialPosition = LatLng(13.7563, 100.5018); // Default to Bangkok
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    _setInitialPosition();
  }

  Future<void> _setInitialPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentPosition = LatLng(position.latitude, position.longitude);

      // ตรวจสอบว่า widget ยังคง mounted อยู่หรือไม่ก่อนที่จะเรียก setState
      if (mounted) {
        setState(() {
          _initialPosition = currentPosition;
          _selectedLocation = currentPosition;
          _isMapInitialized = true;
        });
      }

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentPosition, zoom: 15),
        ),
      );
    } catch (e) {
      print("Error getting location: $e");

      // ตรวจสอบว่า widget ยังคง mounted อยู่หรือไม่ก่อนที่จะเรียก setState
      if (mounted) {
        setState(() {
          _isMapInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_selectedLocation);
              },
            ),
        ],
      ),
      body: _isMapInitialized
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (position) {
                setState(() {
                  _selectedLocation = position;
                });
              },
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selectedLocation'),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
