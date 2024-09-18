import 'dart:convert';
import 'dart:io';
import 'package:apptutor_2/FullScreenImageViewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:apptutor_2/LocationPickerScreen.dart';
import 'package:apptutor_2/TutoringScheduleScreen.dart';

class TutorProfileScreen extends StatefulWidget {
  final String userName;
  final String userRole;
  final String tutorId;
  final String userId;
  final VoidCallback? onProfileUpdated;
  final bool canEdit;
  final String currentUser;
  final String currentUserImage;
  final String idUser;
  final String currentUserRole;

  const TutorProfileScreen({
    Key? key,
    required this.userId,
    required this.tutorId,
    required this.userName,
    required this.userRole,
    this.onProfileUpdated,
    this.canEdit = false,
    required this.currentUser,
    required this.currentUserImage,
    required this.idUser,
    required username,
    required String profileImageUrl,
    required String recipientImage,
    required this.currentUserRole,
  }) : super(key: key);

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  File? _profileImage;
  File? _resumeFile;
  TextEditingController _educationLevelController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _topicController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _commentController = TextEditingController();

  String? _profileImageUrl;
  String? _resumeImageUrl;
  bool _isEditing = false;
  bool isLoading = false;
  bool isFavorite = false;
  List<Map<String, dynamic>> _reviews = [];
  int _rating = 0;
  double? _distanceInKm;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchReviews();
    _checkIfFavorite();
    _calculateAndSetDistance();
  }

  Future<void> _calculateAndSetDistance() async {
    try {
      // Parse and validate tutor coordinates
      double tutorLatitude =
          double.tryParse(_latitudeController.text) ?? double.nan;
      double tutorLongitude =
          double.tryParse(_longitudeController.text) ?? double.nan;

      if (tutorLatitude.isNaN ||
          tutorLongitude.isNaN ||
          tutorLatitude < -90 ||
          tutorLatitude > 90 ||
          tutorLongitude < -180 ||
          tutorLongitude > 180) {
        print("Invalid tutor coordinates detected.");
        if (mounted) {
          setState(() {
            _distanceInKm = null; // or some default value indicating error
          });
        }
        return;
      }

      // Get the current position of the student
      Position studentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Calculate distance in meters
      double distanceInMeters = Geolocator.distanceBetween(
        tutorLatitude,
        tutorLongitude,
        studentPosition.latitude,
        studentPosition.longitude,
      );

      // Set the distance in kilometers
      if (mounted) {
        setState(() {
          _distanceInKm = distanceInMeters / 1000; // Convert to kilometers
        });
      }

      print("Distance: $_distanceInKm km");
    } catch (e) {
      print("Error calculating distance: $e");
      if (mounted) {
        setState(() {
          _distanceInKm = null; // or some default value indicating error
        });
      }
    }
  }

  Future<void> _openMapPicker() async {
    LatLng initialLocation = LatLng(
      double.parse(_latitudeController.text.isNotEmpty
          ? _latitudeController.text
          : '13.7563'), // Default location if empty
      double.parse(_longitudeController.text.isNotEmpty
          ? _longitudeController.text
          : '100.5018'),
    );

    LatLng? pickedLocation = await Navigator.push(
      context,
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

      // หลังจากเลือกพิกัดใหม่แล้ว ให้เรียกใช้ฟังก์ชันนี้เพื่ออัปเดตที่อยู่
      _getAddressFromCoordinates(
          pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final apiKey =
        'AIzaSyAijDTG6loIcfDwQyU94VTK0ru1-55OylI'; // ใส่ API Key ของคุณ
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final address = data['results'][0]['formatted_address'];

          // อัปเดต TextField ที่แสดงที่อยู่ด้วยที่อยู่ที่ได้จาก API
          setState(() {
            _addressController.text = address;
          });
        } else {
          _showSnackBar('ไม่สามารถค้นหาที่อยู่ได้');
        }
      } else {
        _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อกับ Geocoding API');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        'http://10.5.50.138/tutoring_app/get_tutor_profile.php?username=${widget.userName}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);

        if (profileData['status'] == 'success') {
          if (mounted) {
            setState(() {
              _nameController.text = profileData['name'] ?? '';
              _categoryController.text = profileData['category'] ?? '';
              _subjectController.text = profileData['subject'] ?? '';
              _topicController.text = profileData['topic'] ?? '';
              _emailController.text = profileData['email'] ?? '';
              _addressController.text = profileData['address'] ?? '';
              _educationLevelController.text =
                  profileData['education_level'] ?? '';
              _latitudeController.text =
                  (profileData['latitude']?.toString() ?? '');
              _longitudeController.text =
                  (profileData['longitude']?.toString() ?? '');
              _profileImageUrl = profileData['profile_image'];
              _resumeImageUrl = profileData['resume_image'];
              _calculateAndSetDistance();
              isLoading = false;
            });
          }
        } else {
          _showSnackBar(
              'Failed to load profile data: ${profileData['message']}');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        _showSnackBar('Failed to load profile data');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.5.50.138/tutoring_app/get_reviews.php?tutor_name=${widget.userName}'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          if (mounted) {
            setState(() {
              _reviews =
                  List<Map<String, dynamic>>.from(responseData['reviews']);
            });
          }
        } else {
          _showSnackBar('Failed to load reviews: ${responseData['message']}');
        }
      } else {
        _showSnackBar('Failed to load reviews');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _checkIfFavorite() async {
    if (widget.tutorId.isEmpty || widget.userId.isEmpty) {
      _showSnackBar(
          'Tutor ID or Student ID is missing, unable to check favorite status');
      return;
    }

    try {
      final url =
          Uri.parse('http://10.5.50.138/tutoring_app/check_favorite.php');
      final response = await http.post(url, body: {
        'student_id': widget.userId,
        'tutor_id': widget.tutorId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              isFavorite = data['is_favorite'];
            });
          }
        } else {
          _showSnackBar('Failed to load favorite status: ${data['message']}');
        }
      } else {
        _showSnackBar(
            'Failed to load favorite status: Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.tutorId.isEmpty) {
      _showSnackBar('Invalid tutor ID');
      return;
    }

    final action = isFavorite ? 'remove' : 'add';

    try {
      final url =
          Uri.parse('http://10.5.50.138/tutoring_app/favorite_tutors.php');
      final response = await http.post(url, body: {
        'student_id': widget.userId.toString(),
        'tutor_id': widget.tutorId.toString(),
        'action': action,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              isFavorite = !isFavorite;
            });
          }
          _showSnackBar('Favorite status updated successfully');
        } else {
          _showSnackBar('Failed to update favorite status: ${data['message']}');
        }
      } else {
        _showSnackBar(
            'Failed to update favorite status: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('Error updating favorite status: $e');
    }
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
      await _uploadProfileImage(_profileImage!);
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.5.50.138/tutoring_app/upload_profile_image.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_images',
          imageFile.path,
        ),
      );
      request.fields['username'] = widget.userName;

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        if (jsonData['status'] == "success") {
          String? imageUrl = jsonData['image_url'];
          if (mounted) {
            setState(() {
              _profileImageUrl = imageUrl;
            });
          }
          _showSnackBar('Profile image uploaded successfully');
          widget.onProfileUpdated?.call();
        } else {
          _showSnackBar(
              'Failed to upload profile image: ${jsonData['message']}');
        }
      } else {
        _showSnackBar(
            'Failed to upload profile image: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('Error uploading profile image: $e');
    }
  }

  Future<void> _pickResume() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _resumeFile = File(pickedFile.path);
        });
      }
      await _uploadResume(_resumeFile!);
    }
  }

  Future<void> _uploadResume(File resumeFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.5.50.138/tutoring_app/upload_resume.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'resumes_images',
          resumeFile.path,
        ),
      );
      request.fields['username'] = widget.userName;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        if (jsonData['status'] == "success") {
          String? resumeUrl = jsonData['resume_url'];
          if (mounted) {
            setState(() {
              _resumeImageUrl = resumeUrl;
            });
          }
          _showSnackBar('Resume uploaded successfully');
        } else {
          _showSnackBar('Failed to upload resume: ${jsonData['message']}');
        }
      } else {
        _showSnackBar('Failed to upload resume');
      }
    } catch (e) {
      _showSnackBar('Error uploading resume: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _topicController.text.isEmpty ||
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
          Uri.parse('http://10.5.50.138/tutoring_app/update_tutor_profile.php'),
          body: {
            'username': widget.userName,
            'name': _nameController.text,
            'category': _categoryController.text,
            'subject': _subjectController.text,
            'topic': _topicController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'latitude': _latitudeController.text,
            'longitude': _longitudeController.text,
          },
        );

        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          _showSnackBar('Profile updated successfully');
          widget.onProfileUpdated?.call();
          if (mounted) {
            setState(() {
              _isEditing = false;
            });
          }
        } else {
          _showSnackBar('Failed to update profile: ${jsonData['message']}');
        }
      } catch (e) {
        _showSnackBar('Error updating profile: $e');
      }
    }
  }

  Future<void> _addReview() async {
    if (_rating == 0 || _commentController.text.isEmpty) {
      _showSnackBar('Please provide a rating and a comment');
      return;
    }

    final review = {
      'tutor_name': widget.userName,
      'rating': _rating,
      'comment': _commentController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.5.50.138/tutoring_app/add_review.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(review),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          _showSnackBar('Review added successfully');
          _fetchReviews();
          _commentController.clear();
          if (mounted) {
            setState(() {
              _rating = 0;
            });
          }
        } else {
          _showSnackBar('Failed to add review: ${responseData['message']}');
        }
      } else {
        _showSnackBar('Failed to add review');
      }
    } catch (e) {
      _showSnackBar('Error adding review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Profile'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        actions: widget.canEdit
            ? [
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      _updateProfile();
                    } else {
                      if (mounted) {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    }
                  },
                ),
              ]
            : null,
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
                              onTap: widget.canEdit && _isEditing
                                  ? () => _pickImage(ImageSource.gallery)
                                  : null,
                              child: CircleAvatar(
                                radius: 70,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (_profileImageUrl != null
                                        ? NetworkImage(
                                            'http://10.5.50.138/tutoring_app/uploads/$_profileImageUrl')
                                        : AssetImage(
                                                'images/default_profile.jpg')
                                            as ImageProvider),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: widget.canEdit && _isEditing
                                        ? Colors.blue[800]
                                        : Colors.transparent,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _distanceInKm != null
                              ? Center(
                                  child: Text(
                                    'Distance from you: ${_distanceInKm!.toStringAsFixed(2)} km',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: _toggleFavorite,
                              ),
                              SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // ตรวจสอบบทบาทผู้ใช้
                                  String role = widget.userRole == 'student'
                                      ? 'student'
                                      : 'Tutor';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TutoringScheduleScreen(
                                        tutorName: widget.userName,
                                        tutorImage: _profileImageUrl ??
                                            'images/default_profile.jpg',
                                        currentUser: widget.currentUser,
                                        currentUserImage:
                                            widget.currentUserImage,
                                        idUser: widget.idUser,
                                        profileImageUrl: '',
                                        recipientImage: '',
                                        userRole:
                                            role, // ส่งค่า role เป็น 'student' หรือ 'Tutor'
                                        currentUserRole: widget.currentUserRole,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.schedule),
                                label: Text("Schedule Tutoring"),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildProfileFieldWithLabel('Name', _nameController),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel(
                              'Category', _categoryController),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel(
                              'Subject', _subjectController),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel(
                              'Topic', _topicController),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel(
                              'Email', _emailController),
                          SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(
                                12.0), // เพิ่ม padding รอบๆ ฟิลด์
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                TextField(
                                  controller: _addressController,
                                  enabled: _isEditing, // เปิดการแก้ไข
                                  maxLines:
                                      null, // เพิ่มความสูงของ TextField ตามเนื้อหาที่อยู่
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10), // เพิ่มพื้นที่ภายใน
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildProfileFieldWithLabel(
                              'Education Level', _educationLevelController),
                          SizedBox(height: 10),
                          _buildLocationFields(),
                          SizedBox(height: 20),
                          _buildResumeSection(),
                          SizedBox(height: 20),
                          _buildReviewAndAddReviewSection(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProfileFieldWithLabel(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white, // พื้นหลังสีขาว
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: controller,
              enabled: _isEditing,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        // _buildProfileFieldWithLabel('Latitude', _latitudeController),
        // SizedBox(height: 10),
        // _buildProfileFieldWithLabel('Longitude', _longitudeController),
        // SizedBox(height: 10),
        if (widget.canEdit && _isEditing)
          Center(
            child: ElevatedButton.icon(
              onPressed: _openMapPicker,
              icon: Icon(Icons.my_location),
              label: Text('Select Location on Map'),
            ),
          ),
      ],
    );
  }

  Widget _buildResumeSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resume',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _resumeImageUrl != null
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrl:
                              'http://10.5.50.138/tutoring_app/uploads/$_resumeImageUrl',
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    'http://10.5.50.138/tutoring_app/uploads/$_resumeImageUrl',
                    height: 400, // กำหนดขนาดรูปในหน้าหลัก (ไม่เต็มจอ)
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  'No resume uploaded',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
          if (widget.canEdit && _isEditing) ...[
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickResume(),
              child: Text('Upload Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewAndAddReviewSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ตรวจสอบว่า ผู้ใช้ที่กำลังดูโปรไฟล์ไม่ใช่ติวเตอร์เจ้าของโปรไฟล์
          if (widget.currentUser != widget.userName) ...[
            Text(
              'Add Review',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.yellow[700] : Colors.grey,
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _rating = index + 1;
                      });
                    }
                  },
                );
              }),
            ),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment',
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _addReview,
                child: Text('Submit Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],

          // ส่วนแสดงรีวิวที่ผู้ใช้งานทุกคนจะเห็น
          Text(
            'Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _reviews.isEmpty
              ? Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
              : Column(
                  children: _reviews.map((review) {
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          int rating = int.parse(review['rating']);
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.yellow[700],
                          );
                        }),
                      ),
                      title: Text('${review['rating']} Stars'),
                      subtitle: Text(review['comment']),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
