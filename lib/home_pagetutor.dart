import 'dart:async';
import 'dart:convert';
import 'package:apptutor_2/SettingsScreen.dart';
import 'package:apptutor_2/StudentPostsScreen.dart';
import 'package:apptutor_2/TutorSchedule.dart';
import 'package:apptutor_2/VariableDebugScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'TutorSentRequestsScreen.dart';
import 'chat_screen.dart';
import 'selection_screen.dart';
import 'ChatListScreen.dart';
import 'StudentProfileScreen.dart';
import 'StudentRequestsScreen.dart';
import 'SubjectCategoryScreen.dart';
import 'TutorProfileScreen.dart';
import 'notification_screen.dart';
import 'favoritestudent.dart';
import 'favoritetutor.dart';
import 'package:intl/intl.dart';

class HomePage2 extends StatefulWidget {
  final String userName;
  final String userRole;
  final String profileImageUrl;
  final String currentUserRole;
  final String idUser;
  final String tutorName;
  final String recipientImage;
  final String currentUserImage;
  final String tutorId;
  final String userImageUrl;

  const HomePage2({
    Key? key,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
    required this.currentUserRole,
    required this.idUser,
    required this.tutorName,
    required this.recipientImage,
    required this.currentUserImage,
    required this.tutorId,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> tutors = [];
  List<dynamic> topRatedTutors = [];
  List<dynamic> messages = [];
  bool isLoading = false;
  String? _profileImageUrl;
  String? _userName;
  String searchQuery = '';
  String tutorId = '';
  int _selectedIndex = 0; // Track the selected index
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _profileImageUrl = widget.profileImageUrl;
    if (widget.userRole == 'student') {
      _fetchTutors();
    }
    _fetchProfileImage();
    _fetchMessages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTutors() async {
    _setLoadingState(true);
    var url = Uri.parse('http://192.168.243.173/tutoring_app/fetch_tutors.php');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            tutors = data['tutors'];
            _filterAndSortTutors();
          });
        } else {
          _showErrorSnackBar('Failed to load tutors: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load tutors. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching tutors: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  void _filterAndSortTutors() {
    setState(() {
      topRatedTutors = tutors.where((tutor) {
        final name = tutor['name'] ?? '';
        final subject = tutor['subject'] ?? '';
        final category = tutor['category'] ?? '';
        final topic = tutor['topic'] ?? '';
        final query = searchQuery.toLowerCase();

        return (name.toLowerCase().contains(query) ||
            subject.toLowerCase().contains(query) ||
            category.toLowerCase().contains(query) ||
            topic.toLowerCase().contains(query));
      }).toList();

      topRatedTutors.sort((a, b) {
        final ratingA = double.tryParse(a['average_rating'] ?? '0') ?? 0.0;
        final ratingB = double.tryParse(b['average_rating'] ?? '0') ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      if (topRatedTutors.length > 10) {
        topRatedTutors = topRatedTutors.sublist(0, 10);
      }
    });
  }

  Future<void> _fetchProfileImage() async {
    var url = Uri.parse(
        'http://192.168.243.173/tutoring_app/get_user_profile.php?username=$_userName&role=${widget.userRole}');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _profileImageUrl = data['profile_image'] != null
                ? 'http://192.168.243.173/tutoring_app/uploads/${data['profile_image']}'
                : 'images/default_profile.jpg';
            _userName = data['name'];
          });
        } else {
          _showErrorSnackBar(
              'Failed to load profile image: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load profile image: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching profile image: $e');
    }
  }

