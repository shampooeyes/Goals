import 'package:flutter/material.dart';
import 'package:mygoals/models/goals.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../Palette.dart';
import '../new_milestone/new_milestone_screen.dart';

class EditGoalScreen extends StatefulWidget {
  static const routeName = "edit-goal-screen";
  final String goalKey;

  EditGoalScreen(this.goalKey);

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
  TimeOfDay _selectedTime = TimeOfDay(hour: 12, minute: 0);

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

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  void _addMilestone(Milestone milestone) {
    setState(() {
      _milestones.add(milestone);
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null)
      currentFocus.unfocus();
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

  void _submitGoal(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null)
      currentFocus.unfocus();
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter goal title"),
        backgroundColor: Palette.darkred,
        duration: Duration(seconds: 3),
      ));
      return;
    }
    if (_reminder) {
      if (goal.reminder) {
        String appId = "bbdc8751-01db-4011-b5c6-79c78b349bd6";
        http.delete(Uri.parse(
            "https://onesignal.com/api/v1/notifications/${goal.notificationId}?app_id=$appId"));
      }

      final date = DateTime(_targetDate.year, _targetDate.month,
          _targetDate.day, _selectedTime.hour, _selectedTime.minute);

      final OSDeviceState? status = await OneSignal.shared.getDeviceState();
      if (status != null) {
        final playerId = status.userId;
        await OneSignal.shared.postNotificationWithJson({
          "app_id": "bbdc8751-01db-4011-b5c6-79c78b349bd6",
          "include_player_ids": [playerId],
          "contents": {"en": "Reminder: ${_titleController.text.trim()}"},
          "delayed_option": "timezone",
          "delivery_time_of_day": date.toIso8601String(),
          "android_channel_id": "16de5e7e-7580-4500-b445-6a18917bd6e5",
        });
      }
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
      notificationId: "",
    ));
    Navigator.of(context).pop();
  }

  void _selectTime(BuildContext context) async {
    final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) => Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                      primary: Palette.secondary,
                      onSurface: Palette.secondary.withOpacity(0.7),
                      onBackground: Palette.secondary.withOpacity(0.1))),
              child: child!,
            ));
    if (time == null) {
      return;
    } else {
      setState(() {
        if (!_reminder) _reminder = true;
        _selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null)
          currentFocus.unfocus();
        await Future.delayed(Duration(milliseconds: 80), () {});
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: GestureDetector(
            onTap: () => _submitGoal(context),
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
                  color: Palette.primary),
              child: Center(
                child: Text(
                  "SAVE",
                  style: Palette.buttonTheme,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
                  child: Text(
                    "Goal Title",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 15.5, right: 15.5),
                    // width: 360,
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
                    child: Stack(
                      children: [
                        Positioned(
                          left: 10,
                          bottom: -4.5,
                          child: Container(
                            width: 300,
                            child: TextField(
                              controller: _titleController,
                              maxLength: 50,
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
                          ),
                        ),
                      ],
                    )),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
                  child: Text(
                    "Goal Description",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 15.5, right: 15.5),
                    // width: 360,
                    height: 60,
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
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _descController,
                        keyboardType: TextInputType.multiline,
                        maxLength: 100,
                        maxLines: 2,
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
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
                  child: Text(
                    "Milestones",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(
                  width: 375.5,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      return Container(
                        margin: const EdgeInsets.only(
                            left: 15.5, bottom: 7.5, right: 15.5),
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
                ),
                GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus &&
                        currentFocus.focusedChild != null)
                      currentFocus.unfocus();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) =>
                            NewMilestoneScreen(_addMilestone, widget.goalKey)));
                  },
                  child: Container(
                      margin: const EdgeInsets.only(left: 15.5, right: 15.5),
                      // width: 360,
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
                          child: Icon(
                            CupertinoIcons.add,
                            color: Palette.white,
                            size: 34,
                          ),
                        ),
                      ])),
                ),
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
                              width: 115,
                              height: 27,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  color: Palette.primary),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat("dd/MM/yyyy")
                                        .format(_targetDate),
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
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
                      // SizedBox(
                      //   width: 50,
                      // ),
                      // Column(
                      //   children: [
                      //     Text(
                      //       "Repeat",
                      //       style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      //           color:
                      //               _repeater ? Palette.text : Color(0xff989898)),
                      //     ),
                      //     SizedBox(height: 5),
                      //     GestureDetector(
                      //       onTap: () async {
                      //         await _selectRepeat(context);
                      //         Future.delayed(Duration(milliseconds: 1))
                      //             .then((value) => setState(() {}));
                      //         if (_repeatController.text.isEmpty) {
                      //           setState(() => _repeater = false);
                      //         }
                      //       },
                      //       child: Container(
                      //         width: 100,
                      //         height: 27,
                      //         decoration: BoxDecoration(
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(8)),
                      //             color: _repeater
                      //                 ? Palette.primary
                      //                 : Palette.milestone),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Icon(
                      //               CupertinoIcons.restart,
                      //               color: _repeater
                      //                   ? Palette.white
                      //                   : Color(0xff989898),
                      //               size: 13,
                      //             ),
                      //             SizedBox(width: 6),
                      //             Text(
                      //               _repeater
                      //                   ? _repeatController.text +
                      //                       " " +
                      //                       _repeatPeriod
                      //                   : "2 days",
                      //               style: Theme.of(context)
                      //                   .textTheme
                      //                   .bodyText2
                      //                   ?.copyWith(
                      //                       color: _repeater
                      //                           ? Palette.white
                      //                           : Color(0xff989898)),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     )
                      //   ],
                      // ),
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: Palette.primary,
                          side: BorderSide(width: 2, color: Palette.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                            Radius.circular(4.5),
                          )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectTime(context);
                        },
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
                            "${_selectedTime.format(context)}",
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
                    ]),
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
