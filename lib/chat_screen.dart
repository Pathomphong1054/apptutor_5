import 'dart:io';
import 'package:apptutor_2/MapScreen.dart';
import 'package:apptutor_2/StudentProfileScreen.dart';
import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String recipient;
  final String recipientImage;
  final String currentUserImage;
  final String sessionId;
  final String currentUserRole;
  final String idUser;
  final String profileImageUrl;
  final String tutorId;

  const ChatScreen({
    required this.currentUser,
    required this.recipient,
    required this.recipientImage,
    required this.currentUserImage,
    required this.sessionId,
    required this.currentUserRole,
    required this.idUser,
    required String userId,
    required this.profileImageUrl,
    required this.tutorId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, List<Map<String, dynamic>>> _allMessages = {};
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();
  String? _responseStatus;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
      _messages = _allMessages[widget.sessionId] ?? [];
    });
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.5.50.82/tutoring_app/fetch_chat.php?sender_id=${widget.currentUser}&recipient_id=${widget.recipient}&session_id=${widget.sessionId}'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          if (mounted) {
            // ตรวจสอบก่อนใช้ setState
            setState(() {
              _messages =
                  List<Map<String, dynamic>>.from(responseData['messages']);
              _responseStatus =
                  responseData['response_status']; // Fetch response_status
              _isLoading = false;
            });
            _scrollToBottom(); // Scroll to the latest message
          }
        } else {
          throw Exception(
              'Failed to load messages: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load messages: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        // ตรวจสอบก่อนใช้ setState
        setState(() {
          _errorMessage = 'Failed to load messages: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> createNotification(
      String sender, String recipient, String message, String type) async {
    final response = await http.post(
      Uri.parse('http://10.5.50.138/tutoring_app/create_notification.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender': sender,
        'recipient': recipient,
        'message': message,
        'role': widget.currentUserRole,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] != 'success') {
        print('Failed to create notification: ${responseData['message']}');
      }
    } else {
      print('Failed to create notification: ${response.reasonPhrase}');
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      try {
        // Ensure you fetch the numeric sender and recipient IDs from the database
        final senderId =
            'ACTUAL_SENDER_ID'; // Replace with the actual sender's ID
        final recipientId =
            'ACTUAL_RECIPIENT_ID'; // Replace with the actual recipient's ID

        final response = await http.post(
          Uri.parse('http://10.5.50.138/tutoring_app/send_message.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'sender_id': senderId, // Use sender's numeric ID
            'recipient_id': recipientId, // Use recipient's numeric ID
            'message': message,
            'session_id': widget.sessionId,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            if (mounted) {
              // ตรวจสอบก่อนใช้ setState
              setState(() {
                _messages.add({
                  'sender': widget.currentUser,
                  'recipient': widget.recipient,
                  'message': message,
                  'session_id': widget.sessionId,
                });
                _allMessages[widget.sessionId] = _messages;
                _controller.clear();
              });
              _scrollToBottom();
            }

            await createNotification(senderId, recipientId, message, 'chat');
          } else {
            throw Exception(responseData['message']);
          }
        } else {
          throw Exception('Failed to send message');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
    }
  }

  Future<void> _sendMessageWithLocation(LatLng position) async {
    final message =
        'Location: Lat: ${position.latitude}, Lng: ${position.longitude}';
    try {
      final response = await http.post(
        Uri.parse('http://10.5.50.138/tutoring_app/send_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id':
              widget.currentUser, // เปลี่ยนจาก 'sender' เป็น 'sender_id'
          'recipient_id':
              widget.recipient, // เปลี่ยนจาก 'recipient' เป็น 'recipient_id'
          'message': message,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
          'session_id': widget.sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          if (mounted) {
            // ตรวจสอบก่อนใช้ setState
            setState(() {
              _messages.add({
                'sender': widget.currentUser,
                'recipient': widget.recipient,
                'message': message,
                'latitude': position.latitude.toString(),
                'longitude': position.longitude.toString(),
                'session_id': widget.sessionId,
              });
              _allMessages[widget.sessionId] = _messages;
            });
            _scrollToBottom();
          }

          await createNotification(
              widget.currentUser, widget.recipient, message, 'location');
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Failed to send location');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send location: $e')),
      );
    }
  }

  Future<void> _sendImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.5.50.138/tutoring_app/upload_image_chat.php'),
    );
    request.fields['sender'] = widget.currentUser;
    request.fields['recipient'] = widget.recipient;
    request.fields['session_id'] = widget.sessionId;
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final responseData = json.decode(res.body);

      if (responseData['status'] == 'success') {
        if (mounted) {
          // ตรวจสอบก่อนใช้ setState
          setState(() {
            _messages.add({
              'sender': widget.currentUser,
              'recipient': widget.recipient,
              'message': '[Image]',
              'image_url': responseData['file_path'],
              'session_id': widget.sessionId,
            });
            _allMessages[widget.sessionId] = _messages;
          });
          _scrollToBottom();
        }
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Failed to send image');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      // แสดงรูป Preview ก่อนส่ง
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Preview Image'),
          content: Image.file(image),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ยกเลิกการส่ง
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sendImage(image); // ส่งรูปเมื่อผู้ใช้ยืนยัน
              },
              child: Text('Send'),
            ),
          ],
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendResponse(String responseStatus, int sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.5.50.138/tutoring_app/update_response.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'session_id': sessionId,
          'response_status': responseStatus,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            _responseStatus = responseStatus; // อัปเดตสถานะใน UI
            // อัปเดตสถานะการตอบรับของข้อความ
            _messages = _messages.map((msg) {
              if (msg['session_id'] == widget.sessionId) {
                msg['isResponded'] = true; // ตั้งสถานะให้เป็นตอบรับแล้ว
              }
              return msg;
            }).toList();
          });

          await _sendMessageToStudent(responseStatus);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('การตอบกลับถูกบันทึกสำเร็จ')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('การอัปเดตสถานะล้มเหลว: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('การส่งสถานะล้มเหลว: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _sendMessageToStudent(String responseStatus) async {
    // เตรียมข้อความที่จะส่งไปยังนักเรียน
    String message;
    if (responseStatus == 'accepted') {
      message = 'ติวเตอร์ตอบรับที่จะสอนแล้ว';
    } else {
      message = 'ติวเตอร์ปฏิเสธการสอน';
    }

    // เรียก API เพื่อส่งข้อความ
    final response = await http.post(
      Uri.parse('http://10.5.50.138/tutoring_app/send_message.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender': widget.currentUser, // ติวเตอร์ที่ส่งข้อความ
        'recipient': widget.recipient, // นักเรียน
        'message': message,
        'session_id': widget.sessionId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] != 'success') {
        // หากส่งข้อความไม่สำเร็จ แสดงข้อความแสดงข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('การส่งข้อความล้มเหลว: ${responseData['message']}')),
        );
      }
    } else {
      // แสดงข้อความหากมีข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('การส่งข้อความล้มเหลว: ${response.reasonPhrase}')),
      );
    }
  }

