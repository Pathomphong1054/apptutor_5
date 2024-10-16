import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apptutor_2/StudentProfileScreen.dart';

class FavoriteStudentScreen extends StatefulWidget {
  final String userId;
  final String currentUser;
  final String currentUserImage;

  const FavoriteStudentScreen({
    required this.currentUser,
    required this.userId,
    required this.currentUserImage,
  });

  @override
  _FavoriteStudentScreenState createState() => _FavoriteStudentScreenState();
}

class _FavoriteStudentScreenState extends State<FavoriteStudentScreen> {
  List<Map<String, dynamic>> _favoriteStudents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStudents();
  }

  Future<void> _loadFavoriteStudents() async {
    final url =
        'http://10.5.50.138/tutoring_app/get_favorite_student.php?tutor_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _favoriteStudents =
              data.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load favorite students';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load favorite students';
        _isLoading = false;
      });
    }
  }

  void _viewStudentProfile(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(
          userName: student['name'],
          onProfileUpdated: () {},
          userRole: 'student',
          profileImageUrl: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Students'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      body: Stack(
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
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 60),
                            SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadFavoriteStudents,
                              child: Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _favoriteStudents.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: _favoriteStudents.length,
                          itemBuilder: (context, index) {
                            final student = _favoriteStudents[index];
                            final profileImageUrl = student['profile_images'] !=
                                        null &&
                                    student['profile_images'].isNotEmpty
                                ? 'http://10.5.50.138/tutoring_app/uploads/profile_images/' +
                                    student['profile_images']
                                : 'images/default_profile.jpg';

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      profileImageUrl.contains('http')
                                          ? NetworkImage(profileImageUrl)
                                          : AssetImage(profileImageUrl)
                                              as ImageProvider,
                                ),
                                title: Text(
                                  student['name'] ?? 'Unknown',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                subtitle: Text('Click to view profile'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () => _viewStudentProfile(student),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline,
                                    color: Colors.grey, size: 100),
                                SizedBox(height: 16),
                                Text(
                                  'No favorite students found',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black54),
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
