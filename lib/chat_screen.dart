import 'dart:io';
import 'package:apptutor_2/MapScreen.dart';
import 'package:apptutor_2/StudentProfileScreen.dart';
import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String recipient;
  final String recipientImage;
  final String currentUserImage;
  final String sessionId;
  final String currentUserRole;
  final String idUser;

  const ChatScreen({
    required this.currentUser,
    required this.recipient,
    required this.recipientImage,
    required this.currentUserImage,
    required this.sessionId,
    required this.currentUserRole,
    required this.idUser,
    required userId,
    required tutorId,
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
          'http://10.5.50.82/tutoring_app/fetch_chat.php?sender=${widget.currentUser}&recipient=${widget.recipient}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _messages =
                List<Map<String, dynamic>>.from(responseData['messages']);
            _allMessages[widget.sessionId] = _messages;
            _isLoading = false;
          });
          _scrollToBottom();
        } else {
          throw Exception(
              'Failed to load messages: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load messages: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> createNotification(
      String sender, String recipient, String message, String type) async {
    final response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/create_notification.php'),
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
      final response = await http.post(
        Uri.parse('http://10.5.50.82/tutoring_app/send_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': widget.currentUser,
          'recipient': widget.recipient,
          'message': message,
          'session_id': widget.sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
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

          await createNotification(
              widget.currentUser, widget.recipient, message, 'chat');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to send message: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
    }
  }

  Future<void> _sendImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.5.50.82/tutoring_app/upload_image_chat.php'),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to send image: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      await _sendImage(image);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
            );
          } else {
            return TutorProfileScreen(
              userName: widget.recipient,
              userRole: 'Tutor',
              currentUser: widget.currentUser,
              currentUserImage: widget.currentUserImage,
              username: widget.recipient,
              profileImageUrl: widget.recipientImage,
              userId: widget.idUser,
              tutorId: widget.idUser,
              idUser: widget.idUser,
            );
          }
        },
      ),
    );
  }

  void _viewMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          tutorName: widget.recipient,
        ),
      ),
    );
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "images/chat_background.jpg"), // เปลี่ยนภาพพื้นหลังให้เหมาะสม
                fit: BoxFit.cover,
              ),
            ),
          ),
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

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: isCurrentUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (!isCurrentUser)
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(widget.recipientImage),
                                        radius: 20,
                                      ),
                                    if (!isCurrentUser) SizedBox(width: 10),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? const Color.fromARGB(
                                                255, 94, 202, 241)
                                            : Colors.white.withOpacity(0.9),
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
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: message['image_url'] != null &&
                                              message['image_url']!.isNotEmpty
                                          ? Image.network(
                                              message['image_url']!,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Text(
                                                  'Image failed to load',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                );
                                              },
                                            )
                                          : Text(
                                              message['message'] ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isCurrentUser
                                                    ? Colors.black87
                                                    : Colors.black54,
                                              ),
                                            ),
                                    ),
                                    if (isCurrentUser) SizedBox(width: 10),
                                    if (isCurrentUser)
                                      CircleAvatar(
                                        backgroundImage: widget
                                                .currentUserImage.isNotEmpty
                                            ? NetworkImage(
                                                widget.currentUserImage)
                                            : AssetImage(
                                                    'images/default_profile.jpg')
                                                as ImageProvider,
                                        radius: 20,
                                        backgroundColor: Colors.grey[300],
                                      ),
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
