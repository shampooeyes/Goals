import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Palette.dart';

// ignore: must_be_immutable
class DateChip extends StatelessWidget {
  String title;
  final bool isSelected;

  DateChip(this.title, this.isSelected);

  @override
  Widget build(BuildContext context) {
    bool tomorrow = false;
    if (title == DateFormat("d MMM").format(DateTime.now()).toUpperCase())
      title = "TODAY";
    else if (title ==
        DateFormat("d MMM")
            .format(DateTime.now().add(Duration(days: 1)))
            .toUpperCase()) {
      title = "TOMORROW";
      tomorrow = true;
    }

    return Container(
      width: tomorrow ? 84 : 56,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              color: isSelected ? Palette.white : Palette.primary,
              fontWeight: FontWeight.w500,
              fontFamily: "Poppins",
              fontSize: 10.5),
        ),
      ),
    );
  }
}
