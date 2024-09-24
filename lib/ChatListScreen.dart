import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUser;
  final String currentUserImage;
  final String currentUserRole;
  final String idUser;
  final String recipientImage;
  final String profileImageUrl;

  const ChatListScreen({
    required this.currentUser,
    required this.currentUserImage,
    required this.currentUserRole,
    required this.idUser,
    required this.recipientImage,
    required this.profileImageUrl,
  });

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String tutorId = '';

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.243.173/tutoring_app/fetch_conversations.php?user=${widget.currentUser}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          if (mounted) {
            setState(() {
              _conversations = List<Map<String, dynamic>>.from(
                  responseData['conversations']);

              // เรียงลำดับตาม `timestamp` โดยแชทล่าสุดอยู่ด้านบน
              _conversations.sort((a, b) {
                DateTime dateA = DateTime.parse(a['timestamp']);
                DateTime dateB = DateTime.parse(b['timestamp']);
                return dateB.compareTo(dateA); // dateB อยู่บน dateA
              });

              _isLoading = false;
            });
          }
        } else {
          throw Exception(
              'Failed to load conversations: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to load conversations: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load conversations: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _fetchSessionId(String recipient) async {
    final response = await http.get(Uri.parse(
        'http://192.168.243.173/tutoring_app/fetch_session_id.php?recipient=$recipient&user=${widget.currentUser}'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['session_id'].toString();
      } else {
        throw Exception(
            'Failed to fetch session ID: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to fetch session ID: ${response.reasonPhrase}');
    }
  }

  void _navigateToChatScreen(String recipient, String recipientImage) async {
    try {
      String? sessionId = await _fetchSessionId(recipient);
      if (sessionId != null) {
        print("Navigating to ChatScreen with:");
        print("Recipient Image: $recipientImage");
        print("Current User Image: ${widget.currentUserImage}");
        print("profileImageUrl: ${widget.profileImageUrl}");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              // ตรวจสอบบทบาทของผู้ใช้
              if (widget.currentUserRole == 'student') {
                // สำหรับนักเรียน: currentUserImage คือรูปนักเรียน, recipientImage คือรูปติวเตอร์
                return ChatScreen(
                  currentUser: widget.currentUser,
                  recipient: recipient,
                  recipientImage: recipientImage, // รูปของติวเตอร์
                  currentUserImage: widget.currentUserImage, // รูปของนักเรียน
                  sessionId: sessionId,
                  currentUserRole: widget.currentUserRole,
                  idUser: widget.idUser,
                  userId: widget.idUser,
                  tutorId: tutorId,
                  profileImageUrl: widget.profileImageUrl, // รูปนักเรียนใน Chat
                );
              } else if (widget.currentUserRole == 'Tutor') {
                // สำหรับติวเตอร์: currentUserImage คือรูปติวเตอร์, recipientImage คือรูปนักเรียน
                return ChatScreen(
                  currentUser: widget.currentUser,
                  recipient: recipient,
                  recipientImage: recipientImage, // รูปของนักเรียน
                  currentUserImage: widget.currentUserImage, // รูปของติวเตอร์
                  sessionId: sessionId,
                  currentUserRole: widget.currentUserRole,
                  idUser: widget.idUser,
                  userId: widget.idUser,
                  tutorId: tutorId,
                  profileImageUrl: widget.profileImageUrl, // รูปติวเตอร์ใน Chat
                );
              }
              return SizedBox(); // กรณีที่ไม่มีบทบาทที่กำหนด
            },
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteConversation(int index) async {
    final conversation = _conversations[index];
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.243.173/tutoring_app/delete_conversation.php'),
        body: {
          'user': widget.currentUser,
          'recipient': conversation['recipient_username'],
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _conversations.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Conversation deleted')),
          );
        } else {
          throw Exception(
              'Failed to delete conversation: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to delete conversation: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        elevation: 0,
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
                  : _conversations.isNotEmpty
                      ? ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _conversations[index];
                            return Dismissible(
                              key: Key(conversation['recipient_username']),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _deleteConversation(index);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.red,
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: conversation[
                                                'recipient_image'] !=
                                            null
                                        ? NetworkImage(
                                            'http://192.168.243.173/tutoring_app/uploads/${conversation['recipient_image']}')
                                        : AssetImage(
                                                'images/default_profile.jpg')
                                            as ImageProvider,
                                  ),
                                  title: Text(
                                    conversation['conversation_with'] ??
                                        'unknown_user',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              100,
                                    ),
                                    child: Text(
                                      conversation['last_message'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  trailing: Text(
                                    conversation['timestamp'] != null
                                        ? _formatTimestamp(
                                            conversation['timestamp'])
                                        : '',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  onTap: () {
                                    _navigateToChatScreen(
                                      conversation['recipient_username'] ??
                                          'unknown_user',
                                      conversation['recipient_image'] != null
                                          ? 'http://192.168.243.173/tutoring_app/uploads/${conversation['recipient_image']}'
                                          : 'images/default_profile.jpg',
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No conversations found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                        ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
