import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygoals/models/goals.dart';

import '/Palette.dart';

class NewMilestoneScreen extends StatefulWidget {
  static const routeName = "new_milestone_screen";
  final Function submit;
  final String goalKey;

  NewMilestoneScreen(this.submit, this.goalKey);

  @override
  _NewMilestoneScreenState createState() => _NewMilestoneScreenState();
}

class _NewMilestoneScreenState extends State<NewMilestoneScreen> {
  final _titleController = TextEditingController();
  DateTime _targetDate = DateTime.now();

  void _submit(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter milestone title"),
        backgroundColor: Palette.darkred,
        duration: Duration(seconds: 3),
      ));
    } else {
      widget.submit(Milestone(
          key: UniqueKey().toString(),
          parentKey: widget.goalKey.toString(),
          title: _titleController.text,
          enddate:
              DateTime(_targetDate.year, _targetDate.month, _targetDate.day)));
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          onTap: () => _submit(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 40),
            width: 220,
            height: 57,
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
                "ADD",
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text("New Milestone",
              style: Theme.of(context).appBarTheme.titleTextStyle),
        ),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 14.5, bottom: 5),
            child: Text(
              "Milestone Title",
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
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Text(
                    "Target Date",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                      onTap: () {
                        _selectDate(context);
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                        width: 110,
                        height: 27,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Palette.primary),
                        child: Row(children: [
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
                        ]),
                      ))
                ],
              ),
            ),
          ),
        ])));
  }
}
