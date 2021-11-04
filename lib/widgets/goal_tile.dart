import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  final String notificationId;

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
    required this.notificationId,
  }) : super(key: key);

  @override
  _GoalTileState createState() => _GoalTileState();
}

class _GoalTileState extends State<GoalTile> {
  bool isFinished = false;

  void _completeGoal(BuildContext context) {
    final goalProvider = Provider.of<GoalList>(context, listen: false);
    if (widget.goal &&
        goalProvider
            .getGoals()
            .firstWhere((goal) => goal.key == widget.goalKey)
            .milestones
            .isNotEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text("Outstanding Milestones"),
                content: Text("Please complete this goal's milestones first!"),
                actions: [
                  TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(
                        "OK",
                        style: const TextStyle(
                          fontFamily: "OpenSans",
                          fontSize: 17,
                          color: Color(0xff303030),
                        ),
                      )),
                ],
              ));
      setState(() {
        isFinished = false;
      });
      return;
    }

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
    Provider.of<History>(context, listen: false)
        .addGoal(widget.goal ? goal : milestone);
    widget.playConfetti();
    if (widget.goal && widget.reminder) {
      String appId = "bbdc8751-01db-4011-b5c6-79c78b349bd6";
      http.delete(Uri.parse("https://onesignal.com/api/v1/notifications/${widget.notificationId}?app_id=$appId"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: const Color(0x4d000000),
                offset: Offset(1.2246467991473532e-16, 2),
                blurRadius: 6,
                spreadRadius: 0)
          ],
          color: Palette.primary),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 14, top: 9),
                constraints: BoxConstraints(maxWidth: 260),
                child: Wrap(children: [
                  Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(height: 1.3),
                  ),
                ]),
              ),
              if (widget.desc.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 2, left: 14, bottom: 3),
                  constraints: BoxConstraints(maxWidth: 260),
                  child: Wrap(
                    children: [
                      Text(
                        widget.desc,
                        style: const TextStyle(
                            color: Color(0xffbeffec),
                            fontSize: 13.5,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(
                    left: 14, top: 3, right: 10, bottom: 2),
                child: Row(
                  children: [
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
                        Icons.notifications_active,
                        color: Color(0xffbeffec),
                        size: 14,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //actions
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (ctx) {
                            return EditGoalScreen(
                              widget.repeat | !widget.goal ? widget.parentKey : widget.goalKey,
                            );
                          }));
                        }, // Edit Goal
                        child: Icon(
                          Icons.edit,
                          color: Palette.white,
                        )),
                    SizedBox(
                      width: 10,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
