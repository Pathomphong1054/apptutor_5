import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String tutorName;

  const MapScreen({Key? key, required this.tutorName}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition =
      LatLng(13.7563, 100.5018); // ตัวอย่างตำแหน่งในกรุงเทพฯ
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMarker();
  }

  void _setMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.tutorName),
          position: _initialPosition,
          infoWindow: InfoWindow(title: widget.tutorName),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Location'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 10,
        ),
        markers: _markers,
      ),
    );
  }
}
