import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_goal_screen.dart';
import '../Palette.dart';
import '../models/goals.dart';
import '../models/history.dart';

class GoalTile extends StatefulWidget {
  final Key key;
  final String goalKey;
  final String parentKey;
  final String title;
  final String desc;
  final bool goal;
  final String milestoneNumber;
  final bool repeat;
  final bool reminder;
  final Function helper;
  final Function playConfetti;

  const GoalTile({
    required this.key,
    required this.goalKey,
    this.parentKey = "",
    required this.title,
    required this.desc,
    required this.goal,
    required this.milestoneNumber,
    required this.repeat,
    required this.reminder,
    required this.helper,
    required this.playConfetti,
  }) : super(key: key);

  @override
  _GoalTileState createState() => _GoalTileState();
}

class _GoalTileState extends State<GoalTile> {
  bool isFinished = false;

  void _completeGoal(BuildContext context) {
    widget.playConfetti();
    final goalProvider = Provider.of<GoalList>(context, listen: false);

    final goal = widget.goal
        ? goalProvider
            .getGoals()
            .firstWhere((goal) => goal.key == widget.goalKey)
        : goalProvider
            .getGoals()
            .firstWhere((goal) => goal.key == widget.parentKey);
    final milestone = widget.goal
        ? goal
        : goal.milestones.firstWhere((mile) => mile.key == widget.goalKey);
    widget.helper(widget.key, milestone,
        goal); //milestone is the same goal if type is Goal
    Provider.of<History>(context, listen: false).addGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: 330,
      height: 69,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: const Color(0x4d000000),
                offset: Offset(1.2246467991473532e-16, 2),
                blurRadius: 10,
                spreadRadius: 0)
          ],
          color: Palette.primary),
      child: Stack(
        children: [
          Positioned(
              left: 14,
              top: 9,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headline2,
              )),
          Positioned(
            left: 15,
            top: 36,
            child: Text(
              widget.desc,
              style: const TextStyle(
                  color: Color(0xffbeffec),
                  fontSize: 13.5,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Positioned(
              right: 13,
              top: 13,
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return EditGoalScreen(widget.goalKey,
                              isGoal: widget.goal);
                        }));
                      }, // Edit Goal
                      child: Icon(
                        Icons.edit,
                        color: Palette.white,
                      )),
                  SizedBox(
                    width: 13,
                  ),
                  Checkbox(
                    activeColor: Palette.white,
                    checkColor: Palette.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: isFinished,
                    side: BorderSide(width: 2, color: Palette.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    )),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        isFinished = value;
                      });
                      Future.delayed(Duration(milliseconds: 200),
                          () => _completeGoal(context));
                    },
                  ),
                ],
              )),
          Positioned(
              right: 24,
              top: 47.5,
              child: Row(
                children: [
                  // Goal settings (repeat, goal, milestone)
                  Text(
                    widget.goal
                        ? "Goal"
                        : "Milestone ${widget.milestoneNumber}",
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.normal,
                        color: Color(0xffbeffec)),
                  ),
                  if (widget.repeat) SizedBox(width: 10),
                  if (widget.repeat)
                    Icon(
                      Icons.replay,
                      color: Color(0xffbeffec),
                      size: 14,
                    ),
                  if (widget.reminder) SizedBox(width: 10),
                  if (widget.reminder)
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xffbeffec),
                    ),
                ],
              )),
        ],
      ),
    );
  }
}
