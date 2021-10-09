import 'package:flutter/material.dart';
import 'package:mygoals/database/db_helper.dart';

import 'goals.dart';

class History extends ChangeNotifier {
  List<HistoryItem> _history = [];

  void fetchAndSetHistory() async {
    final data = await DatabaseHelper.getHistoryData();
    data.forEach((item) {
      _history.add(HistoryItem(
          key: item["id"],
          title: item["title"],
          desc: item["desc"],
          finishedDate: DateTime.parse(item["finishedDate"]),
          targetDate: DateTime.parse(item["targetDate"]),
          isGoal: item["isGoal"] == 1 ? true : false));
    });
  }

  List<HistoryItem> getHistory(DateTime filterDate) {
    List<HistoryItem> result = [];
    _history.forEach((item) {
      if (item.finishedDate.month == filterDate.month) result.add(item);
    });

    return [...result];
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
    DatabaseHelper.deleteHistory(key);
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
