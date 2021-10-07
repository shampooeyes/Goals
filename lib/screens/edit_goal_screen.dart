import 'package:flutter/material.dart';
import 'package:mygoals/models/goals.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Palette.dart';
import 'new_milestone_screen.dart';

class EditGoalScreen extends StatefulWidget {
  static const routeName = "edit-goal-screen";
  final String goalKey;
  final bool isGoal;

  EditGoalScreen(this.goalKey, {this.isGoal = true,});

  @override
  _EditGoalScreenState createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _repeatController = TextEditingController();
  late Goal goal;
  late DateTime _targetDate;
  late List<Milestone> _milestones;
  late bool _reminder;
  late bool _repeater;
  int _repeatMultiplier = 1;
  String _repeatPeriod = "days";

  @override
  void initState() {
    goal = Provider.of<GoalList>(context, listen: false)
        .getGoals()
        .firstWhere((g) => g.key == widget.goalKey.toString());

    _milestones = goal.milestones;
    _targetDate = goal.enddate;
    _reminder = goal.reminder;
    _repeater = goal.repeat != 0;
    _titleController.text = goal.title;
    _descController.text = goal.desc;

    if (_repeater) {
      if (goal.repeat % 30 == 0) {
        _repeatPeriod = "months";
        _repeatController.text = "${goal.repeat / 30}";
      } else if (goal.repeat % 7 == 0) {
        _repeatPeriod = "weeks";
        _repeatController.text = "${goal.repeat / 7}";
      } else
        _repeatController.text = "${goal.repeat}";
    } else
      _repeatController.text = "2";

    super.initState();
  }

