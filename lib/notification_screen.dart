import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

class NotificationScreen extends StatefulWidget {
  final String userName;
  final String userRole;
  final String idUser;
  final String profileImageUrl;
  final String currentUserImage;

  NotificationScreen(
      {required this.userName,
      required this.userRole,
      required this.idUser,
      required this.profileImageUrl,
      required this.currentUserImage});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool hasNewNotifications = false;
  String tutorId = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final response = await http.get(Uri.parse(
        'http://192.168.243.173/tutoring_app/fetch_notifications.php?username=${widget.userName}&role=${widget.userRole}'));

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          List<dynamic> notificationsData = responseData['notifications'];

          if (notificationsData.isNotEmpty) {
            setState(() {
              notifications =
                  notificationsData.map<Map<String, dynamic>>((notification) {
                return {
                  'id':
                      notification['id'].toString(), // Ensure this is a string
                  'sender': notification['sender'],
                  'message': notification['message'],
                  'created_at': notification['created_at'],
                  'type': notification['type'],
                  'is_read': notification['is_read']?.toString() ??
                      '0', // Handle null values and convert to string
                  'sender_image':
                      notification['sender_image'], // Add this if available
                };
              }).toList();

              notifications
                  .sort((a, b) => b['created_at'].compareTo(a['created_at']));
              hasNewNotifications = notifications
                  .any((notification) => notification['is_read'] == '0');
            });
          } else {
            setState(() {
              notifications = [];
            });
          }
        } else {
          throw Exception(
              'Failed to load notifications: ${responseData['message']}');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse notifications: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  Future<void> _updateNotificationStatus(int notificationId) async {
    final response = await http.post(
      Uri.parse('http://192.168.243.173/tutoring_app/update_notification.php'),
      body: {'notification_id': notificationId.toString()},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          notifications = notifications.map((notification) {
            if (notification['id'] == notificationId.toString()) {
              notification['is_read'] = '1'; // Ensure this is a string
            }
            return notification;
          }).toList();
          hasNewNotifications = notifications
              .any((notification) => notification['is_read'] == '0');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notification status')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notification status')),
      );
    }
  }

  void _navigateToChatScreen(
      String recipient, String recipientImage, int notificationId) async {
    await _updateNotificationStatus(notificationId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: widget.userName,
          recipient: recipient,
          recipientImage: recipientImage,
          sessionId: '', // ใส่ session ID ตามที่ต้องการ
          currentUserRole: widget.userRole,
          idUser: widget.idUser,
          userId: widget.idUser,
          tutorId: tutorId, profileImageUrl: widget.profileImageUrl,
          currentUserImage: widget.currentUserImage,
        ),
      ),
    );
  }

  Future<void> _respondToRequest(int notificationId, bool isAccepted) async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.243.173/tutoring_app/respond_to_notification.php'),
      body: {
        'notification_id': notificationId.toString(),
        'is_accepted': isAccepted ? '1' : '0',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request has been responded successfully')),
        );
        _updateNotificationStatus(notificationId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to respond to request')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to respond to request')),
      );
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.243.173/tutoring_app/delete_notification.php'),
        body: {'notification_id': notificationId.toString()},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            notifications.removeWhere((notification) =>
                notification['id'] == notificationId.toString());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification deleted')),
          );
        } else {
          throw Exception(
              'Failed to delete notification: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to delete notification: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: $e')),
      );
    }
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(int.parse(notification['id']));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: _getLeadingIcon(notification),
          title: Text(
            notification['sender'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(notification['message']),
          trailing: Text(notification['created_at'],
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            try {
              int notificationId = int.parse(notification['id']);
              if (notification['type'] == 'chat') {
                _navigateToChatScreen(
                  notification['sender'],
                  notification['sender_image'] ?? 'images/default_profile.jpg',
                  notificationId,
                );
              } else if (notification['type'] == 'request') {
                _respondToRequest(notificationId, true);
              } else {
                _updateNotificationStatus(notificationId);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid notification ID')),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _getLeadingIcon(Map<String, dynamic> notification) {
    if (notification['type'] == 'chat') {
      return Icon(Icons.message, color: Colors.blue);
    } else if (notification['type'] == 'request') {
      return Icon(Icons.request_page, color: Colors.green);
    } else {
      return Icon(Icons.notifications, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        actions: [
          if (hasNewNotifications)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.circle, color: Colors.red, size: 12.0),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
    );
  }
}
