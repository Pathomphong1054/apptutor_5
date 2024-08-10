import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

class NotificationScreen extends StatefulWidget {
  final String userName;
  final String userRole;

  NotificationScreen({required this.userName, required this.userRole});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool hasNewNotifications = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final response = await http.get(Uri.parse(
        'http://10.5.50.82/tutoring_app/fetch_notifications.php?username=${widget.userName}&role=${widget.userRole}'));

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          List<dynamic> notificationsData = responseData['notifications'];

          setState(() {
            notifications =
                notificationsData.map<Map<String, dynamic>>((notification) {
              return {
                'id': notification['id'].toString(), // Ensure this is a string
                'sender': notification['sender'],
                'message': notification['message'],
                'created_at': notification['created_at'],
                'type': notification['type'],
                'is_read': notification['is_read']?.toString() ??
                    '0', // Handle null values and convert to string
              };
            }).toList();

            notifications
                .sort((a, b) => b['created_at'].compareTo(a['created_at']));
            hasNewNotifications = notifications
                .any((notification) => notification['is_read'] == '0');
          });
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
      Uri.parse('http://10.5.50.82/tutoring_app/update_notification.php'),
      body: {'notification_id': notificationId.toString()},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          notifications = notifications.map((notification) {
            if (notification['id'] == notificationId) {
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
          currentUserImage: '', // ใส่รูปภาพของผู้ใช้ปัจจุบัน
          sessionId: '', // ใส่ session ID ตามที่ต้องการ
          currentUserRole: widget.userRole,
        ),
      ),
    );
  }

  Future<void> _respondToRequest(int notificationId, bool isAccepted) async {
    final response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/respond_request.php'),
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

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    if (notification['type'] == 'chat') {
      return ListTile(
        leading: Icon(Icons.message, color: Colors.blue),
        title: Text(notification['sender']),
        subtitle: Text(notification['message']),
        trailing: Text(notification['created_at']),
        onTap: () {
          try {
            // ตรวจสอบและแปลง `id` ให้เป็น `int` ก่อนใช้งาน
            int notificationId = int.parse(notification['id']);
            _navigateToChatScreen(
              notification['sender'],
              notification['sender_image'] ?? 'images/default_profile.jpg',
              notificationId,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid notification ID')),
            );
          }
        },
      );
    } else if (notification['type'] == 'request') {
      return ListTile(
        leading: Icon(Icons.request_page, color: Colors.green),
        title: Text(notification['sender']),
        subtitle: Text(notification['message']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () =>
                  _respondToRequest(int.parse(notification['id']), true),
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () =>
                  _respondToRequest(int.parse(notification['id']), false),
              child: Text('Decline'),
            ),
          ],
        ),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.notifications, color: Colors.orange),
        title: Text(notification['sender']),
        subtitle: Text(notification['message']),
        trailing: Text(notification['created_at']),
        onTap: () {
          try {
            int notificationId = int.parse(notification['id']);
            _updateNotificationStatus(notificationId);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid notification ID')),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
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
