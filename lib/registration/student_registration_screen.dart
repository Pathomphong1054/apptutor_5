import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:apptutor_2/LocationPickerScreen.dart'; // เพิ่มการ import หน้าจอเลือกแผนที่
import '../home_pagetutor.dart';

class StudentRegistrationScreen extends StatefulWidget {
  @override
  _StudentRegistrationScreenState createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _selectedProvince = 'Bangkok';
  bool _isLoading = false;
  File? _profileImage;
  TextEditingController _addressController =
      TextEditingController(); // ควบคุมที่อยู่ที่เลือก
  double? _selectedLatitude; // ตัวแปรสำหรับเก็บละติจูด
  double? _selectedLongitude; // ตัวแปรสำหรับเก็บลองจิจูด

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 28, 195, 198),
                  const Color.fromARGB(255, 249, 249, 249)
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Fill in the details to register as a student:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('images/default_profile.jpg')
                                as ImageProvider,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.blue[800],
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),

                  // ปุ่มเลือกที่อยู่จากแผนที่
                  TextFormField(
                    controller: _addressController, // ฟิลด์แสดงที่อยู่ที่เลือก
                    readOnly: true, // ไม่ให้ผู้ใช้พิมพ์ในฟิลด์นี้
                    onTap: _selectLocation, // เมื่อกดที่ฟิลด์ จะเปิดแผนที่
                    decoration: InputDecoration(
                      labelText: 'Select Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: Icon(Icons.location_city, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => registerStudent(context),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              backgroundColor:
                                  const Color.fromARGB(255, 5, 162, 186),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                            child: Text(
                              'Register as Student',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectLocation() async {
    LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: LatLng(13.7563, 100.5018), // พิกัดเริ่มต้น
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLatitude = pickedLocation.latitude;
        _selectedLongitude = pickedLocation.longitude;
      });

      // เมื่อผู้ใช้เลือกพิกัดแล้ว ดึงที่อยู่จากพิกัด
      _getAddressFromCoordinates(
          pickedLocation.latitude, pickedLocation.longitude);
    }
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final apiKey =
        'AIzaSyAifMkvdmH00OHXVAw1RNV4nsL56vQWAzQ'; // ใส่ API Key ของคุณ
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final address = data['results'][0]['formatted_address'];

          // อัปเดตฟิลด์ที่อยู่ด้วยที่อยู่ที่ได้จาก API
          setState(() {
            _addressController.text = address;
          });
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );
    return emailRegExp.hasMatch(email);
  }

  Future<void> registerStudent(BuildContext context) async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.5.50.138/tutoring_app/register_student.php'),
    );

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['address'] = _addressController.text; // ที่อยู่จากแผนที่
    request.fields['latitude'] = _selectedLatitude.toString(); // ส่งละติจูด
    request.fields['longitude'] = _selectedLongitude.toString(); // ส่งลองจิจูด

    request.files.add(await http.MultipartFile.fromPath(
      'profile_image',
      _profileImage!.path,
    ));

    var response = await request.send();

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print('Response Data: $responseData'); // เพิ่มการพิมพ์ข้อมูล response

      try {
        var data = json.decode(responseData);
        if (data['status'] == 'success') {
          // ดำเนินการต่อ
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing server response')),
        );
      }

      var data = json.decode(responseData);

      if (data['status'] == 'success') {
        String userName = name;
        String profileImageUrl = data['profile_image'] ??
            'default_profile.jpg'; // ใช้ค่าเริ่มต้นถ้า profile_image เป็น null

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage2(
              userName: userName,
              userRole: 'student',
              profileImageUrl:
                  'http://10.5.50.138/tutoring_app/uploads/$profileImageUrl',
              currentUserRole: 'student',
              idUser: '',
              tutorName: '',
              recipientImage: '',
              currentUserImage: '',
              tutorId: '',
              userImageUrl: '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    }
  }
}
