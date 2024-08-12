import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorSentRequestsScreen extends StatefulWidget {
  final String tutorName;
  final String tutorId;

  TutorSentRequestsScreen({
    required this.tutorName,
    required this.tutorId,
    required String userRole,
    required String userName,
    required String idUser,
  });

  @override
  _TutorSentRequestsScreenState createState() =>
      _TutorSentRequestsScreenState();
}

class _TutorSentRequestsScreenState extends State<TutorSentRequestsScreen> {
  List<dynamic> sentRequests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSentRequests();
  }

  Future<void> _fetchSentRequests() async {
    if (widget.tutorName.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar('Sender parameter is missing');
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://10.5.50.82/tutoring_app/fetch_sent_requests.php?sender=${widget.tutorName}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            sentRequests = data['requests'];
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorSnackBar(
                'Failed to load sent requests: ${data['message']}');
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorSnackBar(
              'Failed to load sent requests. Status code: ${response.statusCode}');
        });
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(
            'An error occurred while fetching sent requests: $e');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sent Requests'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : sentRequests.isEmpty
              ? Center(child: Text('No sent requests found'))
              : ListView.builder(
                  itemCount: sentRequests.length,
                  itemBuilder: (context, index) {
                    final request = sentRequests[index];
                    final studentName = request['recipient'];
                    final requestMessage = request['message'];
                    final isAccepted = request['is_accepted'] == 1;

                    return ListTile(
                      title: Text(studentName),
                      subtitle: Text(requestMessage),
                      trailing: Icon(
                        isAccepted ? Icons.check_circle : Icons.pending,
                        color: isAccepted ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
    );
  }
}
