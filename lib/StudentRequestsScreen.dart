import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:apptutor_2/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentRequestsScreen extends StatefulWidget {
  final String userName;
  final String idUser;
  final String profileImageUrl;

  StudentRequestsScreen(
      {required this.userName,
      required String userRole,
      required this.idUser,
      required this.profileImageUrl,
      required String recipientImage});

  @override
  _StudentRequestsScreenState createState() => _StudentRequestsScreenState();
}

class _StudentRequestsScreenState extends State<StudentRequestsScreen> {
  List<dynamic> requests = [];
  bool isLoading = false;
  String tutorId = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://10.5.50.82/tutoring_app/fetch_requests.php?recipient=${widget.userName}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            requests = data['requests'];
          });
        } else {
          _showErrorSnackBar('Failed to load requests: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('An error occurred while fetching requests: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _respondToRequest(int requestId, bool isAccepted,
      String tutorName, String tutorProfileImage) async {
    var response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/respond_request.php'),
      body: json.encode({
        'request_id': requestId,
        'is_accepted': isAccepted ? 1 : 0,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          requests
              .removeWhere((request) => request['id'] == requestId.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request responded successfully')),
        );

        // ลบโพสต์ออกจากฐานข้อมูล
        if (isAccepted) {
          await _deletePostByUserName(tutorName);
        }

        if (isAccepted && responseData['sessionId'] != null) {
          _navigateToChatScreen(
              tutorName, tutorProfileImage, responseData['sessionId']);
        }

        // ลบคำขอออกจากฐานข้อมูล
        await _deleteRequestFromDatabase(requestId);
      } else {
        _showErrorSnackBar(
            'Failed to respond to request: ${responseData['message']}');
      }
    } else {
      _showErrorSnackBar('Failed to respond to request');
    }
  }

  Future<void> _deleteRequestFromDatabase(int requestId) async {
    var response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/delete_request.php'),
      body: json.encode({
        'request_id': requestId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      _showErrorSnackBar('Failed to delete request from database');
    }
  }

  Future<void> _deletePostByUserName(String userName) async {
    var response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/delete_post_by_username.php'),
      body: json.encode({
        'user_name': userName,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      _showErrorSnackBar('Failed to delete post from database');
    }
  }

  void _navigateToChatScreen(
      String recipient, String recipientImage, String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: widget.userName,
          recipient: recipient,
          recipientImage: recipientImage,
          currentUserImage:
              '', // Add the current user's profile image URL here if available
          sessionId: sessionId,
          currentUserRole: 'student',
          idUser: widget.idUser,
          userId: widget.idUser,
          tutorId: tutorId, profileImageUrl: widget.profileImageUrl,
        ),
      ),
    );
  }

  void _viewTutorProfile(String tutorName, String tutorProfileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorProfileScreen(
          userName: tutorName,
          userRole: 'Tutor',
          canEdit: false,
          currentUser: widget.userName,
          currentUserImage:
              '', // Add the current user's profile image URL here if available
          onProfileUpdated: () {},
          username: tutorName,
          profileImageUrl: tutorProfileImage,
          userId: widget.idUser,
          tutorId: tutorId,
          idUser: widget.idUser, recipientImage: '',
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Requests'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty,
                            color: Colors.grey, size: 60),
                        SizedBox(height: 16),
                        Text(
                          'No requests found',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final tutorName = request['sender'];
                    final tutorProfileImage = request['profileImage'];
                    final isAccepted = request['is_accepted'] == 1;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () =>
                              _viewTutorProfile(tutorName, tutorProfileImage),
                          child: CircleAvatar(
                            backgroundImage: tutorProfileImage != null &&
                                    tutorProfileImage.isNotEmpty
                                ? NetworkImage(
                                    'http://10.5.50.82/tutoring_app/uploads/$tutorProfileImage')
                                : AssetImage('images/default_profile.jpg')
                                    as ImageProvider,
                          ),
                        ),
                        title: Text(
                          request['sender'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          request['message'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: isAccepted
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      int requestId = int.parse(request['id']);
                                      _respondToRequest(requestId, true,
                                          tutorName, tutorProfileImage);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                    child: Text('Accept'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      int requestId = int.parse(request['id']);
                                      _respondToRequest(requestId, false,
                                          tutorName, tutorProfileImage);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text('Decline'),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
