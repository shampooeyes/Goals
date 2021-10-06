import 'package:flutter/material.dart';

import 'goals.dart';

class History extends ChangeNotifier {
  List<dynamic> _history = [];

  List<dynamic> getHistory() {
    return [..._history];
  }

  void addGoal(Goal goal) {
    // Must receive as goal
    _history.add(goal);
  }

  void addMilestone(Milestone milestone) {
    // Must receive as milestone
    _history.add(milestone);
  }
}
