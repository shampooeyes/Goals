import 'package:flutter/material.dart';

import 'goals.dart';

class History extends ChangeNotifier {
  List<dynamic> _history = [];

  List<dynamic> getHistory() {
    return [..._history];
  }

  void addGoal(goal) {
    // Must receive as goal
    if (goal.runtimeType == Milestone) {
      addMilestone(goal);
      return;
    }
    _history.add(goal);
  }

  void addMilestone(milestone) {
    _history.add(milestone);
  }
}
