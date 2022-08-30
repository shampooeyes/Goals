import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygoals/models/event.dart';
import 'package:mygoals/models/habits.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Palette.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  HabitDetailsScreen(this.habit);

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late var _totalEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime enddate;

  @override
  void initState() {
    enddate = widget.habit.enddate;
    _totalEvents = widget.habit.events;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsfromDay(_selectedDay!));
    super.initState();
  }

  updateHabit(DateTime newEnddate) async {
    enddate = newEnddate;
    final habitListProvider = Provider.of<HabitList>(context, listen: false);

    habitListProvider.updateHabitEndDate(widget.habit.key, newEnddate);
    await habitListProvider.fetchAndSetHabits();
    setState(() {
      _totalEvents = habitListProvider
          .getHabits()
          .firstWhere((habit) => habit.key == widget.habit.key)
          .events;
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null)
      currentFocus.unfocus();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Palette.secondary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != widget.habit.enddate) {
      updateHabit(pickedDate);
    }
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
              contentTextStyle: Theme.of(context).textTheme.bodyText1,
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(
                      "Cancel",
                      style: Theme.of(context).textTheme.subtitle1,
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
                      style: Theme.of(context).textTheme.subtitle1,
                    ))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<HabitList>(context, listen: false)
            .updateHabit(widget.habit);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          color: Palette.background,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      widget.habit.title,
                      style: Theme.of(context).textTheme.headline1!.copyWith(
                          color: widget.habit.make
                              ? Palette.primary
                              : Palette.red),
                    ),
                  ),
                ),
                if (widget.habit.desc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(children: [
                        Text(
                          widget.habit.desc,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 16),
                        ),
                      ]),
                    ),
                  ),
                TableCalendar(
                  firstDay: widget.habit.creationDate,
                  lastDay: DateTime(2025),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
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
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
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
                    selectedDecoration: BoxDecoration(
                        color:
                            widget.habit.make ? Palette.primary : Palette.red,
                        shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(
                        border: Border.all(color: Palette.background),
                        shape: BoxShape.circle),
                    todayTextStyle: TextStyle(
                        color:
                            widget.habit.make ? Palette.primary : Palette.red,
                        fontWeight: FontWeight.w800),
                    defaultTextStyle: TextStyle(color: Palette.text),
                    weekendTextStyle: TextStyle(color: Palette.text),
                    markersAutoAligned: false,
                    markersOffset: PositionedOffset(bottom: 7),
                    markerDecoration: BoxDecoration(
                        color:
                            widget.habit.make ? Palette.primary : Palette.red,
                        shape: BoxShape.circle),
                  ),
                  eventLoader: _getEventsfromDay,
                  calendarBuilders: CalendarBuilders(
                    singleMarkerBuilder: (context, date, event) {
                      Color cor = Palette.darkred;
                      if (event.runtimeType == Event) {
                        DateTime today = DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day);
                        if ((event as Event).done) {
                          // if not done and before today mark with red
                          cor =
                              widget.habit.make ? Palette.primary : Palette.red;
                        } else if (event.date.isBefore(today)) {
                          cor = isSameDay(_selectedDay, event.date)
                              ? Palette.red.withOpacity(0)
                              : Palette.red;
                        } else {
                          cor = widget.habit.make
                              ? Palette.primary.withOpacity(0.4)
                              : Palette.background.withOpacity(0);
                        }
                      }
                      return Container(
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: cor),
                        width: 7.0,
                        height: 7.0,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isNotEmpty) {
                        final event = value[0];
                        return Container(
                            child: (event.date.isAfter(DateTime.now()))
                                ? Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Palette.milestone,
                                      border: Border.all(
                                          width: 1.5, color: Color(0xff989898)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      widget.habit.make ? "Done" : "Relapse",
                                      style: TextStyle(
                                          color: Color(0xff989898),
                                          fontSize: 16),
                                    ),
                                  )
                                : GestureDetector(
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
                                        color: event.done
                                            ? widget.habit.make
                                                ? Palette.primary
                                                : Palette.red
                                            : Palette.background,
                                        border: Border.all(
                                            width: 1.5,
                                            color: widget.habit.make
                                                ? Palette.primary
                                                : Palette.red),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        widget.habit.make ? "Done" : "Relapse",
                                        style: TextStyle(
                                            color: event.done
                                                ? Palette.white
                                                : widget.habit.make
                                                    ? Palette.primary
                                                    : Palette.red,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ));
                      }
                      return Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Palette.milestone,
                          border:
                              Border.all(width: 1.5, color: Color(0xff989898)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.habit.make ? "Done" : "Relapse",
                          style:
                              TextStyle(color: Color(0xff989898), fontSize: 16),
                        ),
                      );
                    }),
                SizedBox(
                  height: 25,
                ),
                Column(
                  children: [
                    Text(
                      "End Date",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context, widget.habit.enddate);
                      },
                      child: Container(
                        width: 115,
                        height: 27,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: widget.habit.make
                                ? Palette.primary
                                : Palette.red),
                        child: Row(
                          children: [
                            Text(
                              DateFormat("dd/MM/yyyy").format(enddate),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Spacer(),
                            GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Palette.white,
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () => confirmDelete(widget.habit.title),
                  child: Container(
                    alignment: Alignment.center,
                    width: 170,
                    margin: const EdgeInsets.only(bottom: 30, top: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Palette.red, width: 1.5),
                      color: Palette.background,
                    ),
                    child: Text(
                      "Delete Habit",
                      style: TextStyle(color: Palette.red, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
