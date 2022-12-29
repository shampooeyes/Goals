import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../../edit_goal/edit_goal_screen.dart';
import '../../../Palette.dart';
import '../../../models/goals.dart';
import '../../../models/history.dart';

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
  final Function undoFunc;
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
    required this.undoFunc,
    required this.playConfetti,
    required this.notificationId,
  }) : super(key: key);

  @override
  _GoalTileState createState() => _GoalTileState();
}

class _GoalTileState extends State<GoalTile> {
  bool isFinished = false;
  late GoalList goalProvider;
  late Goal goal;
  late var milestone;

  @override
  void initState() {
    super.initState();
    goalProvider = Provider.of<GoalList>(context, listen: false);

    goal = widget.goal
        ? goalProvider
            .getGoals()
            .firstWhere((goal) => goal.key == widget.goalKey)
        : goalProvider
            .getGoals()
            .firstWhere((goal) => goal.key == widget.parentKey);
    milestone = widget.goal
        ? goal
        : goal.milestones.firstWhere((mile) => mile.key == widget.goalKey);
  }

  Future<void> _completeGoal(
      BuildContext context, bool dismissed, bool delete) async {
    if (widget.goal &&
        goalProvider
            .getGoals()
            .firstWhere((goal) => goal.key == widget.goalKey)
            .milestones
            .isNotEmpty) {
      bool deleteWithMilestones = false;
      if (!delete)
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("Outstanding Milestones"),
                  content:
                      Text("Please complete this goal's milestones first!"),
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
      if (delete) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("Delete ${widget.title}"),
                  content: Text("This will delete all associated milestones"),
                  actions: [
                    TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text(
                          "CANCEL",
                          style: const TextStyle(
                            fontFamily: "OpenSans",
                            fontSize: 17,
                            color: Color(0xff303030),
                          ),
                        )),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            deleteWithMilestones = true;
                          });
                          Navigator.of(context).pop();
                        },
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
      }

      setState(() {
        isFinished = deleteWithMilestones;
      });
      if (!deleteWithMilestones) {
        return;
      }
    }

    if (!delete) {
      widget.playConfetti();
      Provider.of<History>(context, listen: false)
          .addGoal(widget.goal ? goal : milestone);
    }
    widget.helper(widget.key, milestone, goal,
        dismissed); //milestone is the same goal if type is Goal
    if (widget.goal && widget.reminder) {
      FlutterLocalNotificationsPlugin().cancel(goal.key.hashCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    String goalType = widget.goal ? "Goal" : 'Milestone';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return EditGoalScreen(
            widget.repeat | !widget.goal ? widget.parentKey : widget.goalKey,
          );
        }));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (dir) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(dir == DismissDirection.endToStart
                    ? "$goalType Completed"
                    : "$goalType Deleted"),
                action: SnackBarAction(
                  label: "UNDO",
                  textColor: Palette.secondary,
                  onPressed: () {
                    widget.undoFunc(widget.goal ? goal : milestone);
                  },
                )));

            if (dir == DismissDirection.endToStart)
              _completeGoal(context, true, false);
            else // confirm delete
              _completeGoal(context, true, true);
          },
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15),
            color: Palette.red,
            child: Icon(Icons.delete, size: 26, color: Palette.white),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.only(right: 15),
            alignment: Alignment.centerRight,
            color: Palette.primary.withAlpha(150),
            child: Icon(Icons.check, color: Palette.white, size: 26),
          ),
          child: Container(
            color: Palette.primary,
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
                        margin:
                            const EdgeInsets.only(top: 2, left: 14, bottom: 3),
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
                                    widget.repeat | !widget.goal
                                        ? widget.parentKey
                                        : widget.goalKey,
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
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
                                  () {
                                    _completeGoal(context, false, false);
                                    widget.undoFunc(widget.goal ? goal : milestone);
                                    }
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
