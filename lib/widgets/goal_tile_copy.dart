import 'package:flutter/material.dart';

import '../Palette.dart';

class GoalTileCopy extends StatelessWidget {
  final String title;
  final String desc;
  final bool isGoal;
  final String milestoneNumber;
  final bool reminder;
  // final bool repeat;

  const GoalTileCopy(
      {Key? key,
      required this.title,
      required this.desc,
      required this.isGoal,
      required this.milestoneNumber,
      required this.reminder,
      // required this.repeat
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: 330,
        height: 69,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0x4d000000),
                  offset: Offset(1.2246467991473532e-16, 2),
                  blurRadius: 10,
                  spreadRadius: 0)
            ],
            color: Palette.primary),
        child: Stack(
          children: [
            Positioned(
                left: 14,
                top: 9,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline2,
                )),
            Positioned(
              left: 15,
              top: 36,
              child: Text(
                desc,
                style: const TextStyle(
                    color: Color(0xffbeffec),
                    fontSize: 13.5,
                    fontWeight: FontWeight.normal),
              ),
            ),
            Positioned(
                right: 13,
                top: 13,
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Palette.white,
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    GestureDetector(
                      child: Checkbox(
                        onChanged: (_) {},
                        activeColor: Palette.white,
                        checkColor: Palette.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: true,
                        side: BorderSide(width: 2, color: Palette.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        )),
                      ),
                    ),
                  ],
                )),
            Positioned(
                right: 24,
                top: 47.5,
                child: Row(
                  children: [
                    // Goal settings (repeat, goal, milestone)
                    Text(
                      isGoal ? "Goal" : "Milestone ${milestoneNumber}",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.normal,
                          color: Color(0xffbeffec)),
                    ),
                    // if (repeat) SizedBox(width: 10),
                    // if (repeat)
                      Icon(
                        Icons.replay,
                        color: Color(0xffbeffec),
                        size: 14,
                      ),
                    // if (reminder) SizedBox(width: 10),
                    // if (reminder)
                    //   Icon(
                    //     Icons.notifications_active_outlined,
                    //     color: Color(0xffbeffec),
                    //   ),
                  ],
                )),
          ],
        ));
  }
}
