import 'package:flutter/material.dart';
import 'package:mygoals/models/habits.dart';

import '../../../Palette.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;

  const HabitTile(this.habit);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      width: 160,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: habit.make ? Palette.primary : Palette.red,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: const Color(0x26000000),
                offset: Offset(1.2246467991473532e-16, 2),
                blurRadius: 4,
                spreadRadius: 0)
          ],
          color: Palette.white),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 10,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(bottom: 3),
              child: Wrap(
                children: [
                  Text(
                    habit.title,
                    style: TextStyle(
                        color:
                            habit.make ? Color(0xff00564b) : Color(0xff4b0000),
                        fontWeight: FontWeight.w600,
                        fontFamily: "OpenSans",
                        fontStyle: FontStyle.normal,
                        fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 6,
              left: 27,
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        "${habit.currentStreak}",
                        style: TextStyle(
                            color: habit.make
                                ? Color(0xff06382a)
                                : Color(0xff4b0000),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 17.0),
                      ),
                      Text(
                        "CURRENT\nSTREAK",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.3,
                            color: habit.make
                                ? Color(0xff06382a)
                                : Color(0xff4b0000),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 8.0),
                      ),
                    ],
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Text(
                        "${habit.bestStreak}",
                        style: TextStyle(
                            color: habit.make
                                ? Color(0xff06382a)
                                : Color(0xff4b0000),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 17.0),
                      ),
                      Text(
                        "BEST\nSTREAK",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.3,
                            color: habit.make
                                ? Color(0xff06382a)
                                : Color(0xff4b0000),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            fontStyle: FontStyle.normal,
                            fontSize: 8.0),
                      ),
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