  void _addMilestone(Milestone milestone) {
    setState(() {
      _milestones.add(milestone);
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Palette.secondary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != DateTime.now())
      setState(() {
        _targetDate = pickedDate;
      });
  }

  Future<void> _selectRepeat(BuildContext context) {
    final _tempController = TextEditingController();
    _tempController.text = _repeater ? _repeatController.text : "";
    return showDialog(
        context: context,
        builder: (ctx) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: StatefulBuilder(
              builder: (ctx, setState) => AlertDialog(
                title: Text(
                  "Repeat Goal",
                  style: TextStyle(color: Palette.text),
                ),
                backgroundColor: Palette.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                actions: [
                  TextButton(
                      onPressed: () {
                        _repeater = false;
                        Navigator.of(context).pop();
                      },
                      child: Text("CANCEL",
                          style:
                              Theme.of(context).textTheme.headline2!.copyWith(
                                    fontSize: 16,
                                    color: Palette.text,
                                  ))),
                  TextButton(
                      onPressed: () {
                        final number = int.tryParse(_tempController.text);
                        if (number == null) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please only enter numbers"),
                            backgroundColor: Palette.darkred,
                            duration: Duration(seconds: 3),
                          ));
                        } else {
                          _repeatController.text = _tempController.text;

                          _repeater = true;
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        "OK",
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                              fontSize: 16,
                              color: Palette.text,
                            ),
                      )),
                ],
                content: Row(
                  children: [
                    Text("Every", style: Theme.of(context).textTheme.bodyText1),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      height: 30,
                      width: 40,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _tempController,
                        cursorColor: Palette.primary,
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Palette.primary, width: 2),
                          ),
                        ),
                      ),
                    ),
                    DropdownButton(
                      onTap: () =>
                          FocusScope.of(context).requestFocus(new FocusNode()),
                      dropdownColor: Palette.background,
                      value: _repeatPeriod,
                      onChanged: (value) {
                        switch (value) {
                          case "weeks":
                            _repeatMultiplier = 7;
                            setState(() {
                              _repeatPeriod = "weeks";
                            });
                            break;
                          case "months":
                            _repeatMultiplier = 30;
                            setState(() {
                              _repeatPeriod = "months";
                            });
                            break;
                          default:
                            setState(() {
                              _repeatPeriod = "days";
                            });
                            _repeatMultiplier = 1;
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          child: Center(
                              child: Text(
                            "days",
                            style: Theme.of(context).textTheme.bodyText1,
                          )),
                          value: "days",
                        ),
                        DropdownMenuItem(
                          child: Center(
                              child: Text(
                            "weeks",
                            style: Theme.of(context).textTheme.bodyText1,
                          )),
                          value: "weeks",
                        ),
                        DropdownMenuItem(
                          child: Center(
                              child: Text(
                            "months",
                            style: Theme.of(context).textTheme.bodyText1,
                          )),
                          value: "months",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _submitGoal(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter goal title"),
        backgroundColor: Palette.darkred,
        duration: Duration(seconds: 3),
      ));
      return;
    }
    final provider = Provider.of<GoalList>(context, listen: false);
    provider.removeGoal(widget.goalKey);
    provider.addGoal(Goal(
      key: goal.key,
      title: _titleController.text.trim(),
      desc: _descController.text.trim(),
      enddate: DateTime(_targetDate.year, _targetDate.month, _targetDate.day),
      milestones: _milestones,
      repeat:
          _repeater ? _repeatMultiplier * int.parse(_repeatController.text) : 0,
      reminder: _reminder,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Edit Goal",
            style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          TextButton(
            onPressed: () => _submitGoal(context),
            child: Text(
              "SAVE",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Palette.white,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
              child: Text(
                "Goal Title",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 15.5),
                width: 360,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Palette.primary, width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x1a000000),
                          offset: Offset(1.2246467991473532e-16, 2),
                          blurRadius: 8,
                          spreadRadius: 0)
                    ],
                    color: Palette.white),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: TextField(
                    controller: _titleController,
                    maxLength: 26,
                    cursorColor: Palette.primary,
                    cursorHeight: 13.5,
                    cursorRadius: Radius.circular(15),
                    style: const TextStyle(
                        color: Palette.text,
                        fontFamily: "OpenSans",
                        fontSize: 13.5),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
              child: Text(
                "Goal Description",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 15.5),
                width: 360,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Palette.primary, width: 1),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x1a000000),
                          offset: Offset(1.2246467991473532e-16, 2),
                          blurRadius: 8,
                          spreadRadius: 0)
                    ],
                    color: Palette.white),
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: TextField(
                    controller: _descController,
                    maxLength: 60,
                    cursorHeight: 13.5,
                    cursorRadius: Radius.circular(15),
                    cursorColor: Palette.primary,
                    style: const TextStyle(
                      color: Palette.text,
                      fontFamily: "OpenSans",
                      fontSize: 13.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
              child: Text(
                "Milestones",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (ctx, index) {
                return Container(
                  margin: const EdgeInsets.only(
                      left: 15.5, bottom: 7.5, right: 15.5),
                  width: 360,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x1a000000),
                            offset: Offset(1.2246467991473532e-16, 2),
                            blurRadius: 8,
                            spreadRadius: 0)
                      ],
                      color: Palette.white),
                  child: Stack(children: [
                    Positioned(
                      left: 15,
                      top: 11,
                      child: Center(
                        child: Container(
                          child: Text(
                            _milestones[index].title,
                            style: const TextStyle(
                              color: Palette.text,
                              fontFamily: "OpenSans",
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _milestones.removeAt(index);
                          });
                        },
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: Palette.red,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ]),
                );
              },
              itemCount: _milestones.length,
            ),
            Container(
                margin: const EdgeInsets.only(left: 15.5),
                width: 360,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x1a000000),
                          offset: Offset(1.2246467991473532e-16, 2),
                          blurRadius: 8,
                          spreadRadius: 0)
                    ],
                    color: Palette.milestone),
                child: Stack(children: [
                  Positioned(
                    right: 3.5,
                    top: 3.5,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => NewMilestoneScreen(
                                _addMilestone, widget.goalKey)));
                      },
                      child: Icon(
                        CupertinoIcons.add,
                        color: Palette.white,
                        size: 34,
                      ),
                    ),
                  ),
                ])),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "Target Date",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          _selectDate(context, _targetDate);
                        },
                        child: Container(
                          width: 110,
                          height: 27,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Palette.primary),
                          child: Row(
                            children: [
                              Text(
                                DateFormat("dd/MM/yyyy").format(_targetDate),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Palette.white,
                                  ))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Column(
                    children: [
                      Text(
                        "Repeat",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color:
                                _repeater ? Palette.text : Color(0xff989898)),
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () async {
                          await _selectRepeat(context);
                          Future.delayed(Duration(milliseconds: 1))
                              .then((value) => setState(() {}));
                          if (_repeatController.text.isEmpty) {
                            setState(() => _repeater = false);
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 27,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: _repeater
                                  ? Palette.primary
                                  : Palette.milestone),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.restart,
                                color: _repeater
                                    ? Palette.white
                                    : Color(0xff989898),
                                size: 13,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _repeater
                                    ? _repeatController.text +
                                        " " +
                                        _repeatPeriod
                                    : "2 days",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(
                                        color: _repeater
                                            ? Palette.white
                                            : Color(0xff989898)),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 19.5),
                child: Column(children: [
                  Text(
                    "Remind Me",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      value: _reminder,
                      onChanged: (val) {
                        setState(() {
                          _reminder = val!;
                        });
                      },
                      splashRadius: 10,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Palette.primary,
                      side: BorderSide(width: 2, color: Palette.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(4.5),
                      )),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
