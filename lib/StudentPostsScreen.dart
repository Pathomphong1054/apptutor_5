import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'EditPostScreen.dart';

class StudentPostsScreen extends StatefulWidget {
  final String userName;
  final String idUser;

  const StudentPostsScreen({
    Key? key,
    required this.userName,
    required this.idUser,
  }) : super(key: key);

  @override
  _StudentPostsScreenState createState() => _StudentPostsScreenState();
}

class _StudentPostsScreenState extends State<StudentPostsScreen> {
  bool isLoading = false; // ตัวแปรสำหรับแสดง loading state

  Future<List<dynamic>> _fetchPosts() async {
    final response = await http.get(Uri.parse(
        'http://10.5.50.82/tutoring_app/get_student_posts.php?student_id=${widget.idUser}'));

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['posts'];
        } else {
          throw Exception('Failed to load posts: ${responseData['message']}');
        }
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _deletePost(String postId) async {
    setState(() {
      isLoading = true; // เริ่มแสดง loading
    });

    final response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/delete_post_student.php'),
      body: {'postId': postId},
    );

    setState(() {
      isLoading = false; // หยุดแสดง loading
    });

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            _fetchPosts(); // รีเฟรชโพสต์
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing response')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Posts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
            future: _fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No posts available'));
              } else {
                final posts = snapshot.data!;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(
                      post['id'].toString(),
                      post['userName'] ?? 'Unknown User',
                      post['message'] ?? '',
                      post['location'] ?? 'Unknown Location',
                      post['subject'] ?? 'Unknown Subject',
                      post['dateTime'] ?? '',
                    );
                  },
                );
              }
            },
          ),
          // แสดง loading indicator ขณะกำลังลบโพสต์
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCard(String postId, String userName, String message,
      String location, String subject, String dateTime) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แถวที่มีชื่อผู้ใช้และปุ่มแก้ไข/ลบ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ชื่อผู้ใช้งาน
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    // ปุ่มแก้ไขโพสต์
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        _navigateToEditPost(
                            postId, message, location, subject, dateTime);
                      },
                    ),
                    // ปุ่มลบโพสต์
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _confirmDeletePost(postId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 10),
            // ข้อความโพสต์
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            // แสดงตำแหน่งและวิชา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconInfo(Icons.location_on, location, Colors.redAccent),
                _buildIconInfo(Icons.book, subject, Colors.green),
              ],
            ),
            SizedBox(height: 10),
            // วันที่และเวลา
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                dateTime,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
      ],
    );
  }

  // แสดงการยืนยันการลบโพสต์
  void _confirmDeletePost(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Delete",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(postId);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditPost(String postId, String message, String location,
      String subject, String dateTime) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostScreen(
          postId: postId,
          initialMessage: message,
          initialLocation: location,
          initialSubject: subject,
          initialDateTime: dateTime,
        ),
      ),
    );

    // รีเฟรชโพสต์หลังแก้ไขสำเร็จ
    if (result == true) {
      setState(() {
        _fetchPosts();
      });
    }
  }
}
