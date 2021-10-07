import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Palette.dart';

class DateScroller extends StatefulWidget {
  DateScroller({Key? key}) : super(key: key);

  @override
  _DateScrollerState createState() => _DateScrollerState();
}

class _DateScrollerState extends State<DateScroller> {
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          splashRadius: 15,
          onPressed: () {
            setState(() {
              date = date.subtract(Duration(days: 30));
            });
          },
          icon: Icon(
            CupertinoIcons.back,
            color: Palette.secondary,
          ),
        ),
        Text(
          DateFormat("MMM yyyy").format(date),
          style: const TextStyle(
            color: Palette.secondary,
            fontFamily: "Poppins",
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
        IconButton(
          splashRadius: 15,
          onPressed: () {
            setState(() {
              date = date.add(Duration(days: 30));
            });
          },
          icon: Icon(
            CupertinoIcons.forward,
            color: Palette.secondary,
          ),
        ),
      ],
    );
  }
}
