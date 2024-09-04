import 'package:apptutor_2/StudentProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorSentRequestsScreen extends StatefulWidget {
  final String tutorName;
  final String tutorId;
  final String userRole;
  final String userName;
  final String idUser;
  final String profileImageUrl;

  TutorSentRequestsScreen({
    required this.tutorName,
    required this.tutorId,
    required this.userRole,
    required this.userName,
    required this.idUser,
    required this.profileImageUrl,
  });

  @override
  _TutorSentRequestsScreenState createState() =>
      _TutorSentRequestsScreenState();
}

class _TutorSentRequestsScreenState extends State<TutorSentRequestsScreen> {
  List<dynamic> sentRequests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSentRequests();
  }

  Future<void> _fetchSentRequests() async {
    if (widget.tutorName.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar('Sender parameter is missing');
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://10.5.50.82/tutoring_app/fetch_sent_requests.php?sender=${widget.tutorName}');
    print('Fetching data from: $url');

    try {
      var response = await http.get(url);
      print('API Response: ${response.body}');
      print('Tutor Name (Sender): ${widget.tutorName}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            sentRequests = data['requests'];
          });
        } else {
          _showErrorSnackBar(
              'Failed to load sent requests: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load sent requests. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        title: Text('Sent Requests',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 28, 195, 198),
              const Color.fromARGB(255, 249, 249, 249),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : sentRequests.isEmpty
                ? Center(
                    child: Text(
                      'No sent requests found',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: sentRequests.length,
                    itemBuilder: (context, index) {
                      final request = sentRequests[index];
                      final studentName = request['recipient'];
                      final requestMessage = request['message'];
                      final isAccepted = request['is_accepted'] == 1;
                      final createdAt = request['created_at'];
                      final profileImage =
                          request['profile_image']; // ดึงข้อมูลรูปโปรไฟล์

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // นำทางไปยังหน้าจอโปรไฟล์นักเรียน
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentProfileScreen(
                                  userName: studentName,
                                  onProfileUpdated: () {},
                                  userRole: 'student',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: profileImage != null &&
                                                profileImage.isNotEmpty
                                            ? NetworkImage(
                                                'http://10.5.50.82/tutoring_app/uploads/$profileImage')
                                            : AssetImage(
                                                    'assets/default_profile.png')
                                                as ImageProvider,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        studentName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        isAccepted
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        color: isAccepted
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    requestMessage,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Sent at: $createdAt',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
