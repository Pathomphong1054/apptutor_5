import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'TutorProfileScreen.dart';

class FavoriteTutorsScreen extends StatefulWidget {
  final String userId;
  final String currentUser;
  final String currentUserImage;
  final String idUser;
  final String currentUserRole;

  const FavoriteTutorsScreen({
    required this.currentUser,
    required this.userId,
    required this.currentUserImage,
    required this.idUser,
    required String recipientImage,
    required this.currentUserRole,
  });

  @override
  _FavoriteTutorsScreenState createState() => _FavoriteTutorsScreenState();
}

class _FavoriteTutorsScreenState extends State<FavoriteTutorsScreen> {
  List<Map<String, dynamic>> _favoriteTutors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteTutors();
  }

  Future<void> _loadFavoriteTutors() async {
    final url =
        'http://10.5.50.82/tutoring_app/get_favorite_tutors.php?student_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _favoriteTutors =
              data.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load favorite tutors';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load favorite tutors';
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Tutors'),
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
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  : _favoriteTutors.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: _favoriteTutors.length,
                          itemBuilder: (context, index) {
                            final tutor = _favoriteTutors[index];
                            final id = tutor['id']?.toString() ?? 'No ID';
                            final profileImageUrl = tutor['profile_images'] !=
                                        null &&
                                    tutor['profile_images'].isNotEmpty
                                ? 'http://10.5.50.82/tutoring_app/uploads/' +
                                    tutor['profile_images']
                                : 'images/default_profile.jpg';

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      profileImageUrl.contains('http')
                                          ? NetworkImage(profileImageUrl)
                                          : AssetImage(profileImageUrl)
                                              as ImageProvider,
                                  radius: 30,
                                ),
                                title: Text(
                                  tutor['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  '${tutor['category'] ?? 'No category'} - ${tutor['subject'] ?? 'No subject'}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Implement favorite toggle functionality
                                  },
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TutorProfileScreen(
                                        currentUserRole: widget.currentUserRole,
                                        userId: widget.userId,
                                        tutorId: id,
                                        userName: tutor['name'] ?? 'Unknown',
                                        userRole: 'Tutor',
                                        canEdit: false,
                                        onProfileUpdated: () {},
                                        currentUser: widget.currentUser,
                                        currentUserImage:
                                            widget.currentUserImage,
                                        username: tutor['name'] ?? '',
                                        profileImageUrl:
                                            tutor['profile_images'] ?? '',
                                        idUser: widget.idUser,
                                        recipientImage: '',
                                      ),
                                    ),
                                  );
                                  // Refresh data when coming back
                                  _loadFavoriteTutors();
                                },
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No favorite tutors found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
        ],
      ),
    );
  }
}
