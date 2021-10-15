import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygoals/models/goals.dart';
import 'package:mygoals/models/habits.dart';
import 'package:mygoals/models/history.dart';
import 'package:mygoals/screens/history_screen.dart';
import 'package:mygoals/screens/new_goal_screen.dart';
import 'package:mygoals/widgets/date_chip.dart';
import 'package:mygoals/widgets/goal_tile.dart';
import 'package:mygoals/widgets/goal_tile_copy.dart';
import 'package:mygoals/widgets/habit_tile.dart';
import 'package:provider/provider.dart';

import '../Palette.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late ConfettiController _confettiController;
  late DateTime selectedDate;
  @override
  void initState() {
    initialize();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 400));
    super.initState();
  }

  void initialize() async {
    final goalProvider = Provider.of<GoalList>(context, listen: false);
    await goalProvider.fetchAndSetGoals();
    List<DateTime> dates = goalProvider.getDates();
    if (dates.isNotEmpty) selectedDate = dates.first;
    final habitProvider = Provider.of<HabitList>(context, listen: false);
    await habitProvider.fetchAndSetHabits();
    habitProvider.setStreaks();
    Provider.of<History>(context, listen: false).fetchAndSetHistory();
  }

  void playConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> animations = [
      //Animation 1
      Stack(children: [
        Positioned(
            bottom: 0,
            child: ConfettiWidget(
              blastDirectionality: BlastDirectionality.directional,
              blastDirection: 6.5 * pi / 4,
              confettiController: _confettiController,
              numberOfParticles: 20,
              maximumSize: const Size(17, 17),
              minimumSize: const Size(10, 10),
              gravity: 0.35,
              colors: [
                Palette.red,
                Palette.primary,
                Palette.secondary,
                Palette.status,
                Palette.white
              ],
              minBlastForce: 110,
              maxBlastForce: 140,
              emissionFrequency: 0.25,
            )),
        Positioned(
            bottom: 0,
            right: 0,
            child: ConfettiWidget(
              blastDirectionality: BlastDirectionality.directional,
              blastDirection: 5.5 * pi / 4,
              confettiController: _confettiController,
              numberOfParticles: 20,
              maximumSize: const Size(17, 17),
              minimumSize: const Size(10, 10),
              gravity: 0.35,
              colors: [
                Palette.red,
                Palette.primary,
                Palette.secondary,
                Palette.status,
                Palette.white
              ],
              minBlastForce: 110,
              maxBlastForce: 140,
              emissionFrequency: 0.25,
            )),
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width / 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ConfettiWidget(
              blastDirectionality: BlastDirectionality.explosive,
              confettiController: _confettiController,
              numberOfParticles: 30,
              maximumSize: const Size(20, 20),
              minimumSize: const Size(15, 15),
              gravity: 0.5,
              colors: [
                Palette.red,
                Palette.primary,
                Palette.secondary,
                Palette.status,
                Palette.white
              ],
              minBlastForce: 40,
              maxBlastForce: 60,
              emissionFrequency: 0.25,
            ),
          ),
        ),
      ]),
      // Animation 2
      Stack(children: [
        Positioned(
          left: -20,
          top: MediaQuery.of(context).size.height / 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ConfettiWidget(
              blastDirectionality: BlastDirectionality.explosive,
              confettiController: _confettiController,
              numberOfParticles: 30,
              maximumSize: const Size(17, 17),
              minimumSize: const Size(12, 12),
              gravity: 0.33,
              colors: [
                Palette.red,
                Palette.primary,
                Palette.secondary,
                Palette.status,
                Palette.white
              ],
              minBlastForce: 50,
              maxBlastForce: 70,
              emissionFrequency: 0.25,
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width + 20,
          top: MediaQuery.of(context).size.height / 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ConfettiWidget(
              blastDirectionality: BlastDirectionality.explosive,
              confettiController: _confettiController,
              numberOfParticles: 30,
              maximumSize: const Size(17, 17),
              minimumSize: const Size(12, 12),
              gravity: 0.33,
              colors: [
                Palette.red,
                Palette.primary,
                Palette.secondary,
                Palette.status,
                Palette.white
              ],
              minBlastForce: 50,
              maxBlastForce: 70,
              emissionFrequency: 0.25,
            ),
          ),
        ),
      ]),
    ];

    int random = Random().nextInt(2);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final response =
              await Navigator.of(context).pushNamed(NewGoalScreen.routeName);
          if (response != null)
            setState(() {
              selectedDate = response as DateTime;
            });
        },
        backgroundColor: Palette.secondary,
        child: Icon(
          CupertinoIcons.add,
          size: 30,
        ),
      ),
      appBar: AppBar(
        title: Text("My Goals",
            style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(HistoryScreen.routeName);
            },
            icon: Icon(Icons.history, size: 30),
          )
        ],
      ),
      body: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 22, right: 19, top: 12, bottom: 4),
              child: Text(
                "Habits",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Consumer<HabitList>(builder: (context, snapshot, child) {
              final _habits = snapshot.getHabits();
              if (_habits.isEmpty)
                return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/bearhabits.png",
                    ));
              return Container(
                margin: const EdgeInsets.only(left: 5),
                constraints: BoxConstraints(maxHeight: 104.5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _habits.length,
                  itemBuilder: (ctx, index) => HabitTile(_habits[index]),
                ),
              );
            }),
            Container(
              margin: const EdgeInsets.only(
                  left: 22, right: 19, top: 10, bottom: 8),
              child: Text(
                "Goals",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Consumer<GoalList>(
              builder: (ctx, snapshot, child) {
                List goals = snapshot.getGoals();
                final dates = snapshot.getDates();

                return StatefulBuilder(
                    builder: (BuildContext ctx, StateSetter setState) {
                  //
                  if (goals.isEmpty)
                    return Container(
                        alignment: Alignment.center,
                        height: 200,
                        child: Image.asset("assets/images/beargoals.png"));

                  final _listKey = GlobalKey<AnimatedListState>();
                  final finalGoals = [...goals];
                  List<Milestone> milestones = [];

                  finalGoals.forEach((goal) {
                    if (goal.milestones.length != 0)
                      goal.milestones
                          .forEach((milestone) => milestones.add(milestone));
                  });

                  finalGoals
                      .retainWhere((goal) => goal.enddate == selectedDate);

                  milestones.retainWhere(
                      (milestone) => milestone.enddate == selectedDate);

                  final tiles = [...finalGoals, ...milestones];

                  //function to remove from tiles

                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 21),
                        width: MediaQuery.of(context).size.width - 21,
                        height: 26,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: dates.length,
                          itemBuilder: (ctx, index) {
                            final isSelected = selectedDate == dates[index];
                            return GestureDetector(
                              onTap: () {
                                if (!isSelected) {
                                  setState(() {
                                    selectedDate = dates[index];
                                    snapshot.notifyAllListeners();
                                  });
                                }
                              },
                              child: DateChip(
                                  DateFormat("d MMM")
                                      .format(dates[index])
                                      .toUpperCase(),
                                  isSelected),
                            );
                          },
                        ),
                      ),
                      Container(
                        // tight height
                        margin:
                            const EdgeInsets.only(left: 15, top: 12, right: 15),
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).viewPadding.bottom -
                            360,
                        width: MediaQuery.of(context).size.width - 15,
                        child: AnimatedList(
                            // extract to goal tile
                            key: _listKey,
                            shrinkWrap: true,
                            initialItemCount: tiles.length,
                            itemBuilder:
                                (ctx, index, Animation<double> animation) {
                              final bool isGoal =
                                  tiles[index].runtimeType == Goal;

                              void removeItem(
                                  Key key, var goal, Goal associatedGoal) {
                                //var goal may be milestone
                                _listKey.currentState!.removeItem(
                                    index,
                                    (context, animation) => SlideTransition(
                                          position: animation.drive(Tween(
                                                  begin: Offset(-0.5, 0),
                                                  end: Offset(0, 0))
                                              .chain(CurveTween(
                                                  curve:
                                                      Curves.easeInOutCubic))),
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: GoalTileCopy(
                                              title: associatedGoal.title,
                                              desc: isGoal
                                                  ? goal.desc
                                                  : goal.title,
                                              isGoal: isGoal,
                                              milestoneNumber: isGoal
                                                  ? ""
                                                  : "${goal.milestoneNumber}/${associatedGoal.milestones.length}",
                                              // repeat: goal.repeat == 0
                                              //     ? false
                                              //     : true,
                                              reminder: associatedGoal.reminder,
                                            ),
                                          ),
                                        ),
                                    duration: Duration(milliseconds: 350));
                                tiles.removeAt(index);

                                isGoal
                                    ? snapshot.completeGoal(goal.key)
                                    : snapshot.completeMilestone(
                                        goal.key, goal.parentKey);
                              }

                              if (tiles[index].runtimeType == Goal) {
                                return GoalTile(
                                  key: ValueKey(tiles[index].key),
                                  goalKey: tiles[index].key,
                                  title: tiles[index].title,
                                  desc: tiles[index].desc,
                                  goal: true,
                                  milestoneNumber: "",
                                  repeat:
                                      tiles[index].repeat == 0 ? false : true,
                                  reminder: tiles[index].reminder,
                                  helper: removeItem,
                                  playConfetti: playConfetti,
                                );
                              }
                              Goal associatedGoal = snapshot
                                  .getGoals()
                                  .firstWhere((goal) =>
                                      goal.key == tiles[index].parentKey);

                              int totalMilestones =
                                  associatedGoal.milestones.length;
                              int milestoneNumber =
                                  tiles[index].milestoneNumber;

                              return GoalTile(
                                key: UniqueKey(),
                                goalKey: tiles[index].key,
                                parentKey: tiles[index].parentKey,
                                title: associatedGoal.title,
                                desc: tiles[index].title,
                                goal: false,
                                milestoneNumber:
                                    "$milestoneNumber/$totalMilestones",
                                repeat: false,
                                reminder: associatedGoal.reminder,
                                helper: removeItem,
                                playConfetti: playConfetti,
                              );
                            }),
                      ),
                    ],
                  );
                });
              },
            ),
          ],
        ),
        animations[random]
      ]),
    );
  }
}
