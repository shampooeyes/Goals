import 'package:flutter/material.dart';
import 'package:mygoals/models/event.dart';
import 'package:mygoals/models/habits.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Palette.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  HabitDetailsScreen(this.habit);

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final _totalEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    _totalEvents = widget.habit.events;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsfromDay(_selectedDay!));
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return _totalEvents[DateTime(date.year, date.month, date.day)] ?? [];
  }

  void confirmDelete(String title) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Are you sure?"),
              content: Text("Delete \"$title\""),
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(
                      "Cancel",
                      style: const TextStyle(
                        fontFamily: "OpenSans",
                        fontSize: 17,
                        color: Color(0xff303030),
                      ),
                    )),
                TextButton(
                    onPressed: () {
                      Provider.of<HabitList>(context, listen: false)
                          .removeItem(widget.habit.key);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "OK",
                      style: const TextStyle(
                        fontFamily: "OpenSans",
                        fontSize: 17,
                        color: Color(0xff303030),
                      ),
                    ))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title,
            style: Theme.of(context).appBarTheme.titleTextStyle),
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
              print(selectedDay);
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _getEventsfromDay(selectedDay);
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
                  border: Border.all(color: Palette.background),
                  shape: BoxShape.circle),
              todayTextStyle: TextStyle(
                  color: Palette.primary, fontWeight: FontWeight.w800),
              defaultTextStyle: TextStyle(color: Palette.text),
              weekendTextStyle: TextStyle(color: Palette.text),
              markersAutoAligned: false,
              markersOffset: PositionedOffset(bottom: 7),
              markerDecoration:
                  BoxDecoration(color: Palette.primary, shape: BoxShape.circle),
            ),
            eventLoader: _getEventsfromDay,
          ),
          SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return Container(
                    // height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (ctx, index) {
                        final event = value[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              event.done = !event.done;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  event.done ? Palette.primary : Palette.white,
                              border: Border.all(color: Palette.primary),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                  color: event.done
                                      ? Palette.white
                                      : Palette.primary,
                                  fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => confirmDelete(widget.habit.title),
            child: Container(
              alignment: Alignment.center,
              width: 170,
              margin: const EdgeInsets.symmetric(vertical: 30),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Palette.red, width: 1.5),
              ),
              child: Text(
                "Delete Habit",
                style: TextStyle(color: Palette.red, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