// สร้างปุ่มตกลง/ปฏิเสธที่จะแสดงตามสถานะการตอบรับ
  Widget _buildResponseButtons(int index) {
    // Hide buttons if already responded
    if (_responseStatus == 'accepted' || _responseStatus == 'declined') {
      return SizedBox.shrink(); // If already responded, don't show buttons
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () =>
              _sendResponse('accepted', int.parse(widget.sessionId)),
          child: Text('ตกลง'),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () =>
              _sendResponse('declined', int.parse(widget.sessionId)),
          child: Text('ปฏิเสธ'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  void _viewProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (widget.currentUserRole == 'Tutor') {
            return StudentProfileScreen(
              userName: widget.recipient,
              onProfileUpdated: () {},
              userRole: 'student',
              profileImageUrl: widget.profileImageUrl,
            );
          } else {
            return TutorProfileScreen(
              userName: widget.recipient,
              currentUserRole: widget.currentUserRole,
              canEdit: false,
              userRole: 'Tutor',
              currentUser: widget.currentUser,
              currentUserImage: widget.currentUserImage,
              username: widget.recipient,
              profileImageUrl: widget.recipientImage,
              userId: widget.idUser,
              tutorId: widget.idUser,
              idUser: widget.idUser,
              recipientImage: widget.profileImageUrl,
            );
          }
        },
      ),
    );
  }

  void _openMap(LatLng position) async {
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${position.latitude},${position.longitude}';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  void _viewMap() async {
    LatLng? selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          tutorName: widget.recipient,
          initialPosition: _getPreviousPosition(),
        ),
      ),
    );

    if (selectedPosition != null) {
      await _sendMessageWithLocation(selectedPosition);
      _savePosition(selectedPosition);
    }
  }

  void _savePosition(LatLng position) {
    setState(() {
      _allMessages[widget.sessionId] = _messages;
    });
  }

  LatLng? _getPreviousPosition() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recipient}'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: _viewMap,
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _viewProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              bool isCurrentUser =
                                  message['sender'] == widget.currentUser;
                              LatLng? location;
                              if (message['image_url'] != null &&
                                  message['image_url']!.isNotEmpty) {
                                print(message[
                                    'image_url']); // ตรวจสอบว่า URL ของรูปภาพถูกต้องหรือไม่
                              }
                              if (message['latitude'] != null &&
                                  message['longitude'] != null) {
                                try {
                                  if (message['message'] != null &&
                                      message['message']
                                          .startsWith('Location:')) {
                                    location = LatLng(
                                      double.parse(message['latitude']),
                                      double.parse(message['longitude']),
                                    );
                                  }
                                } catch (e) {
                                  print(
                                      'Error parsing latitude or longitude: $e');
                                  location = null;
                                }
                              }

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: isCurrentUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: isCurrentUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        if (!isCurrentUser)
                                          CircleAvatar(
                                            backgroundImage: widget
                                                    .recipientImage.isNotEmpty
                                                ? NetworkImage(
                                                    widget.recipientImage)
                                                : AssetImage(
                                                        'images/default_profile.jpg')
                                                    as ImageProvider,
                                            radius: 20,
                                            backgroundColor: Colors.grey[300],
                                          ),
                                        if (!isCurrentUser) SizedBox(width: 10),
                                        if (location == null)
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isCurrentUser
                                                  ? const Color.fromARGB(
                                                      255, 94, 202, 241)
                                                  : Colors.white
                                                      .withOpacity(0.9),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomLeft: isCurrentUser
                                                    ? Radius.circular(20)
                                                    : Radius.circular(0),
                                                bottomRight: isCurrentUser
                                                    ? Radius.circular(0)
                                                    : Radius.circular(20),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 2),
                                                  blurRadius: 4.0,
                                                ),
                                              ],
                                            ),
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                            ),
                                            child: message['image_url'] !=
                                                        null &&
                                                    message['image_url']!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    message['image_url']!,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Text(
                                                        'Failed to load image',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      );
                                                    },
                                                  )
                                                : Text(
                                                    message['message'] ?? '',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                          ),
                                      ],
                                    ),
                                    if (location != null)
                                      GestureDetector(
                                        onTap: () => _openMap(location!),
                                        child: Container(
                                          height: 150, // Mini map height
                                          width: 150,
                                          child: GoogleMap(
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: location!,
                                              zoom: 14,
                                            ),
                                            markers: {
                                              Marker(
                                                markerId: MarkerId(
                                                    'location_marker_$index'),
                                                position: location!,
                                              ),
                                            },
                                            gestureRecognizers: Set()
                                              ..add(Factory<
                                                  OneSequenceGestureRecognizer>(
                                                () => EagerGestureRecognizer(),
                                              )),
                                            zoomGesturesEnabled: false,
                                            scrollGesturesEnabled: false,
                                            tiltGesturesEnabled: false,
                                            rotateGesturesEnabled: false,
                                            myLocationButtonEnabled: false,
                                            onTap: (position) {
                                              _openMap(location!);
                                            },
                                          ),
                                        ),
                                      ),
                                    if (!isCurrentUser &&
                                        message['message'] != null &&
                                        message['message']
                                            .contains('ราคาสำหรับ') &&
                                        message['isResponded'] != true)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(height: 10),
                                          _buildResponseButtons(
                                              index), // แสดงปุ่มตกลง/ปฏิเสธ
                                        ],
                                      )
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 28, 195, 198),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.image, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 28, 195, 198),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
