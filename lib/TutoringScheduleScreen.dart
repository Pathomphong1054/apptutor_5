import 'package:apptutor_2/BookedSessionsScreen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'package:apptutor_2/EditScheduleScreen.dart';

class TutoringScheduleScreen extends StatefulWidget {
  final String tutorName;
  final String tutorImage;
  final String currentUser;
  final String currentUserImage;
  final String idUser;
  final String recipientImage;
  final String profileImageUrl;
  final String currentUserRole;
  final String userRole;

  TutoringScheduleScreen({
    required this.tutorName,
    required this.tutorImage,
    required this.currentUser,
    required this.currentUserImage,
    required this.idUser,
    required this.recipientImage,
    required this.profileImageUrl,
    required this.currentUserRole,
    required this.userRole,
  });

  @override
  _TutoringScheduleScreenState createState() => _TutoringScheduleScreenState();
}

class _TutoringScheduleScreenState extends State<TutoringScheduleScreen> {
  Set<DateTime> studentSessions = {};
  Set<DateTime> notTeachingDays = {}; // Days with black events
  Set<DateTime> teachingSpecificTime = {};
  Map<DateTime, Map<String, String>> specificTimeDetails = {};

  List<DateTime> selectedDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int selectedRate = 1;
  String selectedLevel = 'ประถม1-3';
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  double hourlyRate = 100.0;
  String tutorId = '';
  List<Map<String, dynamic>> rates = [];
  Set<DateTime> scheduledDays = {};
  List<Map<String, dynamic>> scheduledTimesForDay = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _scheduledSessions = [];

  bool isNotTeachingDay = false; // Track if the selected day is a black day

  @override
  void initState() {
    super.initState();
    _fetchTutorSchedule(); // ดึงข้อมูลจากตาราง tutor_schedule
    _fetchStudentSessions(); // ดึงข้อมูลจากตาราง tutoring_sessions
    _updateRates();
  }

  // ฟังก์ชันดึงข้อมูลจากตาราง tutor_schedule สำหรับสีฟ้า
  Future<void> _fetchTutorSchedule() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.243.173/tutoring_app/get_tutor_schedule.php?tutor=${widget.tutorName}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          for (var session in responseData['sessions']) {
            DateTime date = DateTime.parse(session['date']);
            if (session['is_not_teaching'] == "ไม่รับติว") {
              notTeachingDays.add(date); // Mark as not available (black)
            } else if (session['start_time'] != null &&
                session['end_time'] != null) {
              teachingSpecificTime.add(date); // สีฟ้า
              specificTimeDetails[date] = {
                'start': session['start_time'],
                'end': session['end_time']
              };
            }
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล้มเหลวในการโหลดตารางติวเตอร์')),
      );
    }
  }

  // ฟังก์ชันดึงข้อมูลจากตาราง tutoring_sessions สำหรับสีแดง
  Future<void> _fetchStudentSessions() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.243.173/tutoring_app/get_student_sessions.php?tutor=${widget.tutorName}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          for (var session in responseData['sessions']) {
            studentSessions.add(DateTime.parse(session['date'])); // สีแดง
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล้มเหลวในการโหลดตารางของนักเรียน')),
      );
    }
  }

  Future<void> _fetchScheduledTimesForDay(DateTime selectedDay) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.243.173/tutoring_app/fetch_scheduled_times.php?date=$selectedDay&tutor=${widget.tutorName}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (mounted) {
        setState(() {
          scheduledTimesForDay = responseData['times'] != null
              ? List<Map<String, dynamic>>.from(responseData['times'])
              : [];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('ล้มเหลวในการโหลดเวลาที่นัดหมาย: ${response.body}')),
      );
    }
  }

  void _showDayInfo(DateTime selectedDay) {
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
      return; // ไม่มีป๊อปอัพแสดง
    }

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

  Future<void> _selectTimeForTutorSpecific(DateTime selectedDay) async {
    DateTime onlyDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    // ตรวจสอบว่าวันที่เลือกมีเวลาเฉพาะที่ติวเตอร์กำหนดไว้หรือไม่
    if (specificTimeDetails.containsKey(onlyDate)) {
      var startTimeStr = specificTimeDetails[onlyDate]?['start'];
      var endTimeStr = specificTimeDetails[onlyDate]?['end'];

      // ถ้าเวลาต้นและเวลาสิ้นสุดมีค่า ให้ดำเนินการเลือกเวลา
      if (startTimeStr != null && endTimeStr != null) {
        // แปลงเวลาจาก String เป็น TimeOfDay
        TimeOfDay startTime = TimeOfDay(
          hour: int.parse(startTimeStr.split(":")[0]),
          minute: int.parse(startTimeStr.split(":")[1]),
        );
        TimeOfDay endTime = TimeOfDay(
          hour: int.parse(endTimeStr.split(":")[0]),
          minute: int.parse(endTimeStr.split(":")[1]),
        );

        // เปิด TimePicker โดยตั้งค่าเริ่มต้นที่เวลาเริ่มต้นของติวเตอร์
        final timePicked = await showTimePicker(
          context: context,
          initialTime: startTime,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        // ตรวจสอบว่าเวลาที่เลือกอยู่ในช่วงเวลาที่ติวเตอร์กำหนดหรือไม่
        if (timePicked != null) {
          if (_isTimeWithinRange(timePicked, startTime, endTime)) {
            // ถ้าเวลาอยู่ในช่วงที่ถูกต้อง อัปเดตเวลาเริ่มต้น
            setState(() {
              startTimeController.text = timePicked.format(context);
            });
          } else {
            // แสดงข้อผิดพลาดถ้าเลือกเวลาอื่นที่อยู่นอกช่วง
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'กรุณาเลือกเวลาในช่วง ${startTime.format(context)} - ${endTime.format(context)}')),
            );
          }
        }
      }
    }
  }

