import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygoals/models/goals.dart';
import 'package:mygoals/models/habits.dart';
import 'package:mygoals/models/history.dart';
import 'package:mygoals/screens/habit_details/habit_details_screen.dart';
import 'package:mygoals/screens/history/history_screen.dart';
import 'package:mygoals/screens/new_goal/new_goal_screen.dart';
import 'package:mygoals/screens/goals/widgets/date_chip.dart';
import 'package:mygoals/screens/goals/widgets/goal_tile.dart';
import 'package:mygoals/screens/goals/widgets/goal_tile_copy.dart';
import 'package:mygoals/screens/goals/widgets/habit_tile.dart';
import 'package:provider/provider.dart';

import '../../Palette.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late ConfettiController _confettiController;
  late DateTime selectedDate;
  @override
  void initState() {
    _initialize();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 400));
    super.initState();
  }

  Future<void> _initialize() async {
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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
          top: -70,
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

    final appBar = AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed(HistoryScreen.routeName);
        },
        icon: Icon(Icons.history, size: 30),
      ),
      title:
          Text("My Goals", style: Theme.of(context).appBarTheme.titleTextStyle),
      actions: [
        IconButton(
          onPressed: () async {
            final response =
                await Navigator.of(context).pushNamed(NewGoalScreen.routeName);
            if (response != null)
              setState(() {
                selectedDate = response as DateTime;
              });
          },
          icon: const Icon(CupertinoIcons.add, size: 30),
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(children: [
        RefreshIndicator(
          color: Palette.primary,
          onRefresh: () async {
            Provider.of<HabitList>(context, listen: false).setStreaks();
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Streaks Updated"),
              backgroundColor: Palette.primary.withAlpha(200),
              duration: Duration(seconds: 3),
            ));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 22, right: 19, top: 12),
                  child: Text(
                    "Habits",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                Consumer<HabitList>(builder: (context, snapshot, child) {
                  final _habits = snapshot.getHabits();
                  if (_habits.isEmpty)
                    return Container(
                        height: 133,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () async {
                            final response = await Navigator.of(context)
                                .pushNamed(NewGoalScreen.routeName);
                            if (response != null)
                              setState(() {
                                selectedDate = response as DateTime;
                              });
                          },
                          child: Container(
                            height: 100,
                            child: Image.asset(
                              "assets/images/bearhabits.png",
                            ),
                          ),
                        ));
                  return Container(
                    margin: const EdgeInsets.only(left: 5),
                    constraints: BoxConstraints(maxHeight: 127),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _habits.length,
                      itemBuilder: (ctx, index) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) =>
                                    HabitDetailsScreen(_habits[index])));
                          },
                          child: HabitTile(_habits[index])),
                    ),
                  );
                }),
                Container(
                  margin: const EdgeInsets.only(left: 22, right: 19),
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
                            child: GestureDetector(
                                onTap: () async {
                                  final response = await Navigator.of(context)
                                      .pushNamed(NewGoalScreen.routeName);
                                  if (response != null)
                                    setState(() {
                                      selectedDate = response as DateTime;
                                    });
                                },
                                child: Image.asset(
                                    "assets/images/beargoals.png")));

                      final _listKey = GlobalKey<AnimatedListState>();
                      final finalGoals = [...goals];
                      List<Milestone> milestones = [];

                      finalGoals.forEach((goal) {
                        if (goal.milestones.length != 0)
                          goal.milestones.forEach(
                              (milestone) => milestones.add(milestone));
                      });

                      finalGoals
                          .retainWhere((goal) => goal.enddate == selectedDate);

                      milestones.retainWhere(
                          (milestone) => milestone.enddate == selectedDate);

                      final tiles = [...finalGoals, ...milestones];

                      return Column(
                        children: [
                          // Dates Row
                          Container(
                            width: MediaQuery.of(context).size.width - 21,
                            height: 40,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(left: 5),
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
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 10, top: 5, bottom: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        border: Border.all(
                                            color: Palette.primary, width: 1.5),
                                        color: isSelected
                                            ? Palette.primary
                                            : Palette.background,
                                        boxShadow: [
                                          if (isSelected)
                                            const BoxShadow(
                                                color: Color(0xff42ad9f),
                                                spreadRadius: 0.5,
                                                blurRadius: 3)
                                        ]),
                                    child: DateChip(
                                        DateFormat("d MMM")
                                            .format(dates[index])
                                            .toUpperCase(),
                                        isSelected),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            child: AnimatedList(
                                // extract to goal tile
                                key: _listKey,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                initialItemCount: tiles.length,
                                itemBuilder:
                                    (ctx, index, Animation<double> animation) {
                                  final bool isGoal =
                                      tiles[index].runtimeType == Goal;

                                  void undoCompletion(Goal goal) {
                                    snapshot.addGoal(goal);
                                    Provider.of<History>(context, listen: false)
                                        .removeItem(goal.key);
                                  }

                                  void removeItem(Key key, var goal,
                                      Goal associatedGoal, bool dismissed) {
                                    if (!dismissed)
                                      _listKey.currentState!.removeItem(
                                          index,
                                          (context, animation) =>
                                              SlideTransition(
                                                position: animation.drive(Tween(
                                                        begin: Offset(-0.5, 0),
                                                        end: Offset(0, 0))
                                                    .chain(CurveTween(
                                                        curve: Curves
                                                            .easeInOutCubic))),
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
                                                        : "${goal.milestoneNumber}/${associatedGoal.totalMilestones}",
                                                    repeat: goal.repeat == 0
                                                        ? false
                                                        : true,
                                                    reminder:
                                                        associatedGoal.reminder,
                                                  ),
                                                ),
                                              ),
                                          duration:
                                              Duration(milliseconds: 350));
                                    else {
                                      _listKey.currentState!.removeItem(index,
                                          (context, animation) => Container());
                                    }
                                    tiles.removeAt(index);

                                    isGoal
                                        ? snapshot.completeGoal(goal.key)
                                        : snapshot.completeMilestone(
                                            goal.key, goal.parentKey);
                                  }

                                  if (tiles[index].runtimeType == Goal) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 10, left: 15, right: 15),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: const Color(0x2a000000),
                                              offset: Offset(
                                                  1.2246467991473532e-16, 2),
                                              blurRadius: 6,
                                              spreadRadius: 0)
                                        ],
                                      ),
                                      child: GoalTile(
                                        key: ValueKey(tiles[index].key),
                                        goalKey: tiles[index].key,
                                        parentKey: tiles[index].parentKey,
                                        title: tiles[index].title,
                                        desc: tiles[index].desc,
                                        goal: true,
                                        milestoneNumber: "",
                                        repeat: tiles[index].repeat == 0
                                            ? false
                                            : true,
                                        reminder: tiles[index].reminder,
                                        helper: removeItem,
                                        undoFunc: undoCompletion,
                                        playConfetti: playConfetti,
                                        notificationId:
                                            tiles[index].notificationId,
                                      ),
                                    );
                                  }
                                  Goal associatedGoal = snapshot
                                      .getGoals()
                                      .firstWhere((goal) =>
                                          goal.key == tiles[index].parentKey);

                                  int milestoneNumber =
                                      tiles[index].milestoneNumber;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, left: 15, right: 15),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: const Color(0x2a000000),
                                            offset: Offset(
                                                1.2246467991473532e-16, 2),
                                            blurRadius: 6,
                                            spreadRadius: 0)
                                      ],
                                    ),
                                    child: GoalTile(
                                      key: UniqueKey(),
                                      goalKey: tiles[index].key,
                                      parentKey: tiles[index].parentKey,
                                      title: associatedGoal.title,
                                      desc: tiles[index].title,
                                      goal: false,
                                      milestoneNumber:
                                          "$milestoneNumber/${associatedGoal.totalMilestones}",
                                      repeat: false,
                                      reminder: associatedGoal.reminder,
                                      helper: removeItem,
                                      undoFunc: undoCompletion,
                                      playConfetti: playConfetti,
                                      notificationId: "",
                                    ),
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
          ),
        ),
        animations[random]
      ]),
    );
  }
}
