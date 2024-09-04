import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'
    as location_pkg; // ตั้ง alias เป็น location_pkg
import 'package:geocoding/geocoding.dart'
    as geocoding; // ตั้ง alias เป็น geocoding

class MapScreen extends StatefulWidget {
  final String tutorName;
  final LatLng? initialPosition;

  const MapScreen({
    Key? key,
    required this.tutorName,
    this.initialPosition,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(13.7563, 100.5018); // ค่าเริ่มต้นที่กรุงเทพฯ
  Set<Marker> _markers = {};
  LatLng? _selectedPosition;
  location_pkg.Location _location =
      location_pkg.Location(); // ใช้ location จากแพ็กเกจ location
  bool _isMapInitialized = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _initialPosition = widget.initialPosition!;
      _setMarker(_initialPosition);
      _isMapInitialized = true;
    } else {
      _setInitialPosition();
    }
  }

  Future<void> _setInitialPosition() async {
    try {
      location_pkg.LocationData locationData = await _location.getLocation();
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
        _isMapInitialized = true;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _isMapInitialized = true;
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

  Future<void> _searchLocation(String query) async {
    try {
      List<geocoding.Location> locations = await geocoding
          .locationFromAddress(query); // ใช้ location จากแพ็กเกจ geocoding
      if (locations.isNotEmpty) {
        LatLng searchedPosition =
            LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: searchedPosition, zoom: 15),
          ),
        );
        _setMarker(searchedPosition);
      }
    } catch (e) {
      print("Error searching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // ทำให้ AppBar โปร่งใส
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search location',
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _searchLocation(_searchController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please enter a location to search')),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendPositionToChat,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isMapInitialized
              ? GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_selectedPosition != null) {
                      _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: _selectedPosition!, zoom: 15),
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
                  myLocationEnabled: true,
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
