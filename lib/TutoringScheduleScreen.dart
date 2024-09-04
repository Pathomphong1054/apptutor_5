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
  List<DateTime> selectedDays = []; // เก็บวันที่ที่เลือก
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int selectedRate = 1;
  String selectedLevel = 'ประถม1-3';
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  double hourlyRate = 100.0;
  String tutorId = '';

  List<Map<String, dynamic>> rates = [];
  Set<DateTime> scheduledDays = {}; // เซ็ตที่เก็บวันที่มีการนัดเรียนแล้ว

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
          // เก็บวันที่ที่มีการนัดหมายแล้วใน scheduledDays
          scheduledDays = _scheduledSessions
              .map((session) => DateTime.parse(session['date']))
              .toSet();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ล้มเหลวในการโหลดตารางเรียน: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ล้มเหลวในการโหลดตารางเรียน: ${response.body}')),
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
      // ใช้ List เพื่อเก็บ session_id สำหรับแต่ละวัน
      List<String> sessionIds = [];

      for (DateTime selectedDay in selectedDays) {
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
              // เก็บ session_id ใน list
              sessionIds.add(responseData['session_id'].toString());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('ล้มเหลวในการนัดเรียน: ${responseData['message']}'),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ล้มเหลวในการอ่านข้อมูล: $e')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ล้มเหลวในการนัดเรียน: ${response.body}')),
          );
        }
      }

      // ส่งข้อความถึงติวเตอร์หลังจากสร้าง session สำหรับทุกวันที่เลือกเสร็จสิ้นแล้ว
      if (sessionIds.isNotEmpty) {
        await _sendMessageToTutor(sessionIds);
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

  Future<void> _sendMessageToTutor(List<String> sessionIds) async {
    final price =
        rates.firstWhere((rate) => rate['people'] == selectedRate)['price'];

    // สร้างข้อความเพื่อแสดงวันที่ที่เลือกทั้งหมดในรูปแบบภาษาไทย
    final message = '''
ได้มีการนัดเรียนกับคุณในวันที่ ${selectedDays.map((day) => '${day.day}/${day.month}/${day.year}').join(', ')}
ตั้งแต่เวลา ${startTime!.format(context)} ถึง ${endTime!.format(context)}.
ราคาสำหรับ $selectedRate คน คือ ${price.toStringAsFixed(2)} บาท.''';

    final payload = json.encode({
      'sender': widget.currentUser,
      'recipient': widget.tutorName,
      'message': message,
      'session_id':
          sessionIds.join(', '), // รวม session_id ทั้งหมดในข้อความเดียว
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
            SnackBar(content: Text('ส่งข้อความไปหาติวเตอร์แล้ว')),
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
                sessionId: sessionIds.first, // ส่ง sessionId แรกไปใน Chat
                currentUserRole: 'student',
                idUser: widget.idUser,
                userId: widget.idUser,
                tutorId: tutorId,
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ล้มเหลวในการอ่านข้อมูล: $e')),
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ติวเตอร์: ${widget.tutorName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
              selectedDayPredicate: (day) {
                return selectedDays.contains(day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (selectedDays.contains(selectedDay)) {
                    selectedDays.remove(selectedDay); // ลบวันที่เลือก
                  } else {
                    if (!_isDayScheduled(selectedDay)) {
                      selectedDays.add(selectedDay); // เพิ่มวันที่ที่เลือก
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('วันนี้มีการนัดเรียนแล้ว')),
                      );
                    }
                  }
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              // ใช้ eventLoader เพื่อโหลดเครื่องหมาย
              eventLoader: (day) {
                if (scheduledDays
                    .any((scheduledDate) => isSameDay(scheduledDate, day))) {
                  return ['Scheduled']; // คืนค่าวันที่มีการนัดหมาย
                }
                return []; // ไม่มีเหตุการณ์
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
                markersMaxCount: 1, // แสดงเครื่องหมายสำหรับวันที่มีการนัดหมาย
                markerDecoration: BoxDecoration(
                  color: Colors.red, // สีเครื่องหมายเป็นสีแดง
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
                  'ทำการนัดหมาย',
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
