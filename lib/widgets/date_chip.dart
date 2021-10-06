import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Palette.dart';

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
      height: 30,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          border: Border.all(color: Palette.primary, width: 1.5),
          color: isSelected ? Palette.primary : Palette.background,
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                  color: Color(0xff42ad9f), spreadRadius: 0.5, blurRadius: 3)
          ]),
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
