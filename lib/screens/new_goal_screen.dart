import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:mygoals/models/habits.dart';
import 'package:provider/provider.dart';
import '/models/goals.dart';
import '/screens/new_milestone_screen.dart';

import '../Palette.dart';

class NewGoalScreen extends StatefulWidget {
  static const routeName = "new_goal_screen";

  @override
  _NewGoalScreenState createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final key = UniqueKey();

  final _descController = TextEditingController();
  final _repeatController = TextEditingController();
  final _titleController = TextEditingController();
  final _habitTitleController = TextEditingController();

  DateTime _targetDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _endDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(Duration(days: 30));
  bool _reminder = false;
  bool _repeater = false;
  int _repeatMultiplier = 1;
  String _repeatPeriod = "days";
  List<Milestone> _milestones = [];
  Color _buttonColor = Palette.primary;
  bool _make = true;

  @override
  void initState() {
    super.initState();
    final fbm =
        FirebaseMessaging.instance; // get instance when remind me enabled
    fbm.requestPermission();
  }

  @override
  void dispose() {
    _descController.dispose();
    _repeatController.dispose();
    _titleController.dispose();
    _habitTitleController.dispose();
    super.dispose();
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
        if (DefaultTabController.of(context)?.index == 0)
          _targetDate =
              DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
        else
          _endDate =
              DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      });
  }

  Future<void> _selectRepeat(BuildContext context) {
    final _tempController = TextEditingController();
    _repeatPeriod = _repeater ? _repeatPeriod : "days";
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

  Future<void> _selectHabitRepeat(BuildContext context) {
    final _tempController = TextEditingController();
    _tempController.text = _repeatController.text;
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
                  "Practice Every",
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
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter goal title"),
        backgroundColor: Palette.darkred,
        duration: Duration(seconds: 3),
      ));
      return;
    }
    Provider.of<GoalList>(context, listen: false).addGoal(Goal(
      key: key.toString(),
      title: _titleController.text.trim(),
      desc: _descController.text.trim(),
      enddate: DateTime(_targetDate.year, _targetDate.month, _targetDate.day),
      milestones: _milestones,
      repeat:
          _repeater ? _repeatMultiplier * int.parse(_repeatController.text) : 0,
      reminder: _reminder,
    ));
    Navigator.of(context).pop(_targetDate);
  }

  void _submitHabit(BuildContext context) {
    if (_habitTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter habit title"),
        backgroundColor: Palette.darkred,
        duration: Duration(seconds: 3),
      ));
      return;
    }
    if (_repeatController.text.isEmpty) _repeatController.text = "2";

    Provider.of<HabitList>(context, listen: false).addHabit(Habit(
      key: UniqueKey().toString(),
      make: _make,
      title: _habitTitleController.text.trim(),
      enddate: _endDate,
      creationDate: DateTime.now(),
      reminder: _reminder,
      repeat: _repeatMultiplier * int.parse(_repeatController.text),
    ));
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: GestureDetector(
            onTap: () {
              DefaultTabController.of(context)?.index == 0
                  ? _submitGoal(context)
                  : _submitHabit(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              width: 240,
              height: 65,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(57)),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x4d000000),
                        offset: Offset(1.2246467991473532e-16, 2),
                        blurRadius: 10,
                        spreadRadius: 0)
                  ],
                  color: DefaultTabController.of(context)?.index == 0
                      ? Palette.primary
                      : _buttonColor),
              child: Center(
                child: Text(
                  DefaultTabController.of(context)?.index == 0
                      ? "ADD GOAL"
                      : "ADD HABIT",
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: Text("New Goal",
                style: Theme.of(context).appBarTheme.titleTextStyle),
            bottom: TabBar(
              onTap: (_) {
                FocusScope.of(context).requestFocus(new FocusNode());
                setState(() {});
              },
              labelColor: Palette.white,
              unselectedLabelColor: Color(0xFFe9d5bb),
              indicatorColor: Palette.white,
              tabs: [
                Tab(
                  child: Text(
                    "GOAL",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "HABIT",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 14.5, bottom: 5),
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
                            border:
                                Border.all(color: Palette.primary, width: 1),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0x1a000000),
                                  offset: Offset(1.2246467991473532e-16, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0)
                            ],
                            color: Palette.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: TextField(
                            controller: _titleController,
                            maxLength: 26,
                            cursorColor: Palette.primary,
                            cursorHeight: 13.5,
                            cursorRadius: Radius.circular(15),
                            autocorrect: false,
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
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 14.5, bottom: 5),
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
                            border:
                                Border.all(color: Palette.primary, width: 1),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: TextField(
                            controller: _descController,
                            maxLength: 60,
                            cursorHeight: 13.5,
                            cursorRadius: Radius.circular(15),
                            cursorColor: Palette.primary,
                            autocorrect: false,
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
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 14.5, bottom: 5),
                      child: Text(
                        "Milestones",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    SizedBox(
                      width: 375.5, //360 +15.5 padding
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          return Container(
                            margin:
                                const EdgeInsets.only(left: 15.5, bottom: 7.5),
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
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
                                        _addMilestone, key.toString())));
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Palette.primary),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat("dd/MM/yyyy")
                                            .format(_targetDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: Palette.white,
                                      )
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(
                                        color: _repeater
                                            ? Palette.text
                                            : Color(0xff989898)),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: Palette.primary,
                                  side: BorderSide(
                                      width: 2, color: Palette.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                    Radius.circular(4.5),
                                  )),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 27,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: _reminder
                                          ? Palette.primary
                                          : Palette.milestone),
                                  child: Text(
                                    DateFormat("hh:mm a").format(
                                        _targetDate), // change targetdate to timeselector
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(
                                            color: _reminder
                                                ? Palette.white
                                                : Color(0xff989898)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 28, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _make = true;
                                _habitTitleController.text = "";
                                _buttonColor = Palette.primary;
                                _reminder = false;
                              });
                            },
                            child: AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                color: _make
                                    ? Color(0xff00c6ac)
                                    : Color(0xff97c7c1),
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins",
                                fontSize: _make ? 28.0 : 26.0,
                                shadows: [
                                  if (_make)
                                    Shadow(
                                        color:
                                            Color.fromRGBO(33, 175, 134, 0.5),
                                        blurRadius: 8),
                                ],
                              ),
                              child: Text(
                                "MAKE",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 78),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _make = false;
                              _habitTitleController.text = "";
                              _buttonColor = Palette.red;
                              _reminder = false;
                            });
                          },
                          child: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                                color: _make
                                    ? Color(0xffdda8a8)
                                    : Color(0xffda0000),
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins",
                                fontStyle: FontStyle.normal,
                                fontSize: _make ? 26.0 : 28.0,
                                shadows: [
                                  if (!_make)
                                    Shadow(
                                        color: Color.fromRGBO(218, 0, 0, 0.5),
                                        blurRadius: 8),
                                ]),
                            child: Text(
                              "BREAK",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 5),
                      child: Text(
                        "Habit Title",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        margin: const EdgeInsets.only(left: 15.5),
                        width: 360,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: _make ? Palette.primary : Palette.red,
                                width: 1),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0x1a000000),
                                  offset: Offset(1.2246467991473532e-16, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0)
                            ],
                            color: Palette.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: TextField(
                            controller: _habitTitleController,
                            maxLength: 26,
                            cursorColor: Palette.primary,
                            cursorHeight: 13.5,
                            cursorRadius: Radius.circular(15),
                            autocorrect: false,
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
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "End Date",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  _selectDate(context, _endDate);
                                },
                                child: Container(
                                  width: 110,
                                  height: 27,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: _make
                                          ? Palette.primary
                                          : Palette.red),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat("dd/MM/yyyy")
                                            .format(_endDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
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
                          if (_make)
                            SizedBox(
                              width: 50,
                            ),
                          if (_make)
                            Column(
                              children: [
                                Text(
                                  "Practice Every",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(color: Palette.text),
                                ),
                                SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () async {
                                    await _selectHabitRepeat(context);
                                    Future.delayed(Duration(milliseconds: 1))
                                        .then((value) => setState(() {}));
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 27,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        color: Palette.primary),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.restart,
                                          color: Palette.white,
                                          size: 13,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          _repeatController.text.isNotEmpty
                                              ? _repeatController.text +
                                                  " " +
                                                  _repeatPeriod
                                              : "2 days",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              ?.copyWith(color: Palette.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )),
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
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: _make ? Palette.primary : Palette.red,
                            side: BorderSide(
                                width: 2,
                                color: _make ? Palette.primary : Palette.red),
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
              )
            ],
          ),
        );
      }),
    );
  }
}
