import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mygoals/database/db_helper.dart';
import 'package:mygoals/models/event.dart';

class HabitList extends ChangeNotifier {
  List<Habit> _habits = [];

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    DatabaseHelper.insertHabit("Habits", {
      "id": habit.key,
      "title": habit.title,
      "make": habit.make ? 1 : 0,
      "repeat": habit.repeat,
      "reminder": habit.reminder ? 1 : 0,
      "enddate": habit.enddate.toIso8601String(),
      "creationDate": habit.creationDate.toIso8601String(),
    });
    DatabaseHelper.insertHabitsEvents({
      "id": habit.key,
      "dates": " ",
    });
  }

  void updateHabit(Habit habit) {
    String data = "";
    int bestStrk = 0;
    int counter = 0;
    List<DateTime> dates = [];
    habit.events.forEach((date, list) {
      dates.add(date);
      if (list[0].done) {
        counter++;
        data += date.toIso8601String() + " ";
      } else {
        bestStrk = max(counter, bestStrk);
        counter = 0;
      }
    });

    habit.bestStreak = (bestStrk * habit.repeat) - 1;
    dates = dates.reversed.toList();
    counter = -1;
    int daysAtEnd = 0;
    for (int i = 0; i < dates.length; i++) {
      DateTime date = dates[i];

      if (i == 0 && habit.events[date]![0].done) {
        DateTime tod = DateTime.now();
        daysAtEnd =
            DateTime(tod.year, tod.month, tod.day).difference(date).inDays;
      }

      if (!habit.events[date]![0].done) {
        break;
      } else {
        counter++;
      }
    }
    habit.currentStreak = (counter * habit.repeat) + daysAtEnd;
    habit.bestStreak = max(habit.bestStreak, habit.currentStreak);
    notifyListeners();
    DatabaseHelper.updateHabitsEvents(
        habit.key, {"id": habit.key, "dates": data});
  }

  List<Habit> getHabits() {
    return [..._habits];
  }

  void removeItem(String key) {
    _habits.removeWhere((habit) => habit.key == key);
    DatabaseHelper.deleteHabit(key);
    notifyListeners();
  }

  void setStreaks() {
    // calculate last start date till now
    DateTime now = DateTime.now();

    _habits.forEach((habit) {
      int difference = now.difference(habit.creationDate).inDays;
      habit.currentStreak = difference;
      if (difference > habit.bestStreak) habit.bestStreak = difference;
    });

    notifyListeners();
  }

  Future<void> fetchAndSetHabits() async {
    final List<Map<String, dynamic>>
        habitEvents = // [{id: "id", dates: "date1 date2"}, {...}]
        await DatabaseHelper.getHabitsEventsData();

    final List<Map<String, dynamic>> habits =
        await DatabaseHelper.getHabitsData();
    _habits = habits.map((habit) {
      final event = habitEvents.firstWhere((element) =>
          element["id"] == habit["id"]); // {id: "id", dates: "date1 date2"}

      var events = {};
      String doneDates = event["dates"] as String;
      List<DateTime> doneDatesList = [];
      doneDates.split(" ").forEach((string) {
        doneDatesList.add(DateTime.parse(string));
      });

      DateTime date = habit["creationDate"];
      while (date.isBefore(habit["enddate"])) {
        events.update(DateTime(date.year, date.month, date.day), (_) {
          return [Event(done: false)]; //find where date == date in doneDatesList and set event to true
        }, ifAbsent: () => [Event(done: false)]);
        date = date.add(Duration(days: habit["make"] ? habit["repeat"] : 1));
      }

      return Habit(
          key: habit["id"],
          make: habit["make"] == 0 ? false : true,
          title: habit["title"],
          enddate: DateTime.parse(habit["enddate"]),
          creationDate: DateTime.parse(habit["creationDate"]),
          repeat: habit["repeat"],
          reminder: habit["reminder"] == 0 ? false : true,
          events: {}

          ///fetch
          );
    }).toList();
  }
}

class Habit {
  final String key;
  final String title;
  final DateTime enddate;
  final int repeat;
  final bool reminder;
  final bool make;
  final DateTime creationDate;
  Map<DateTime, List<Event>> events = {};
  int bestStreak = 0;
  int currentStreak = 0;

  Habit({
    required this.key,
    required this.make,
    required this.title,
    required this.enddate,
    required this.creationDate,
    required this.repeat,
    required this.reminder,
    required this.events,
  }) {
    if (events.isEmpty) {
      DateTime date = creationDate;
      while (date.isBefore(enddate)) {
        events.update(DateTime(date.year, date.month, date.day),
            (_) => [Event(done: false)],
            ifAbsent: () => [Event(done: false)]);
        date = date.add(Duration(days: make ? repeat : 1));
      }
    }
  }
}
