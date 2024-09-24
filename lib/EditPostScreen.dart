import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String initialMessage;
  final String initialLocation;
  final String initialSubject;
  final String initialDateTime;

  const EditPostScreen({
    Key? key,
    required this.postId,
    required this.initialMessage,
    required this.initialLocation,
    required this.initialSubject,
    required this.initialDateTime,
  }) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController.text = widget.initialMessage;
    _locationController.text = widget.initialLocation;
    _subjectController.text = widget.initialSubject;
    _dateTimeController.text = widget.initialDateTime;
  }

  Future<void> _updatePost() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.243.173/tutoring_app/update_post_student.php'),
      body: {
        'postId': widget.postId,
        'message': _messageController.text,
        'location': _locationController.text,
        'subject': _subjectController.text,
        'dateTime': _dateTimeController.text,
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.of(context).pop(true); // ส่งค่ากลับหน้าหลัก
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 28, 195, 198),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ปรับช่อง Message ให้ใหญ่ขึ้นและรองรับหลายบรรทัด
            _buildMessageField(
              controller: _messageController,
              label: 'Message',
              icon: Icons.message,
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _subjectController,
              label: 'Subject',
              icon: Icons.book,
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _dateTimeController,
              label: 'Date and Time',
              icon: Icons.calendar_today,
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updatePost,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color.fromARGB(255, 28, 195, 198),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Update Post'),
                  ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้าง TextField แบบหลายบรรทัด
  Widget _buildMessageField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      maxLines: 8, // ปรับจำนวนบรรทัดสูงสุด
      minLines: 4, // ปรับจำนวนบรรทัดขั้นต่ำ
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      style: TextStyle(fontSize: 16),
    );
  }

  // ฟังก์ชันสำหรับสร้าง TextField ปกติ
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      style: TextStyle(fontSize: 16),
    );
  }
}
