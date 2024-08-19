import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final String tutorName;

  const MapScreen({Key? key, required this.tutorName}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(13.7563, 100.5018); // Default to Bangkok
  Set<Marker> _markers = {};
  LatLng? _selectedPosition;
  Location _location = Location();
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    _setInitialPosition();
  }

  Future<void> _setInitialPosition() async {
    try {
      LocationData locationData = await _location.getLocation();
      LatLng currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _initialPosition = currentPosition;
      _setMarker(currentPosition);
      if (_mapController != null) {
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentPosition, zoom: 15),
          ),
        );
      }
      setState(() {
        _isMapInitialized = true; // แสดงว่าแผนที่ถูกตั้งค่าแล้ว
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _isMapInitialized = true; // ถึงแม้จะมีข้อผิดพลาด ให้แสดงแผนที่
      });
    }
  }

  void _setMarker(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(widget.tutorName),
          position: position,
          infoWindow: InfoWindow(title: widget.tutorName),
        ),
      );
    });
  }

  void _sendPositionToChat() {
    if (_selectedPosition != null) {
      Navigator.pop(context, _selectedPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendPositionToChat,
          ),
        ],
      ),
      body: _isMapInitialized
          ? GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_selectedPosition != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _initialPosition, zoom: 15),
                    ),
                  );
                }
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10,
              ),
              markers: _markers,
              onTap: (LatLng position) {
                _setMarker(position);
              },
              myLocationEnabled: true, // แสดงตำแหน่งผู้ใช้บนแผนที่
            )
          : Center(
              child:
                  CircularProgressIndicator()), // แสดง loader ขณะรอการตั้งค่าแผนที่
    );
  }
}
