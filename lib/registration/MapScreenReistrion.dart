// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart'; // ใช้แปลงตำแหน่งเป็นจังหวัด

// class MapScreenReistrion extends StatefulWidget {
//   @override
//   _MapScreenReistrionState createState() => _MapScreenReistrionState();
// }

// class _MapScreenReistrionState extends State<MapScreenReistrion> {
//   late GoogleMapController mapController;
//   LatLng? selectedPosition;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Your Location'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check),
//             onPressed: () async {
//               if (selectedPosition != null) {
//                 List<Placemark> placemarks = await placemarkFromCoordinates(
//                   selectedPosition!.latitude,
//                   selectedPosition!.longitude,
//                 );
//                 if (placemarks.isNotEmpty) {
//                   String province =
//                       placemarks[0].administrativeArea ?? 'Unknown';
//                   Navigator.pop(
//                       context, province); // ส่งชื่อจังหวัดกลับไปยังหน้าหลัก
//                 }
//               }
//             },
//           )
//         ],
//       ),
//       body: GoogleMap(
//         onMapCreated: (controller) {
//           mapController = controller;
//         },
//         initialCameraPosition: CameraPosition(
//           target: LatLng(13.736717, 100.523186), // ตำแหน่งเริ่มต้น
//           zoom: 12,
//         ),
//         onTap: (LatLng position) {
//           setState(() {
//             selectedPosition = position;
//           });
//         },
//         markers: selectedPosition != null
//             ? {
//                 Marker(
//                   markerId: MarkerId('selected_position'),
//                   position: selectedPosition!,
//                 ),
//               }
//             : {},
//       ),
//     );
//   }
// }
