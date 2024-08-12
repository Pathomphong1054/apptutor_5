import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

class TutoringScheduleScreen extends StatefulWidget {
  final String tutorName;
  final String tutorImage;
  final String currentUser;
  final String currentUserImage;
  final String idUser;

  TutoringScheduleScreen({
    required this.tutorName,
    required this.tutorImage,
    required this.currentUser,
    required this.currentUserImage,
    required this.idUser,
  });

  @override
  _TutoringScheduleScreenState createState() => _TutoringScheduleScreenState();
}

class _TutoringScheduleScreenState extends State<TutoringScheduleScreen> {
  DateTime? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int selectedRate = 1;
  String selectedLevel = 'ประถม1-3';
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  double hourlyRate = 100.0;
  String tutorId = '';

  List<Map<String, dynamic>> rates = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _scheduledSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchScheduledSessions();
    _updateRates();
  }

  Future<void> _fetchScheduledSessions() async {
    final response = await http.get(
      Uri.parse(
          'http://10.5.50.82/tutoring_app/fetch_scheduled_sessions.php?tutor=${widget.tutorName}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _scheduledSessions =
              List<Map<String, dynamic>>.from(responseData['sessions']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load scheduled sessions: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to load scheduled sessions: ${response.body}')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final timePicked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? startTime ?? TimeOfDay(hour: 13, minute: 0)
          : endTime ?? TimeOfDay(hour: 15, minute: 0),
    );

    if (timePicked != null) {
      setState(() {
        if (isStartTime) {
          startTime = timePicked;
          startTimeController.text = startTime!.format(context);
        } else {
          endTime = timePicked;
          endTimeController.text = endTime!.format(context);
        }
        _updateRates();
      });
    }
  }

  bool _isDayScheduled(DateTime day) {
    for (var session in _scheduledSessions) {
      if (isSameDay(DateTime.parse(session['date']), day)) {
        return true;
      }
    }
    return false;
  }

  void _updateRates() {
    if (startTime != null && endTime != null) {
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;
      final durationHours = (durationMinutes / 60).ceil();
      double baseRate;
      switch (selectedLevel) {
        case 'ประถม1-3':
          baseRate = 100.0;
          break;
        case 'ประถม4-6':
          baseRate = 120.0;
          break;
        case 'มัธยม1-3':
          baseRate = 140.0;
          break;
        case 'มัธยม4-6':
          baseRate = 160.0;
          break;
        case 'ปวช':
          baseRate = 180.0;
          break;
        case 'ปวส':
          baseRate = 200.0;
          break;
        case 'ป.ตรี':
        default:
          baseRate = 180.0;
          break;
      }
      setState(() {
        rates = [
          {'people': 1, 'price': durationHours * baseRate},
          {'people': 2, 'price': durationHours * baseRate * 2},
          {'people': 3, 'price': durationHours * baseRate * 3},
        ];
      });
    }
  }

  Future<void> _scheduleSession() async {
    if (selectedDay != null && startTime != null && endTime != null) {
      final response = await http.post(
        Uri.parse('http://10.5.50.82/tutoring_app/schedule_session.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student': widget.currentUser,
          'tutor': widget.tutorName,
          'date': selectedDay.toString(),
          'startTime': startTime!.format(context),
          'endTime': endTime!.format(context),
          'rate': selectedRate,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Session scheduled successfully')),
            );

            await _sendMessageToTutor(responseData['session_id'].toString());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to schedule session: ${responseData['message']}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse response: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to schedule session: ${response.body}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a day and time')),
      );
    }
  }

  Future<void> _sendMessageToTutor(String sessionId) async {
    final price =
        rates.firstWhere((rate) => rate['people'] == selectedRate)['price'];
    final message =
        '''A new tutoring session has been scheduled with you on ${selectedDay.toString()}
    from ${startTime!.format(context)} to ${endTime!.format(context)}.
    The rate is $selectedRate people at ${price.toStringAsFixed(2)} THB.''';

    final payload = json.encode({
      'sender': widget.currentUser,
      'recipient': widget.tutorName,
      'message': message,
      'session_id': sessionId,
    });

    final response = await http.post(
      Uri.parse('http://10.5.50.82/tutoring_app/send_message.php'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message sent to tutor')),
          );
          // Navigate to ChatScreen with the tutor
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                currentUser: widget.currentUser,
                recipient: widget.tutorName,
                recipientImage: widget.tutorImage,
                currentUserImage: widget.currentUserImage,
                sessionId: sessionId,
                currentUserRole: 'student',
                idUser: widget.idUser,
                userId: widget.idUser,
                tutorId: tutorId, // Pass currentUserRole as 'student'
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to send message: ${responseData['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse response: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutoring Schedule'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutor: ${widget.tutorName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (_isDayScheduled(selectedDay)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'This day is already scheduled. Please choose another day.')),
                  );
                } else {
                  setState(() {
                    this.selectedDay = selectedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            SizedBox(height: 20),
            _buildTimePickerRow('Start Time:', startTimeController, true),
            SizedBox(height: 10),
            _buildTimePickerRow('End Time:', endTimeController, false),
            SizedBox(height: 10),
            _buildDropdown('Level of Education', selectedLevel, <String>[
              'ประถม1-3',
              'ประถม4-6',
              'มัธยม1-3',
              'มัธยม4-6',
              'ปวช',
              'ปวส',
              'ป.ตรี'
            ], (String? newValue) {
              setState(() {
                selectedLevel = newValue!;
                _updateRates();
              });
            }),
            SizedBox(height: 10),
            Text(
              'Price rate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: rates.length,
              itemBuilder: (context, index) {
                return RadioListTile<int>(
                  title: Text(
                      '${rates[index]['people']} คน | ราคา ${rates[index]['price'].toStringAsFixed(2)} บาท'),
                  value: rates[index]['people'],
                  groupValue: selectedRate,
                  onChanged: (int? value) {
                    setState(() {
                      selectedRate = value!;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _scheduleSession,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 28, 195, 198),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                  ),
                ),
                child: Text(
                  'Schedule',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(
      String label, TextEditingController controller, bool isStartTime) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () {
              _selectTime(context, isStartTime);
            },
            decoration: InputDecoration(
              hintText: 'Select Time',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String?)? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
