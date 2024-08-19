import 'dart:convert';
import 'dart:io';
import 'package:apptutor_2/LocationPickerScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StudentProfileScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onProfileUpdated;

  const StudentProfileScreen({
    Key? key,
    required this.userName,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  File? _profileImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  String? _profileImageUrl;
  bool _isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'http://10.5.50.82/tutoring_app/get_student_profile.php?username=${widget.userName}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);

        if (profileData['status'] == 'success') {
          setState(() {
            _nameController.text = profileData['name'] ?? '';
            _emailController.text = profileData['email'] ?? '';
            _addressController.text = profileData['address'] ?? '';
            _latitudeController.text =
                profileData['latitude']?.toString() ?? '';
            _longitudeController.text =
                profileData['longitude']?.toString() ?? '';
            _profileImageUrl = profileData['profile_image'];
            isLoading = false;
          });
        } else {
          _showSnackBar(
              'Failed to load profile data: ${profileData['message']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        _showSnackBar('Failed to load profile data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.5.50.82/tutoring_app/upload_profile_student.php'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_images',
          imageFile.path,
        ),
      );

      request.fields['username'] = widget.userName;
      request.fields['name'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['address'] = _addressController.text;
      request.fields['latitude'] = _latitudeController.text;
      request.fields['longitude'] = _longitudeController.text;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);

        if (jsonData['status'] == "success") {
          String? imageUrl = jsonData['image_url'];

          setState(() {
            _profileImageUrl = imageUrl;
          });

          _showSnackBar('Profile updated successfully');
          widget.onProfileUpdated();
          setState(() {
            _isEditing = false;
          });
        } else {
          _showSnackBar('Failed to update profile: ${jsonData['message']}');
        }
      } else {
        _showSnackBar('Failed to update profile');
      }
    } catch (e) {
      _showSnackBar('Error uploading profile image: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    LatLng initialLocation = LatLng(
      _latitudeController.text.isNotEmpty
          ? double.parse(_latitudeController.text)
          : 13.7563, // ค่าเริ่มต้นถ้า TextField ว่างเปล่า
      _longitudeController.text.isNotEmpty
          ? double.parse(_longitudeController.text)
          : 100.5018, // ค่าเริ่มต้นถ้า TextField ว่างเปล่า
    );

    final pickedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: initialLocation,
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _latitudeController.text = pickedLocation.latitude.toString();
        _longitudeController.text = pickedLocation.longitude.toString();
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty) {
      _showSnackBar('Please fill in all the fields');
      return;
    }

    if (_profileImage != null) {
      await _uploadProfileImage(_profileImage!);
    } else {
      try {
        var response = await http.post(
          Uri.parse(
              'http://10.5.50.82/tutoring_app/update_student_profile.php'),
          body: {
            'username': widget.userName,
            'name': _nameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'latitude': _latitudeController.text,
            'longitude': _longitudeController.text,
          },
        );

        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          _showSnackBar('Profile updated successfully');
          widget.onProfileUpdated();
          setState(() {
            _isEditing = false;
          });
        } else {
          _showSnackBar('Failed to update profile: ${jsonData['message']}');
        }
      } catch (e) {
        _showSnackBar('Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _updateProfile,
            ),
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _nameController.text.isEmpty
              ? Center(child: Text('No profile data available'))
              : Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color.fromARGB(255, 28, 195, 198),
                            const Color.fromARGB(255, 249, 249, 249),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: GestureDetector(
                              onTap: _isEditing
                                  ? () => _pickImage(ImageSource.gallery)
                                  : null,
                              child: Stack(
                                children: [
                                  // โปรไฟล์รูปภาพ
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 4,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : (_profileImageUrl != null
                                              ? NetworkImage(
                                                  'http://10.5.50.82/tutoring_app/uploads/$_profileImageUrl')
                                              : AssetImage(
                                                      'images/default_profile.jpg')
                                                  as ImageProvider),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                  if (_isEditing)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.blue[800],
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildProfileCard(
                              'Name', _nameController.text, Icons.person),
                          _buildProfileCard(
                              'Email', _emailController.text, Icons.email),
                          _buildProfileCard(
                              'Address', _addressController.text, Icons.home),
                          _buildProfileCard('Latitude',
                              _latitudeController.text, Icons.location_on),
                          _buildProfileCard('Longitude',
                              _longitudeController.text, Icons.location_on),
                          if (_isEditing)
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _getCurrentLocation,
                                icon: Icon(Icons.my_location),
                                label: Text('Use Current Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProfileCard(String label, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
