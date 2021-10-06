import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../screens/edit_goal_screen.dart';
import '../Palette.dart';
import '../models/goals.dart';
import '../models/history.dart';

class GoalTile extends StatefulWidget {
  final Key key;
  final String goalKey;
  final String title;
  final String desc;
  final bool goal;
  final String milestoneNumber;
  final bool repeat;
  final bool reminder;
  final Animation<double> animation;
  final Function helper;

  const GoalTile({
    required this.key,
    required this.goalKey,
    required this.title,
    required this.desc,
    required this.goal,
    required this.milestoneNumber,
    required this.repeat,
    required this.reminder,
    required this.animation,
    required this.helper,
  }) : super(key: key);

  @override
  _GoalTileState createState() => _GoalTileState();
}

class _GoalTileState extends State<GoalTile> {
  late ConfettiController _confettiController;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 300));
  }

  void _completeGoal(BuildContext context) async {
    final goalProvider = Provider.of<GoalList>(context, listen: false);
    final goal = goalProvider
        .getGoals()
        .firstWhere((goal) => goal.key == widget.goalKey);
    await widget.helper(widget.key, widget.goal);
    Provider.of<History>(context, listen: false).addGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      key: widget.key,
      opacity: widget.animation,
      child: Container(
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
                            return EditGoalScreen(widget.goalKey);
                          }));
                        }, // Edit Goal
                        child: Icon(
                          Icons.edit,
                          color: Palette.white,
                        )),
                    SizedBox(
                      width: 13,
                    ),
                    GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   _confettiController.play();
                        // });
                        // completeGoal(context);
                      }, // Complete Goal
                      child: Checkbox(
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
                          setState(() {
                            isFinished = value!;
                          });
                          Future.delayed(Duration(milliseconds: 250), () {
                            setState(() {
                              _confettiController.play();
                            });
                          });
                          Future.delayed(Duration(milliseconds: 450),
                              () => _completeGoal(context));
                        },
                      ),
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
            Positioned(
              right: 13,
              top: 13,
              child: ConfettiWidget(
                blastDirectionality: BlastDirectionality.explosive,
                confettiController: _confettiController,
                numberOfParticles: 30,
                maximumSize: const Size(15, 15),
                minimumSize: const Size(10, 10),
                gravity: 0.4,
                colors: [
                  Palette.red,
                  Palette.primary,
                  Palette.secondary,
                  Palette.status,
                  Palette.white
                ],
                minBlastForce: 30,
                maxBlastForce: 60,
                emissionFrequency: 0.25,
              ),
            )
          ],
        ),
      ),
    );
  }
}