  Future<void> _fetchMessages() async {
    _setLoadingState(true);
    var url =
        Uri.parse('http://192.168.243.173/tutoring_app/fetch_messages.php');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          messages = data['messages'];
        });
      } else {
        _showErrorSnackBar('Failed to load messages');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching messages');
    } finally {
      _setLoadingState(false);
    }
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
        'subject': 'N/A',
      };

      var url =
          Uri.parse('http://192.168.243.173/tutoring_app/post_message.php');
      var response =
          await http.post(url, body: json.encode(messageObject), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message posted successfully')),
          );
          _postController.clear();
          _locationController.clear();
          _dateTimeController.clear();
          _fetchMessages();
        } else {
          _showErrorSnackBar(
              'Failed to post message: ${responseData['message']}');
        }
      } else {
        _showErrorSnackBar('Failed to post message');
      }
    } else {
      _showErrorSnackBar('Message, location, and date/time cannot be empty');
    }
  }

  void _removeTutorPost(String tutorName) {
    setState(() {
      tutors.removeWhere((tutor) => tutor['name'] == tutorName);
      _filterAndSortTutors();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          currentUserImage: widget.profileImageUrl,
          sessionId: sessionId,
          currentUserRole: widget.userRole,
          idUser: widget.idUser,
          userId: widget.idUser,
          tutorId: tutorId,
          profileImageUrl: widget.profileImageUrl,
        ),
      ),
    );
  }

  Future<void> _sendRequest(String recipient, String recipientImage) async {
    var response = await http.post(
      Uri.parse('http://192.168.243.173/tutoring_app/send_request.php'),
      body: json.encode({
        'sender': widget.userName,
        'recipient': recipient,
        'message': 'คุณมีคำขอติวใหม่',
        'role': widget.userRole,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('คำขอถูกส่งเรียบร้อย')),
        );
        _fetchMessages();
        _removeTutorPost(recipient);
      } else {
        _showErrorSnackBar('ส่งคำขอไม่สำเร็จ: ${responseData['message']}');
      }
    } else {
      _showErrorSnackBar('ส่งคำขอไม่สำเร็จ');
    }
  }

  void _onProfileUpdated() {
    _fetchProfileImage();
  }

  void _viewProfile(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget.userRole == 'student'
            ? TutorProfileScreen(
                userName: userName,
                onProfileUpdated: _onProfileUpdated,
                canEdit: false,
                userRole: 'Tutor',
                currentUser: widget.userName,
                currentUserImage: widget.profileImageUrl,
                userId: widget.idUser,
                tutorId: tutorId,
                profileImageUrl: _profileImageUrl ?? '',
                username: '',
                idUser: widget.idUser,
                recipientImage: widget.recipientImage,
                currentUserRole: widget.currentUserRole,
              )
            : StudentProfileScreen(
                userName: userName,
                onProfileUpdated: _onProfileUpdated,
                userRole: 'student',
                profileImageUrl: widget.profileImageUrl),
      ),
    );
  }

  void _setLoadingState(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        if (widget.userRole == 'student') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListScreen(
                currentUser: widget.userName,
                currentUserImage: widget.currentUserImage, // รูปของนักเรียน
                currentUserRole: widget.userRole,
                idUser: widget.idUser,
                recipientImage: widget.recipientImage, // รูปของติวเตอร์
                profileImageUrl: widget.profileImageUrl,
              ),
            ),
          );
        } else if (widget.userRole == 'Tutor') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListScreen(
                currentUser: widget.userName,
                currentUserImage: widget.currentUserImage, // รูปของติวเตอร์
                currentUserRole: widget.userRole,
                idUser: widget.idUser,
                recipientImage: widget.recipientImage, // รูปของนักเรียน
                profileImageUrl: widget.profileImageUrl,
              ),
            ),
          );
        }
        break;

      case 2:
        if (widget.userRole == 'student') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoriteTutorsScreen(
                  currentUser: widget.userName,
                  userId: widget.idUser,
                  currentUserImage: '',
                  idUser: widget.idUser,
                  recipientImage: widget.recipientImage,
                  currentUserRole: widget.currentUserRole),
            ),
          );
        } else if (widget.userRole == 'Tutor') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoriteStudentScreen(
                currentUser: widget.userName,
                userId: widget.idUser,
                currentUserImage: '',
              ),
            ),
          );
        }
        break;
      case 3:
        if (widget.userRole == 'student') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentRequestsScreen(
                userName: widget.userName,
                userRole: widget.userRole,
                idUser: widget.idUser,
                profileImageUrl: widget.profileImageUrl,
                recipientImage: widget.recipientImage,
                currentUserRole: widget.currentUserRole,
              ),
            ),
          );
        }
        if (widget.userRole == 'Tutor') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorSentRequestsScreen(
                tutorName: widget.userName, // ใช้ตัวแปรจริงที่เก็บชื่อติวเตอร์
                tutorId: '', // ใช้ ID ของติวเตอร์จริง
                userRole: widget.userRole, // ใช้ role ของผู้ใช้จริง
                userName: widget.userName, // ชื่อผู้ใช้จริง
                idUser: widget.idUser, // ID ของผู้ใช้จริง
                profileImageUrl: widget.profileImageUrl,
              ),
            ),
          );
        }

        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen(
              userName: widget.userName,
              userRole: widget.userRole,
              idUser: widget.idUser,
              profileImageUrl: widget.profileImageUrl,
              currentUserImage: widget.currentUserImage,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      drawer: _buildDrawer(),
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
          SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchField(),
                _buildCommonSection(),
                widget.userRole == 'student'
                    ? _buildStudentBody()
                    : _buildTutorBody(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: _userName != null && _userName!.isNotEmpty
                ? Text(_userName!, style: TextStyle(fontSize: 20))
                : Text('User', style: TextStyle(fontSize: 20)),
            accountEmail: Text(widget.userRole, style: TextStyle(fontSize: 16)),
            currentAccountPicture: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.userRole == 'student'
                        ? StudentProfileScreen(
                            userName: _userName!,
                            onProfileUpdated: _onProfileUpdated,
                            userRole: 'student',
                            profileImageUrl: widget.profileImageUrl,
                          )
                        : TutorProfileScreen(
                            userName: _userName!,
                            onProfileUpdated: _onProfileUpdated,
                            canEdit: true,
                            userRole: 'Tutor',
                            currentUser: widget.userName,
                            currentUserImage: widget.profileImageUrl,
                            username: '',
                            profileImageUrl: '',
                            userId: widget.idUser,
                            tutorId: tutorId,
                            idUser: widget.idUser,
                            recipientImage: widget.recipientImage,
                            currentUserRole: widget.currentUserRole,
                          ),
                  ),
                );
                _onProfileUpdated();
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'images/default_profile.jpg',
                      image: _profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                          ? _profileImageUrl!
                          : 'images/default_profile.jpg',
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset('images/default_profile.jpg',
                            fit: BoxFit.cover, width: 60, height: 60);
                      },
                    ),
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 28, 195, 198),
              // Gradient background
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 28, 195, 198),
                  const Color.fromARGB(255, 5, 102, 106)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blueAccent),
            title: Text('Settings', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          if (widget.userRole == 'Tutor')
            ListTile(
              leading: Icon(Icons.class_, color: Colors.blueAccent),
              title: Text('TutorSchedule', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TutorSchedule(
                            userName: widget.userName,
                            tutorName: '',
                            currentUserImage: widget.currentUserImage,
                            tutorId: '',
                            recipientImage: widget.recipientImage,
                            profileImageUrl: widget.profileImageUrl,
                            currentUserRole: '',
                            userImageUrl: widget.userImageUrl,
                          )
                      // builder: (context) => VariableCheckScreen(
                      //       tutorName: widget.tutorName,
                      //       tutorId: widget.tutorId,
                      //       idUser: widget.idUser,
                      //       // idUser: wuserId,
                      //       userName: widget.userName,
                      //       userRole: widget.userRole,
                      //       currentUser: widget.userName,
                      //       currentUserImage: widget.profileImageUrl,
                      //       userId: widget.idUser,

                      //       profileImageUrl: _profileImageUrl ?? '',
                      //       username: '',

                      //       recipientImage: widget.recipientImage,
                      //       tutorImage: '',
                      //     )
                      ),
                );
              },
            ),
          if (widget.userRole == 'student')
            ListTile(
              leading: Icon(Icons.post_add, color: Colors.blueAccent),
              title: Text('Post', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentPostsScreen(
                      userName: widget.userName,
                    ),
                  ),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.blueAccent),
            title: Text('Log Out', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SelectionScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    // ตรวจสอบบทบาทของผู้ใช้
    if (widget.currentUserRole == 'student') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.blue),
            hintText: 'Search by name, subject, category, or topic',
            hintStyle: TextStyle(fontSize: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (query) {
            setState(() {
              searchQuery = query;
              _filterAndSortTutors();
            });
          },
        ),
      );
    } else {
      return SizedBox.shrink(); // ถ้าไม่ใช่นักเรียน จะไม่แสดงอะไร
    }
  }

  Widget _buildCommonSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Subject Categories',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryIcon(Icons.language, 'Language', Colors.red),
              _buildCategoryIcon(Icons.calculate, 'Mathematics', Colors.green),
              _buildCategoryIcon(Icons.science, 'Science', Colors.blue),
              _buildCategoryIcon(
                  Icons.computer, 'Computer Science', Colors.orange),
              _buildCategoryIcon(Icons.business, 'Business', Colors.purple),
              _buildCategoryIcon(Icons.art_track, 'Arts', Colors.pink),
              _buildCategoryIcon(
                  Icons.sports, 'Physical Education', Colors.teal),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectCategoryScreen(
              category: label,
              userName: widget.userName,
              userRole: widget.userRole,
              profileImageUrl: widget.profileImageUrl,
              idUser: widget.idUser,
              recipientImage: widget.recipientImage,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 40, color: color),
              radius: 40,
            ),
            SizedBox(height: 5),
            Text(label, style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recommended Tutors',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : topRatedTutors.isEmpty
                ? Center(child: Text('No tutors available'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: topRatedTutors.length,
                    itemBuilder: (context, index) {
                      final tutor = topRatedTutors[index];
                      final name = tutor['name'] ?? 'No Name';
                      final category = tutor['category'] ?? 'No Category';
                      final subject = tutor['subject'] ?? 'No Subject';
                      final profileImageUrl = tutor['profile_images'] != null &&
                              tutor['profile_images'].isNotEmpty
                          ? 'http://192.168.243.173/tutoring_app/uploads/' +
                              tutor['profile_images']
                          : 'images/default_profile.jpg';

                      final averageRatingStr = tutor['average_rating'] ?? '0';
                      final averageRating =
                          double.tryParse(averageRatingStr) ?? 0.0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TutorProfileScreen(
                                userName: name,
                                userRole: 'Tutor',
                                canEdit: false,
                                onProfileUpdated: () {},
                                currentUser: widget.userName,
                                currentUserImage: widget.profileImageUrl,
                                userId: widget.idUser,
                                tutorId: tutor['id'].toString(),
                                profileImageUrl: profileImageUrl,
                                username: name,
                                idUser: widget.idUser,
                                recipientImage: widget.recipientImage,
                                currentUserRole: widget.currentUserRole,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white.withOpacity(0.8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: profileImageUrl.contains('http')
                                  ? NetworkImage(profileImageUrl)
                                  : AssetImage(profileImageUrl)
                                      as ImageProvider,
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
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < averageRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: index < averageRating
                                          ? Colors.yellow
                                          : Colors.grey,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildTutorBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome, ${_userName}!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            'You are logged in as a ${widget.userRole}.',
            style: TextStyle(fontSize: 18, color: Colors.blue[800]),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final userName = message['userName'] ?? '';
                  final userImageUrl = message['profileImageUrl'] != null &&
                          message['profileImageUrl'].isNotEmpty
                      ? 'http://192.168.243.173/tutoring_app/uploads/' +
                          message['profileImageUrl']
                      : 'images/default_profile.jpg';
                  final messageText = message['message'] ?? '';
                  final location = message['location'] ?? '';
                  final subject = message['subject'] ?? '';
                  final dateTime = message['dateTime'] ?? '';
                  final sessionId = message['session_id'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      _viewProfile(userName);
                    },
                    child: _buildMessageCard(
                      userName,
                      userImageUrl,
                      messageText,
                      location,
                      subject,
                      dateTime,
                      sessionId,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildMessageCard(
    String userName,
    String userImageUrl,
    String messageText,
    String location,
    String subject,
    String dateTime,
    String sessionId,
  ) {
    // แปลงฟอร์แมตวันเวลาให้ดูสวยงาม
    String formattedDateTime = _formatDateTime(dateTime);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  _viewProfile(userName);
                },
                child: CircleAvatar(
                  backgroundImage: userImageUrl.contains('http')
                      ? NetworkImage(userImageUrl)
                      : AssetImage(userImageUrl) as ImageProvider,
                  radius: 30,
                ),
              ),
              title: Text(
                userName,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                messageText,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                SizedBox(width: 5),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 20),
                Icon(Icons.book, color: Colors.green, size: 18),
                SizedBox(width: 5),
                Text(
                  subject,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedDateTime, // แสดงวันที่ที่ถูกฟอร์แมต
                style: TextStyle(
                  fontSize: 14, // ขยายฟอนต์ให้ดูดีขึ้น
                  color: Colors.blueGrey, // ใช้สีที่อ่านง่ายและสวยงาม
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _sendRequest(userName, userImageUrl);
                },
                icon: Icon(Icons.send),
                label: Text('Send Request'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ฟังก์ชันฟอร์แมตวันเวลา
  String _formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      final formattedDate =
          DateFormat('EEEE, MMM d, yyyy, h:mm a').format(parsedDate);
      return formattedDate;
    } catch (e) {
      return dateTime; // ถ้าแปลงไม่ได้ ให้ใช้ข้อความเดิม
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              size: _selectedIndex == 0 ? 35 : 25,
            ),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.chat,
              color: _selectedIndex == 1 ? Colors.green : Colors.grey,
              size: _selectedIndex == 1 ? 35 : 25,
            ),
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.favorite,
              color: _selectedIndex == 2 ? Colors.red : Colors.grey,
              size: _selectedIndex == 2 ? 35 : 25,
            ),
          ),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.request_page,
              color: _selectedIndex == 3 ? Colors.orange : Colors.grey,
              size: _selectedIndex == 3 ? 35 : 25,
            ),
          ),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.notifications,
              color: _selectedIndex == 4 ? Colors.red : Colors.grey,
              size: _selectedIndex == 4 ? 35 : 25,
            ),
          ),
          label: 'Notifications',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 20.0,
      unselectedFontSize: 12.0,
      backgroundColor:
          Colors.white, // เพิ่มสีพื้นหลังให้กับ BottomNavigationBar
    );
  }
}
