import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
      print('Fetching profile for username: ${widget.userName}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        print('Profile Data: $profileData');

        if (profileData['status'] == 'success') {
          setState(() {
            _nameController.text = profileData['name'] ?? '';
            _emailController.text = profileData['email'] ?? '';
            _addressController.text = profileData['address'] ?? '';
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
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: _isEditing
                                        ? Colors.blue[800]
                                        : Colors.transparent,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildProfileFieldWithLabel(
                              'Name', _nameController, Icons.person),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel(
                              'Email', _emailController, Icons.email),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel('Address',
                              _addressController, Icons.location_city),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProfileFieldWithLabel(
      String label, TextEditingController controller, IconData icon) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isEditing
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black),
                        prefixStyle: TextStyle(color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black),
                    )
                  : _buildProfileInfo(label, controller.text, icon),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
