import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'StudentProfileScreen.dart';
import 'TutorProfileScreen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final String userName;
  final String userRole;
  final String profileImageUrl;
  final String idUser;

  const SubjectDetailScreen({
    Key? key,
    required this.subject,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
    required this.idUser,
    required userId,
    required String tutorId,
  }) : super(key: key);

  @override
  _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  List<dynamic> tutors = [];
  bool isLoading = false;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  String tutorId = '';

  @override
  void initState() {
    super.initState();
    _fetchTutorsBySubject(); // ดึงข้อมูลติวเตอร์จากฐานข้อมูลตามวิชา
  }

  Future<void> _fetchTutorsBySubject() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://10.5.50.82/tutoring_app/fetch_tutors_by_subject.php?subject=${widget.subject['name']}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          tutors = data['tutors'];
        });
      } else {
        _showErrorSnackBar('Failed to load tutors');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching tutors');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _postMessage() async {
    String message = _postController.text.trim();
    String location = _locationController.text.trim();
    String dateTime = _dateTimeController.text.trim();

    if (message.isNotEmpty && location.isNotEmpty && dateTime.isNotEmpty) {
      var messageObject = {
        'message': message,
        'dateTime': dateTime,
        'location': location,
        'userName': widget.userName,
        'profileImageUrl': widget.profileImageUrl,
        'subject': widget.subject['name'],
      };

      print('Posting message: $messageObject');

      var url = Uri.parse('http://10.5.50.82/tutoring_app/post_message.php');
      var response =
          await http.post(url, body: json.encode(messageObject), headers: {
        'Content-Type': 'application/json',
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Message posted successfully')),
            );
            _postController.clear();
            _locationController.clear();
            _dateTimeController.clear();
          } else {
            _showErrorSnackBar(
                'Failed to post message: ${responseData['message']}');
          }
        } catch (e) {
          _showErrorSnackBar('An error occurred while parsing response');
        }
      } else {
        _showErrorSnackBar('Failed to post message');
      }
    } else {
      _showErrorSnackBar('Message, location, and date/time cannot be empty');
    }
  }

  void _navigateToChatScreen(
      String recipient, String recipientImage, String sessionId) {
    if (sessionId.isEmpty) {
      print('Error: sessionId is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: sessionId is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: widget.userName,
          recipient: recipient,
          recipientImage: recipientImage,
          currentUserImage: widget.profileImageUrl,
          sessionId: sessionId,
          currentUserRole: widget.userRole,
          idUser: widget.idUser,
          userId: widget.idUser,
          tutorId: tutorId,
        ),
      ),
    );
  }

  void _viewProfile(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (widget.userRole == 'tutor') {
            return StudentProfileScreen(
              userName: userName,
              onProfileUpdated: () {},
            );
          } else {
            return TutorProfileScreen(
              userName: userName,
              userRole: 'tutor',
              canEdit: false,
              currentUser: widget.userName,
              currentUserImage: widget.profileImageUrl,
              onProfileUpdated: () {},
              username: '',
              profileImageUrl: '',
              userId: widget.idUser,
              tutorId: tutorId,
              idUser: widget.idUser,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject['name']),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject['description'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post a new message:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _postController,
                          decoration: InputDecoration(
                            hintText: 'Enter your message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: 'Enter location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _dateTimeController,
                          decoration: InputDecoration(
                            hintText: 'Enter date and time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _postMessage,
                            icon: Icon(Icons.send),
                            label: Text('Post Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 28, 195, 198),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tutors for ${widget.subject['name']}:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tutors.length,
                    itemBuilder: (context, index) {
                      final tutor = tutors[index];
                      final name = tutor['name'] ?? 'No Name';
                      final category = tutor['category'] ?? 'No Category';
                      final subject = tutor['subject'] ?? 'No Subject';
                      final profileImageUrl = tutor['profile_images'] != null &&
                              tutor['profile_images'].isNotEmpty
                          ? 'http://10.5.50.82/tutoring_app/uploads/' +
                              tutor['profile_images']
                          : 'images/default_profile.jpg';
                      final username = tutor['name'] ?? 'No Username';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TutorProfileScreen(
                                userName: username,
                                userRole: 'Tutor',
                                canEdit: false,
                                onProfileUpdated: () {},
                                currentUser: widget.userName,
                                currentUserImage: widget.profileImageUrl,
                                username: name,
                                profileImageUrl: profileImageUrl,
                                userId: widget.idUser,
                                tutorId: tutor['id'].toString(),
                                idUser: widget.idUser,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                _viewProfile(username);
                              },
                              child: CircleAvatar(
                                backgroundImage:
                                    profileImageUrl.contains('http')
                                        ? NetworkImage(profileImageUrl)
                                        : AssetImage(profileImageUrl)
                                            as ImageProvider,
                              ),
                            ),
                            title: Text(name,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subjects: $subject',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                                Text('Category: $category',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
