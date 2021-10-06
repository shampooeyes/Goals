import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Palette.dart';

class RepeatWidget extends StatefulWidget {

  @override
  _RepeatWidgetState createState() => _RepeatWidgetState();
}

class _RepeatWidgetState extends State<RepeatWidget> {
  final _repeatController = TextEditingController();
  bool _repeater = false;
  String _repeatPeriod = "days";
  String _repeatText = "";

  Future _selectRepeat(BuildContext context) { //Push to different widget
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
                          setState(() {
                            _repeater = true;
                            _repeatText =
                                _tempController.text + " " + _repeatPeriod;
                            _repeatController.text = _tempController.text;
                          });
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
                            setState(() {
                              _repeatPeriod = "weeks";
                              _repeater = true;
                            });
                            break;
                          case "months":
                            setState(() {
                              _repeatPeriod = "months";
                            });
                            break;
                          default:
                            setState(() {
                              _repeatPeriod = "days";
                            });
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
                                  onTap: () {
                                    _selectRepeat(context);
                                    if (_repeatController.text.isEmpty) {
                                      setState(() => _repeater = false);
                                    }
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 27,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        color: _repeater
                                            ? Palette.primary
                                            : Palette.milestone),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              ? _repeatText
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
                            );
  }
}