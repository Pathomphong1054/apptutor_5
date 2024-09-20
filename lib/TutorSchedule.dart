import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorSchedule extends StatefulWidget {
  final String tutorName;
  final String tutorId;
  final String userName;
  final String currentUserImage; //ไม่มี
  final String profileImageUrl; // รูปติวเตอร์
  final String recipientImage; //รูปติวเตอร์
  final String userImageUrl; //ชื่อติวเตอร์

  TutorSchedule(
      {required this.tutorName,
      required this.tutorId,
      required this.userName,
      required this.currentUserImage,
      required this.profileImageUrl,
      required this.recipientImage,
      required String currentUserRole,
      required this.userImageUrl});

  @override
  _TutorScheduleState createState() => _TutorScheduleState();
}

class _TutorScheduleState extends State<TutorSchedule> {
  List<Map<String, dynamic>> tutorSessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTutorSessions();
  }

  Future<void> _fetchTutorSessions() async {
    final response = await http.get(
      Uri.parse(
          'http://10.5.50.82/tutoring_app/fetch_tutor_sessions.php?tutor=${widget.userName}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          tutorSessions =
              List<Map<String, dynamic>>.from(responseData['sessions']);

          // เรียงลำดับตามวันที่และเวลาล่าสุดขึ้นก่อน
          tutorSessions.sort((a, b) {
            DateTime dateA = DateTime.parse('${a['date']} ${a['start_time']}');
            DateTime dateB = DateTime.parse('${b['date']} ${b['start_time']}');
            return dateB.compareTo(dateA); // เรียงจากล่าสุดไปเก่าสุด
          });

          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ล้มเหลวในการโหลดตารางนัดหมาย: ${responseData['message']}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('ล้มเหลวในการโหลดตารางนัดหมาย: ${response.body}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/delete_session.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': sessionId}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session deleted successfully')),
        );
        setState(() {
          tutorSessions.removeWhere((session) => session['id'] == sessionId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to delete session: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตารางนัดหมายติวเตอร์'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tutorSessions.isEmpty
              ? Center(
                  child: Text(
                    'ไม่มีการนัดหมายในขณะนี้',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: tutorSessions.length,
                  itemBuilder: (context, index) {
                    final session = tutorSessions[index];
                    DateTime sessionDateTime = DateTime.parse(
                        '${session['date']} ${session['start_time']}');
                    bool isPast = sessionDateTime.isBefore(DateTime.now());
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      color: isPast ? Colors.grey[300] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  //         currentUserImage: widget.currentUserImage,

                                  // recipientImage: widget.recipientImage,
                                  // profileImageUrl: widget.profileImageUrl,
                                  backgroundImage: widget
                                          .userImageUrl.isNotEmpty
                                      ? NetworkImage(widget.userImageUrl)
                                      : AssetImage('images/default_profile.jpg')
                                          as ImageProvider,
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'นักเรียน: ${session['student']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'วันที่: ${session['date']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                if (isPast) // แสดงปุ่มลบถ้าเป็น session ที่ผ่านมาแล้ว
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteSession(session['id']
                                          .toString()); // แปลงเป็น String ก่อนส่งไป
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Divider(color: Colors.grey[300]),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.teal[300],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'เวลา: ${session['start_time']} - ${session['end_time']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.teal[300],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'จำนวนนักเรียน: ${session['rate']} คน',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: Colors.teal[300],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'จำนวนเงิน: ${session['amount']} บาท',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