// ฟังก์ชันตรวจสอบว่าเวลาที่เลือกอยู่ในช่วงเวลาที่กำหนดหรือไม่
  bool _isTimeWithinRange(
      TimeOfDay pickedTime, TimeOfDay startTime, TimeOfDay endTime) {
    final pickedMinutes = pickedTime.hour * 60 + pickedTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // ตรวจสอบว่าช่วงเวลาที่เลือกอยู่ในช่วงเวลาที่กำหนดหรือไม่
    return pickedMinutes >= startMinutes && pickedMinutes <= endMinutes;
  }

  void _showSelectionLimitMessage(DateTime day) {
    DateTime onlyDate = DateTime(day.year, day.month, day.day);
    if (teachingSpecificTime.contains(onlyDate)) {
      var start = specificTimeDetails[onlyDate]?['start'];
      var end = specificTimeDetails[onlyDate]?['end'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เลือกได้เฉพาะเวลา: $start ถึง $end'),
        ),
      );
    } else if (notTeachingDays.contains(onlyDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('วันนี้ไม่สามารถนัดหมายได้'),
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    DateTime selectedDay =
        selectedDays.isNotEmpty ? selectedDays.first : _focusedDay;

    // ตรวจสอบว่าถ้าวันที่เลือกเป็นสีฟ้า ให้เลือกเวลาเฉพาะที่ติวเตอร์กำหนด
    if (teachingSpecificTime.contains(selectedDay)) {
      await _selectTimeForTutorSpecific(selectedDay);
    } else {
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
          baseRate = 220.0;
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
    if (selectedDays.isNotEmpty && startTime != null && endTime != null) {
      // Prevent scheduling if it's a not-teaching (black) day
      if (isNotTeachingDay) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('วันนี้ไม่สามารถทำการนัดหมายได้')),
        );
        return;
      }

      List<String> sessionIds = [];

      for (DateTime selectedDay in selectedDays) {
        if (_isTimeOverlapping(startTime!, endTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เวลาที่เลือกทับซ้อนกับเวลาที่ถูกจองแล้ว')),
          );
          return;
        }

        // Calculate the correct amount based on your rates
        final startMinutes = startTime!.hour * 60 + startTime!.minute;
        final endMinutes = endTime!.hour * 60 + endTime!.minute;
        final durationMinutes = endMinutes - startMinutes;
        final durationHours = (durationMinutes / 60).ceil();
        final amount =
            rates.firstWhere((rate) => rate['people'] == selectedRate)['price'];

        final response = await http.post(
          Uri.parse('http://192.168.243.173/tutoring_app/schedule_session.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'student': widget.currentUser,
            'tutor': widget.tutorName,
            'date': selectedDay.toString(),
            'startTime': startTime!.format(context),
            'endTime': endTime!.format(context),
            'rate': selectedRate,
            'amount': amount.toString(),
          }),
        );

        if (response.statusCode == 200) {
          try {
            final responseData = json.decode(response.body);
            if (responseData['status'] == 'success') {
              sessionIds.add(responseData['session_id'].toString());

              // Update the studentSessions to show it in red
              setState(() {
                studentSessions.add(selectedDay);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${responseData['message']}')),
              );
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid response from the server')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error: ${response.statusCode} - ${response.reasonPhrase}')),
          );
        }
      }

      if (sessionIds.isNotEmpty) {
        // ส่งข้อความไปหาติวเตอร์เมื่อมีการนัดหมายสำเร็จ
        _sendMessageToTutor(sessionIds);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ทำการนัดเรียนสำเร็จ')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกวันและเวลา')),
      );
    }
  }

  bool _isTimeOverlapping(TimeOfDay start, TimeOfDay end) {
    for (var time in scheduledTimesForDay) {
      TimeOfDay bookedStart = TimeOfDay(
        hour: int.parse(time['start_time'].split(":")[0]),
        minute: int.parse(time['start_time'].split(":")[1]),
      );
      TimeOfDay bookedEnd = TimeOfDay(
        hour: int.parse(time['end_time'].split(":")[0]),
        minute: int.parse(time['end_time'].split(":")[1]),
      );

      if (start.hour < bookedEnd.hour ||
          (start.hour == bookedEnd.hour && start.minute < bookedEnd.minute)) {
        if (end.hour > bookedStart.hour ||
            (end.hour == bookedStart.hour && end.minute > bookedStart.minute)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _sendMessageToTutor(List<String> sessionIds) async {
    final price =
        rates.firstWhere((rate) => rate['people'] == selectedRate)['price'];

    final message = '''
ได้มีการนัดเรียนกับคุณในวันที่ ${selectedDays.map((day) => '${day.day}/${day.month}/${day.year}').join(', ')}, 
ตั้งแต่เวลา ${startTime!.format(context)} ถึง ${endTime!.format(context)}. 
ราคาสำหรับ $selectedRate คน คือ ${price.toStringAsFixed(2)} บาท.''';

    final payload = json.encode({
      'sender': widget.currentUser,
      'recipient': widget.tutorName,
      'message': message,
      'session_id': sessionIds.join(', '),
    });

    final response = await http.post(
      Uri.parse('http://192.168.243.173/tutoring_app/send_message.php'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อความไปหาติวเตอร์แล้ว')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUser: widget.currentUser,
              recipient: widget.tutorName,
              // recipientImage: widget.tutorImage,
              currentUserImage: widget.currentUserImage,
              sessionId: sessionIds.first,
              currentUserRole: 'student',
              idUser: widget.idUser,
              userId: widget.idUser,
              tutorId: tutorId,
              profileImageUrl: widget.profileImageUrl,
              recipientImage: widget.recipientImage,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('ล้มเหลวในการส่งข้อความ: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล้มเหลวในการส่งข้อความ: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตารางเรียนกับติวเตอร์'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              // Navigate to the booked sessions page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookedSessionsScreen(
                    tutorName: widget.tutorName,
                    currentUser: widget.currentUser,
                    currentUserImage: widget.currentUserImage,
                    idUser: widget.idUser,
                    recipientImage: widget.recipientImage,
                    profileImageUrl: widget.profileImageUrl,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          'ติวเตอร์: ${widget.tutorName}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    TableCalendar(
                      calendarFormat: _calendarFormat,
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2024, 12, 31),
                      selectedDayPredicate: (day) => selectedDays.contains(day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (selectedDays.contains(selectedDay)) {
                            selectedDays.remove(selectedDay);
                          } else {
                            selectedDays.add(selectedDay);
                            _fetchScheduledTimesForDay(selectedDay);
                          }
                          _focusedDay = focusedDay;

                          // Check if it's a not-teaching day (black)
                          isNotTeachingDay = notTeachingDays.contains(DateTime(
                              selectedDay.year,
                              selectedDay.month,
                              selectedDay.day));

                          _showDayInfo(
                              selectedDay); // แสดงรายละเอียดเมื่อเลือกวัน
                        });
                      },
                      eventLoader: (day) {
                        DateTime onlyDate =
                            DateTime(day.year, day.month, day.day);

                        // ตรวจสอบว่าวันนั้นมีนักเรียนจองในตาราง tutoring_sessions หรือไม่ -> สีแดง
                        if (studentSessions.any((d) =>
                            DateTime(d.year, d.month, d.day) == onlyDate)) {
                          return [
                            'StudentSession'
                          ]; // สีแดงสำหรับการจองของนักเรียน
                        }
                        // ตรวจสอบว่าติวเตอร์กำหนดเวลาในตาราง tutor_schedule หรือไม่ -> สีฟ้า
                        else if (teachingSpecificTime.any((d) =>
                            DateTime(d.year, d.month, d.day) == onlyDate)) {
                          return [
                            'TeachingSpecificTime'
                          ]; // สีฟ้าสำหรับเวลาที่ติวเตอร์กำหนด
                        }
                        // วันไม่รับสอน -> สีดำ
                        else if (notTeachingDays.any((d) =>
                            DateTime(d.year, d.month, d.day) == onlyDate)) {
                          return ['NotTeaching']; // สีดำสำหรับวันไม่รับติว
                        }
                        return [];
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isNotEmpty) {
                            // นักเรียนจองแล้ว -> สีแดง
                            if (events.contains('StudentSession')) {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .red, // สีแดงสำหรับการจองของนักเรียน
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            // ติวเตอร์กำหนดเวลา -> สีฟ้า
                            else if (events.contains('TeachingSpecificTime')) {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blue, // สีฟ้าสำหรับเวลาที่ติวเตอร์กำหนด
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            // ไม่รับติว -> สีดำ
                            else if (events.contains('NotTeaching')) {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: Colors.black, // สีดำสำหรับไม่รับติว
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                          }
                          return null;
                        },
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            scheduledTimesForDay.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: scheduledTimesForDay.length,
                    itemBuilder: (context, index) {
                      final timeSlot = scheduledTimesForDay[index];
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                              'เวลาที่ถูกจอง: ${timeSlot['start_time']} - ${timeSlot['end_time']}'),
                        ),
                      );
                    },
                  )
                : Text('ยังไม่มีการจองเวลาในวันนี้'),
            SizedBox(height: 20),
            _buildTimePickerRow('เวลาเริ่มต้น:', startTimeController, true),
            SizedBox(height: 10),
            _buildTimePickerRow('เวลาสิ้นสุด:', endTimeController, false),
            SizedBox(height: 10),
            _buildDropdown('ระดับการศึกษา', selectedLevel, <String>[
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
              'อัตราค่าบริการ',
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
                onPressed: isNotTeachingDay
                    ? null
                    : _scheduleSession, // Disable button if it's a black day
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 28, 195, 198),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                  ),
                ),
                child: Text(
                  'ทำการนัดหมาย',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.currentUserRole == 'Tutor'
          ? FloatingActionButton(
              onPressed: () {
                _navigateToEditSchedule();
              },
              child: Icon(Icons.edit),
              backgroundColor: const Color.fromARGB(255, 28, 195, 198),
            )
          : null,
    );
  }

  void _navigateToEditSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScheduleScreen(
          tutorName: widget.tutorName,
          tutorImage: widget.tutorImage,
          currentUser: widget.currentUser,
          currentUserImage: widget.currentUserImage,
          idUser: widget.idUser,
          recipientImage: widget.recipientImage,
          profileImageUrl: widget.profileImageUrl,
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
              hintText: 'เลือกเวลา',
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
