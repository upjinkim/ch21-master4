import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/event_model.dart';
import 'package:calendar_scheduler/screen/image_upload_page.dart';
import 'package:calendar_scheduler/screen/statsscreen.dart';
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _endDate;
  String? _recurrenceType;
  Map<DateTime, List<Event>> _events = {};

  int _currentIndex = 0; // BottomNavigationBar의 현재 인덱스
  final List<Widget> _pages = [
    CalendarScreenContent(),
    Center(child: Text('지도 화면')), // 지도 화면 대체 텍스트
    ImageUploadPage(), // 카메라 화면을 ImageUploadPage로 변경
    StatsScreen(), // 통계 화면 대체 텍스트
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '카메라'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
        ],
      ),
    );
  }
}

// Calendar 화면의 내용
class CalendarScreenContent extends StatefulWidget {
  @override
  _CalendarScreenContentState createState() => _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<CalendarScreenContent> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _endDate;
  String? _recurrenceType;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _events.map((key, value) => MapEntry(
        key.toIso8601String(), value.map((event) => event.toJson()).toList()));
    await prefs.setString('events', jsonEncode(data));
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('events');
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      setState(() {
        _events = decoded.map((key, value) => MapEntry(
            _normalizeDate(DateTime.parse(key)),
            (value as List).map((event) => Event.fromJson(event)).toList()));
      });
    }
  }

  void _deleteEvent(Event event) {
    setState(() {
      DateTime normalizedDate = _normalizeDate(event.dateTime);
      _events[normalizedDate]?.removeWhere((e) => e == event);
      if (_events[normalizedDate]?.isEmpty ?? false) {
        _events.remove(normalizedDate);
      }
    });
    _saveEvents();
  }

  void _showEventDialog({Event? event}) {
    final TextEditingController _eventController = TextEditingController(
        text: event != null ? event.title : '');
    TimeOfDay? _selectedTime =
    event != null ? TimeOfDay.fromDateTime(event.dateTime) : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(event == null ? '일정 추가' : '일정 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      labelText: '일정 제목',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _selectedTime?.format(context) ?? "시간X",
                      ),
                      TextButton(
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _selectedTime = pickedTime;
                            });
                          }
                        },
                        child: Text("시간 선택"),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_eventController.text.isEmpty ||
                        _selectedDay == null ||
                        _selectedTime == null) return;

                    final DateTime eventDateTime = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    setState(() {
                      DateTime normalizedDate = _normalizeDate(_selectedDay!);
                      if (_events[normalizedDate] != null) {
                        _events[normalizedDate]!.add(Event(
                            title: _eventController.text,
                            dateTime: eventDateTime));
                      } else {
                        _events[normalizedDate] = [
                          Event(
                              title: _eventController.text,
                              dateTime: eventDateTime)
                        ];
                      }
                    });

                    _saveEvents();
                    Navigator.of(context).pop();
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            DateTime normalizedDay = _normalizeDate(day);
            return _events[normalizedDay] ?? [];
          },
        ),
        ElevatedButton(
          onPressed: () => _showEventDialog(),
          child: const Text('일정 추가'),
        ),
        if (_selectedDay != null)
          Expanded(
            child: ListView(
              children: (_events[_normalizeDate(_selectedDay!)] ?? [])
                  .map((event) => ListTile(
                title: Text(event.title),
                subtitle: Text(
                    "${event.dateTime.hour}:${event.dateTime.minute}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteEvent(event);
                  },
                ),
                onTap: () => _showEventDialog(event: event),
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
