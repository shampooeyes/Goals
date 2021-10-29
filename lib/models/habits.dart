import 'package:flutter/material.dart';
import 'package:mygoals/database/db_helper.dart';
import 'package:mygoals/models/event.dart';

class HabitList extends ChangeNotifier {
  List<Habit> _habits = [];

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    DatabaseHelper.insertHabit("Habits", {
      "id": habit.key.toString(),
      "title": habit.title,
      "make": habit.make ? 1 : 0,
      "repeat": habit.repeat,
      "reminder": habit.reminder ? 1 : 0,
      "enddate": habit.enddate.toIso8601String(),
      "creationDate": habit.creationDate.toIso8601String(),
    });
  }

  List<Habit> getHabits() {
    return [..._habits];
  }

  void setStreaks() {
    DateTime now = DateTime.now();

    _habits.forEach((habit) {
      int difference = now.difference(habit.creationDate).inDays;
      habit.currentStreak = difference;
      if (difference > habit.bestStreak) habit.bestStreak = difference;
    });

    notifyListeners();
  }

  Future<void> fetchAndSetHabits() async {
    final List<Map<String, dynamic>> habits =
        await DatabaseHelper.getHabitsData();
    _habits = habits
        .map((habit) => Habit(
              key: habit["id"],
              make: habit["make"] == 0 ? false : true,
              title: habit["title"],
              enddate: DateTime.parse(habit["enddate"]),
              creationDate: DateTime.parse(habit["creationDate"]),
              repeat: habit["repeat"],
              reminder: habit["reminder"] == 0 ? false : true,
            ))
        .toList();
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
  }) {
    DateTime date = creationDate;
    while (date.isBefore(enddate)) {
      events.update(DateTime(date.year, date.month, date.day),
          (_) => [Event(done: false)],
          ifAbsent: () => [Event(done: false)]);
      date = date.add(Duration(days: make ? repeat : 1));
    }
  }
}
