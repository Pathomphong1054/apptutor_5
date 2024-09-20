import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditScheduleScreen extends StatefulWidget {
  final String tutorName;
  final String tutorImage;
  final String currentUser;
  final String currentUserImage;
  final String idUser;
  final String recipientImage;
  final String profileImageUrl;

  EditScheduleScreen({
    required this.tutorName,
    required this.tutorImage,
    required this.currentUser,
    required this.currentUserImage,
    required this.idUser,
    required this.recipientImage,
    required this.profileImageUrl,
  });

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDays = {}; // เก็บหลายวันที่ถูกเลือก
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  double hourlyRate = 100.0;

  Set<DateTime> scheduledDays = {}; // สำหรับตารางที่ติวเตอร์แก้ไข
  Set<DateTime> studentSessions = {}; // สำหรับเวลาที่นักเรียนจอง
  Set<DateTime> teachingSpecificTime = {}; // สำหรับเวลาที่ติวเฉพาะเวลา
  Set<DateTime> notTeachingDays = {}; // สำหรับเวลาที่ไม่รับติว
  Map<DateTime, Map<String, String>> specificTimeDetails =
      {}; // เก็บรายละเอียดเวลาของวันสีฟ้า

  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _hourlyRateController = TextEditingController();

  bool _isNotTeachingToday = false;

  @override
  void initState() {
    super.initState();
    _hourlyRateController.text = hourlyRate.toStringAsFixed(2);
    _fetchScheduledSessions();
    _fetchStudentSessions();
  }

  Future<void> _fetchScheduledSessions() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.5.50.82/tutoring_app/get_tutor_schedule.php?tutor=${widget.tutorName}'),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            for (var session in responseData['sessions']) {
              DateTime date = DateTime.parse(session['date']);
              if (session['is_not_teaching'] == "ไม่รับติว") {
                notTeachingDays.add(date);
              } else if (session['start_time'] != null &&
                  session['end_time'] != null) {
                teachingSpecificTime.add(date);
                specificTimeDetails[date] = {
                  'start': session['start_time'],
                  'end': session['end_time']
                };
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching schedule: $e');
    }
  }

  Future<void> _fetchStudentSessions() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.5.50.82/tutoring_app/get_student_sessions.php?tutor=${widget.tutorName}'),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            for (var session in responseData['sessions']) {
              studentSessions.add(DateTime.parse(session['date']));
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching student sessions: $e')),
      );
    }
  }

  // Method to show a dialog message based on the selected day
  void _showDayInfoDialog(DateTime selectedDay) {
    DateTime onlyDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    String message = "";
    if (studentSessions
        .any((d) => DateTime(d.year, d.month, d.day) == onlyDate)) {
      message = 'มีนักเรียนจองแล้ว';
    } else if (notTeachingDays
        .any((d) => DateTime(d.year, d.month, d.day) == onlyDate)) {
      message = 'วันนี้ไม่รับติว';
    } else if (teachingSpecificTime
        .any((d) => DateTime(d.year, d.month, d.day) == onlyDate)) {
      var startTime = specificTimeDetails[onlyDate]?['start'];
      var endTime = specificTimeDetails[onlyDate]?['end'];

      if (startTime != null && endTime != null) {
        message = 'รับติวเฉพาะเวลา: $startTime - $endTime';
      } else {
        message = 'ไม่พบข้อมูลเวลา';
      }
    } else {
      message = 'ไม่มีข้อมูลสำหรับวันดังกล่าว';
    }

    // Show dialog with the message
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('รายละเอียดวัน'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    if (_isNotTeachingToday) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
          _startTimeController.text = startTime!.format(context);
        } else {
          endTime = picked;
          _endTimeController.text = endTime!.format(context);
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_selectedDays.isNotEmpty &&
        (_isNotTeachingToday || (startTime != null && endTime != null))) {
      try {
        for (DateTime day in _selectedDays) {
          final response = await http.post(
            Uri.parse('http://10.5.50.82/tutoring_app/save_schedule.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'tutor': widget.tutorName,
              'date': day.toString(),
              'startTime':
                  _isNotTeachingToday ? null : startTime!.format(context),
              'endTime': _isNotTeachingToday ? null : endTime!.format(context),
              'hourlyRate': _isNotTeachingToday ? '0' : hourlyRate.toString(),
              'isNotTeaching':
                  _isNotTeachingToday.toString(), // ส่งสถานะ "ไม่รับติว"
            }),
          );

          if (response.statusCode != 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save schedule for $day')),
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedules saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select days and complete all required information.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Schedule'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Days:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2021),
              lastDay: DateTime(2025),
              selectedDayPredicate: (day) => _selectedDays.contains(day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (_selectedDays.contains(selectedDay)) {
                    _selectedDays.remove(selectedDay);
                  } else {
                    _selectedDays.add(selectedDay);
                  }
                  _focusedDay = focusedDay;
                  _showDayInfoDialog(
                      selectedDay); // Show the dialog when a day is selected
                });
              },
              eventLoader: (day) {
                DateTime onlyDate = DateTime(day.year, day.month, day.day);

                if (studentSessions
                    .any((d) => DateTime(d.year, d.month, d.day) == onlyDate)) {
                  return ['StudentSession']; // Red for student bookings
                } else if (notTeachingDays
                    .any((d) => DateTime(d.year, d.month, d.day) == onlyDate)) {
                  return ['NotTeaching']; // Black for not teaching
                } else if (teachingSpecificTime
                    .any((d) => DateTime(d.year, d.month, d.day) == onlyDate)) {
                  return [
                    'TeachingSpecificTime'
                  ]; // Blue for specific teaching time
                }
                return [];
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
                markerDecoration: BoxDecoration(
                  color: Colors.red, // default สีแดง
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    if (events.contains('StudentSession')) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.red, // Red for student booking
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    } else if (events.contains('NotTeaching')) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.black, // Black for not teaching
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    } else if (events.contains('TeachingSpecificTime')) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color:
                                Colors.blue, // Blue for teaching specific time
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                  }
                  return null; // Return null if no events
                },
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            SizedBox(height: 20),

            // Checkbox สำหรับติ๊กว่า "วันนี้ไม่รับติว"
            Row(
              children: [
                Checkbox(
                  value: _isNotTeachingToday,
                  onChanged: (value) {
                    setState(() {
                      _isNotTeachingToday = value!;
                      // ถ้าเลือก "ไม่รับติว" ล้างค่าเวลาเริ่มและสิ้นสุด
                      if (_isNotTeachingToday) {
                        _startTimeController.clear();
                        _endTimeController.clear();
                      }
                    });
                  },
                ),
                Text('วันนี้ไม่รับติว',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),

            // แสดงฟอร์มเลือกเวลาเฉพาะเมื่อไม่ได้ติ๊ก "ไม่รับติว"
            if (!_isNotTeachingToday) ...[
              Text('Start Time:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _startTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select start time',
                ),
                onTap: () => _selectTime(context, true),
              ),
              SizedBox(height: 20),
              Text('End Time:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _endTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select end time',
                ),
                onTap: () => _selectTime(context, false),
              ),
              SizedBox(height: 20),
              Text('Hourly Rate (THB/hour):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _hourlyRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter hourly rate',
                ),
                onChanged: (value) {
                  hourlyRate = double.tryParse(value) ?? 100.0;
                },
              ),
            ],

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveSchedule,
                child: Text('Save Schedule'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: const Color.fromARGB(255, 28, 195, 198),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
