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
      "creationDate": DateTime(habit.creationDate.year,
              habit.creationDate.month, habit.creationDate.day)
          .toIso8601String(),
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
    dates.retainWhere((element) => element.isBefore(DateTime.now()));
    counter = 0;
    int daysAtEnd = 0;
    for (int i = 0; i < dates.length; i++) {
      DateTime date = dates[i];

      if (i == 0 && habit.events[date]![0].done) {
        DateTime tod = DateTime.now();
        daysAtEnd =
            DateTime(tod.year, tod.month, tod.day).difference(date).inDays;
        print(daysAtEnd);
      }

      if (!habit.events[date]![0].done) {
        break;
      } else {
        counter++;
      }
    }
    habit.currentStreak =
        counter == 0 ? 0 : ((counter - 1) * habit.repeat) + daysAtEnd;
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
    _habits.forEach((habit) {
      int bestStrk = 0;
      int counter = 0;
      List<DateTime> dates = [];
      habit.events.forEach((date, list) {
        dates.add(date);
        if (list[0].done) {
          counter++;
        } else {
          bestStrk = max(counter, bestStrk);
          counter = 0;
        }
      });

      habit.bestStreak = (bestStrk * habit.repeat) - 1;
      dates = dates.reversed.toList();
      dates.retainWhere((element) => element.isBefore(DateTime.now()));
      counter = 0;
      int daysAtEnd = 0;
      for (int i = 0; i < dates.length; i++) {
        DateTime date = dates[i];

        if (i == 0 && habit.events[date]![0].done) {
          DateTime tod = DateTime.now();
          daysAtEnd =
              DateTime(tod.year, tod.month, tod.day).difference(date).inDays;
          print(daysAtEnd);
        }

        if (!habit.events[date]![0].done) {
          break;
        } else {
          counter++;
        }
      }
      habit.currentStreak =
          counter == 0 ? 0 : ((counter - 1) * habit.repeat) + daysAtEnd;
      habit.bestStreak = max(habit.bestStreak, habit.currentStreak);
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

      Map<DateTime, List<Event>> events = {};
      String doneDates = event["dates"] as String;
      // print(doneDates);
      List<DateTime> doneDatesList = [];

      doneDates.split(" ").forEach((string) {
        if (string.trim().isNotEmpty) doneDatesList.add(DateTime.parse(string));
      });

      DateTime date = DateTime.parse(habit["creationDate"]);
      while (date.isBefore(DateTime.parse(habit["enddate"]))) {
        events.update(DateTime(date.year, date.month, date.day), (_) {
          bool dateDone =
              doneDatesList.remove(DateTime(date.year, date.month, date.day));
          return [
            Event(done: dateDone,date: DateTime(date.year, date.month, date.day))
          ]; //find where date == date in doneDatesList and set event to true
        }, ifAbsent: () {
          bool dateDone =
              doneDatesList.remove(DateTime(date.year, date.month, date.day));
          return [
            Event(done: dateDone,date: DateTime(date.year, date.month, date.day))
          ]; //find where date == date in doneDatesList and set event to true
        });
        date =
            date.add(Duration(days: habit["make"] == 1 ? habit["repeat"] : 1));
      }

      return Habit(
        key: habit["id"],
        make: habit["make"] == 0 ? false : true,
        title: habit["title"],
        enddate: DateTime.parse(habit["enddate"]),
        creationDate: DateTime.parse(habit["creationDate"]),
        repeat: habit["repeat"],
        reminder: habit["reminder"] == 0 ? false : true,
        events: events,

        ///fetch
      );
    }).toList();
    notifyListeners();
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
            (_) => [Event(done: false,date: DateTime(date.year, date.month, date.day))],
            ifAbsent: () => [Event(done: false,date: DateTime(date.year, date.month, date.day))]);
        date = date.add(Duration(days: make ? repeat : 1));
      }
    }
  }
}
