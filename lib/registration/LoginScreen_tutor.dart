import 'package:apptutor_2/registration/students_password_reset_screen.dart';
import 'package:apptutor_2/registration/tutor_password_reset_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home_pagetutor.dart';
import 'tutor_registration_screen.dart';

class LoginScreenTutor extends StatefulWidget {
  @override
  _LoginScreenTutorState createState() => _LoginScreenTutorState();
}

class _LoginScreenTutorState extends State<LoginScreenTutor> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login(BuildContext context) async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/login.php'),
      body: {
        'email': email,
        'password': password,
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        String userId = responseData['id'].toString();
        String userName = responseData['name'];
        String userRole = responseData['role'];
        String profileImageUrl = responseData['profile_image'] != null
            ? 'http://10.5.50.82/tutoring_app/uploads/' +
                responseData['profile_image']
            : 'images/default_profile.jpg';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage2(
              idUser: userId,
              userName: userName,
              userRole: userRole,
              profileImageUrl: profileImageUrl,
              currentUserRole: 'Tutor',
              tutorName: '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 28, 195, 198),
                  const Color.fromARGB(255, 249, 249, 249)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Image.asset(
                      'images/apptutor.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please login to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => login(context),
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 15),
                              backgroundColor:
                                  const Color.fromARGB(255, 5, 162, 186),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TutorRegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Register here',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdatePasswordScreen(userRole: 'Tutor'),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password? Reset here',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
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
}
