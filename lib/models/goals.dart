import 'package:flutter/material.dart';
import 'package:mygoals/database/db_helper.dart';

class GoalList extends ChangeNotifier {
  List<Goal> _goals = [];

  void completeGoal(String key) {
    _goals.removeWhere((goal) => goal.key == key);
    DatabaseHelper.removeGoal("Goals", key);
  }

  void completeMilestone(String key, String parentKey) {
    final goal = _goals.firstWhere((goal) => goal.key == parentKey);
    goal.milestones.removeWhere((milestone) => milestone.key == key);
    DatabaseHelper.removeGoal("Milestones", key);
  }

  Future<void> fetchAndSetGoals() async {
    final List<Map<String, dynamic>> goals =
        await DatabaseHelper.getGoalsData();
    final List<Map<String, dynamic>> milestones =
        await DatabaseHelper.getMilestonesData();

    List<Milestone> _milestones = milestones.map((milestone) {
      Milestone result = Milestone(
          key: milestone["id"],
          parentKey: milestone["parentId"],
          title: milestone["title"],
          enddate: DateTime.parse(milestone["enddate"]));
      result.milestoneNumber = milestone["milestoneNumber"];
      return result;
    }).toList();

    goals.forEach((goal) {
      List<Milestone> _goalMilestones = _milestones
          .where((milestone) => milestone.parentKey == goal["id"])
          .toList();
      Goal finalGoal = Goal(
          key: goal["id"],
          parentKey: goal["parentId"],
          title: goal["title"],
          desc: goal["desc"],
          enddate: DateTime.parse(goal["enddate"]),
          reminder: goal["reminder"] == 0 ? false : true,
          repeat: goal["repeat"],
          milestones: _goalMilestones,
          totalMilestones: goal["totalMilestones"],
          notificationId: goal["notificationId"]);

      _goals.add(finalGoal);
    });
    notifyListeners();
  }

  void addGoal(Goal goal) {
    if (goal.repeat > 0) {
      var j = 0; // total num of goals
      DateTime date = DateTime.now();
      while (goal.enddate.isAfter(date)) {
        j++;
        date = date.add(Duration(days: goal.repeat));
      }

      for (int i = 0; i < j; i++) {
        final key = UniqueKey().toString();
        final enddate = DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(Duration(days: goal.repeat * i));

        _goals.add(Goal(
            key: key,
            parentKey: goal.key,
            title: goal.title,
            desc: goal.desc,
            milestones: goal.milestones,
            reminder: goal.reminder,
            repeat: goal.repeat,
            enddate: enddate,
            notificationId: goal.notificationId));
        DatabaseHelper.insertGoal("Goals", {
          "id": key,
          "parentId": goal.key,
          "title": goal.title,
          "desc": goal.desc,
          "reminder": goal.reminder ? 1 : 0,
          "repeat": goal.repeat,
          "enddate": enddate.toIso8601String(),
          "notificationId": goal.notificationId,
        });
      }
      notifyListeners();
      return;
    }

    goal.sortAndNumberMilestones();
    int totalMilestones = 0;
    goal.milestones.forEach((milestone) {
      totalMilestones++;
      DatabaseHelper.insertGoal("Milestones", {
        "id": milestone.key,
        "parentId": milestone.parentKey,
        "title": milestone.title,
        "milestoneNumber": milestone.milestoneNumber,
        "enddate": milestone.enddate.toIso8601String(),
      });
    });

    DatabaseHelper.insertGoal("Goals", {
      "id": goal.key,
      "parentId": "_",
      "title": goal.title,
      "desc": goal.desc,
      "reminder": goal.reminder ? 1 : 0,
      "repeat": goal.repeat,
      "enddate": goal.enddate.toIso8601String(),
      "notificationId": goal.notificationId,
      "totalMilestones": totalMilestones,
    });
    goal.milestones.forEach((mile) => mile.parentTitle = goal.title);
    goal.totalMilestones = totalMilestones;
    _goals.add(goal);
    notifyListeners();
  }

  void removeGoal(String key) {
    _goals.removeWhere((goal) => goal.key == key.toString());
    notifyListeners();
  }

  List<Goal> getGoals() {
    return [..._goals];
  }

  List<DateTime> getDates() {
    List<DateTime> dates = [];

    _goals.forEach((goal) {
      final date = goal.enddate;

      if (!dates.contains(DateTime(date.year, date.month, date.day)))
        dates.add(DateTime(date.year, date.month, date.day));

      goal.milestones.forEach((m) {
        if (!dates
            .contains(DateTime(m.enddate.year, m.enddate.month, m.enddate.day)))
          dates.add(DateTime(m.enddate.year, m.enddate.month, m.enddate.day));
      });
    });

    dates.sort((a, b) => a.compareTo(b));

    return dates;
  }

  void notifyAllListeners() {
    notifyListeners();
  }
}

class Goal {
  final String key;
  final String title;
  final String desc;
  final DateTime enddate;
  final List<Milestone> milestones;
  int totalMilestones;
  final int repeat; // in days
  final bool reminder;
  String notificationId;
  String parentKey;

  Goal({
    required this.key,
    required this.title,
    required this.desc,
    required this.enddate,
    required this.milestones,
    required this.repeat,
    required this.reminder,
    required this.notificationId,
    this.parentKey = "not-recurring",
    this.totalMilestones = 0,
  });

  List<Milestone> sortAndNumberMilestones() {
    milestones.sort((a, b) => a.enddate.compareTo(b.enddate));
    int counter = 1;
    milestones.forEach((milestone) {
      milestone.milestoneNumber = counter;
      counter++;
    });
    return milestones;
  }
}

class Milestone {
  final String key;
  final String parentKey;
  final String title;
  String parentTitle;
  final DateTime enddate;
  int milestoneNumber = 0;

  Milestone({
    required this.key,
    required this.parentKey,
    required this.title,
    this.parentTitle = "",
    required this.enddate,
  });
}
