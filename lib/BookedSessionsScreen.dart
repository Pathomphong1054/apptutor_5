import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookedSessionsScreen extends StatefulWidget {
  final String tutorName;
  final String currentUser;
  final String currentUserImage;
  final String idUser;
  final String recipientImage;
  final String profileImageUrl;

  BookedSessionsScreen({
    required this.tutorName,
    required this.currentUser,
    required this.currentUserImage,
    required this.idUser,
    required this.recipientImage,
    required this.profileImageUrl,
  });

  @override
  _BookedSessionsScreenState createState() => _BookedSessionsScreenState();
}

class _BookedSessionsScreenState extends State<BookedSessionsScreen> {
  List<Map<String, dynamic>> bookedSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedSessions(); // ดึงข้อมูลการนัดหมายทั้งหมด
  }

  Future<void> _fetchBookedSessions() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.243.173/tutoring_app/get_booked_sessions.php?tutor=${widget.tutorName}'),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            bookedSessions =
                List<Map<String, dynamic>>.from(responseData['sessions']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถแปลงข้อมูล JSON ได้')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล้มเหลวในการโหลดการนัดหมาย: ${response.body}')),
      );
    }
  }

  Future<void> _cancelSession(String sessionId, DateTime date) async {
    final response = await http.post(
      Uri.parse('http://192.168.243.173/tutoring_app/cancel_session.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'session_id': sessionId}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            bookedSessions
                .removeWhere((session) => session['session_id'] == sessionId);
          });

          _sendMessageToTutor(sessionId, date);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session canceled successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel session: ${response.body}')),
      );
    }
  }

  Future<void> _sendMessageToTutor(String sessionId, DateTime date) async {
    final message = '''
การนัดหมายวันที่ ${date.day}/${date.month}/${date.year} ถูกยกเลิกแล้ว.
''';

    final payload = json.encode({
      'sender': widget.currentUser,
      'recipient': widget.tutorName,
      'message': message,
      'session_id': sessionId,
    });

    final response = await http.post(
      Uri.parse('http://192.168.243.173/tutoring_app/cancel_message.php'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ยกเลิกการนัดหมายสำเร็จและแจ้งติวเตอร์แล้ว')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถแจ้งติวเตอร์ได้: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'การนัดหมายที่จองไว้',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchBookedSessions,
          ),
        ],
      ),
      body: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // เพิ่ม SizedBox เพื่อเพิ่มระยะห่าง
            SizedBox(height: 100),

            Expanded(
              child: bookedSessions.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: bookedSessions.length,
                      itemBuilder: (context, index) {
                        final session = bookedSessions[index];
                        final DateTime date = DateTime.parse(session['date']);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.event_available,
                                        color: Colors.greenAccent,
                                        size: 40,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'วันที่ ${date.day}/${date.month}/${date.year}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'เวลา ${session['start_time']} - ${session['end_time']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      _cancelSession(
                                        session['session_id'].toString(),
                                        date,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'ยังไม่มีการนัดหมาย',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
