import 'package:flutter/material.dart';
import 'package:mygoals/models/habits.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Palette.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  HabitDetailsScreen(this.habit);

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Widget> _selectedEvents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title,
            style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete,
              size: 24,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: widget.habit.creationDate,
            lastDay: DateTime(2023),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Week',
              CalendarFormat.week: 'Month',
            },
            headerStyle: HeaderStyle(
              formatButtonTextStyle: TextStyle(color: Colors.black),
              titleTextStyle: TextStyle(
                  color: Palette.text,
                  fontSize: 18,
                  fontWeight: FontWeight.normal),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Palette.text),
              weekendStyle: TextStyle(color: Palette.text),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration:
                  BoxDecoration(color: Palette.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                  border: Border.all(color: Palette.primary),
                  shape: BoxShape.circle),
              todayTextStyle: TextStyle(color: Palette.text),
              defaultTextStyle: TextStyle(color: Palette.text),
              weekendTextStyle: TextStyle(color: Palette.text),
            ),
          ),
        ],
      ),
    );
  }
}
