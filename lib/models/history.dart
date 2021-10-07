import 'package:flutter/material.dart';
import 'package:mygoals/database/db_helper.dart';

import 'goals.dart';

class History extends ChangeNotifier {
  List<HistoryItem> _history = [];

  List<HistoryItem> getHistory() {
    return [..._history];
  }

  void addGoal(final goal) {
    // save current date as finished date
    // Must receive as goal
    final bool isGoal = goal.runtimeType == Goal;
    final today = DateTime.now();
    _history.add(HistoryItem(
        key: goal.key,
        title: isGoal ? goal.title : goal.parentTitle,
        desc: isGoal ? goal.desc : goal.title,
        finishedDate: today,
        targetDate: goal.enddate,
        isGoal: isGoal));

    DatabaseHelper.insertHistory({
      "id": goal.key,
      "title": isGoal ? goal.title : goal.parentTitle,
      "desc": isGoal ? goal.desc : goal.title,
      "finishedDate": today.toIso8601String(),
      "targetDate": goal.enddate.toIso8601String(),
      "isGoal": isGoal ? 1 : 0,
    });
    notifyListeners();
  }

  void removeItem(String key) {
    _history.removeWhere((item) => item.key == key);
    notifyListeners();
  }
}

class HistoryItem {
  final String key;
  final String title;
  final String desc;
  final DateTime finishedDate;
  final DateTime targetDate;
  final bool isGoal;

  HistoryItem({
    required this.key,
    required this.title,
    required this.desc,
    required this.finishedDate,
    required this.targetDate,
    required this.isGoal,
  });
}
