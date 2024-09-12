import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
                  DropdownButtonFormField<String>(
                    value: _selectedProvince,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedProvince = newValue!;
                      });
                    },
                    items: <String>[
                      'Bangkok',
                      'Krabi',
                      'Kanchanaburi',
                      'Kalasin',
                      'Kamphaeng Phet',
                      'Khon Kaen',
                      'Chanthaburi',
                      'Chachoengsao',
                      'Chon Buri',
                      'Chai Nat',
                      'Chaiyaphum',
                      'Chumphon',
                      'Chiang Mai',
                      'Chiang Rai',
                      'Trang',
                      'Trat',
                      'Tak',
                      'Nakhon Nayok',
                      'Nakhon Pathom',
                      'Nakhon Phanom',
                      'Nakhon Ratchasima',
                      'Nakhon Si Thammarat',
                      'Nakhon Sawan',
                      'Nonthaburi',
                      'Narathiwat',
                      'Nan',
                      'Bueng Kan',
                      'Buriram',
                      'Pathum Thani',
                      'Prachuap Khiri Khan',
                      'Prachinburi',
                      'Pattani',
                      'Phra Nakhon Si Ayutthaya',
                      'Phang Nga',
                      'Phatthalung',
                      'Phichit',
                      'Phitsanulok',
                      'Phetchaburi',
                      'Phetchabun',
                      'Phuket',
                      'Maha Sarakham',
                      'Mukdahan',
                      'Mae Hong Son',
                      'Yasothon',
                      'Yala',
                      'Roi Et',
                      'Ranong',
                      'Rayong',
                      'Lopburi',
                      'Lampang',
                      'Lamphun',
                      'Loei',
                      'Si Sa Ket',
                      'Sakon Nakhon',
                      'Songkhla',
                      'Satun',
                      'Samut Prakan',
                      'Samut Sakhon',
                      'Samut Songkhram',
                      'Saraburi',
                      'Sing Buri',
                      'Sukhothai',
                      'Suphan Buri',
                      'Surat Thani',
                      'Surin',
                      'Nong Khai',
                      'Nong Bua Lamphu',
                      'Amnat Charoen',
                      'Udon Thani',
                      'Uttaradit',
                      'Uthai Thani',
                      'Ubon Ratchathani',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Province',
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
      Uri.parse('http://10.5.50.82/tutoring_app/register_student.php'),
    );

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['address'] = _selectedProvince;

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
                  'http://10.5.50.82/tutoring_app/uploads/$profileImageUrl',
              currentUserRole: 'student',
              idUser: '',
              tutorName: '',
              recipientImage: '',
              currentUserImage: '',
              tutorId: '',
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
