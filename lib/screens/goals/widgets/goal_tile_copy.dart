import 'package:flutter/material.dart';

import '../../../Palette.dart';

class GoalTileCopy extends StatelessWidget {
  final String title;
  final String desc;
  final bool isGoal;
  final String milestoneNumber;
  final bool reminder;
  final bool repeat;

  const GoalTileCopy({
    Key? key,
    required this.title,
    required this.desc,
    required this.isGoal,
    required this.milestoneNumber,
    required this.reminder,
    required this.repeat
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: const Color(0x4d000000),
                offset: Offset(1.2246467991473532e-16, 2),
                blurRadius: 6,
                spreadRadius: 0)
          ],
          color: Palette.primary),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 14, top: 9),
                constraints: BoxConstraints(maxWidth: 260),
                child: Wrap(children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(height: 1.3),
                  ),
                ]),
              ),
              if (desc.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 2, left: 14, bottom: 3),
                  constraints: BoxConstraints(maxWidth: 260),
                  child: Wrap(
                    children: [
                      Text(
                        desc,
                        style: const TextStyle(
                            color: Color(0xffbeffec),
                            fontSize: 13.5,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(
                    left: 14, top: 3, right: 10, bottom: 2),
                child: Row(
                  children: [
                    Text(
                      isGoal
                          ? "Goal"
                          : "Milestone $milestoneNumber",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.normal,
                          color: Color(0xffbeffec)),
                    ),
                    if (repeat) SizedBox(width: 10),
                    if (repeat)
                      Icon(
                        Icons.replay,
                        color: Color(0xffbeffec),
                        size: 14,
                      ),
                    if (reminder) SizedBox(width: 10),
                    if (reminder)
                      Icon(
                        Icons.notifications_active,
                        color: Color(0xffbeffec),
                        size: 14,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //actions
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Palette.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Checkbox(
                      activeColor: Palette.white,
                      checkColor: Palette.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: true,
                      side: BorderSide(width: 2, color: Palette.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                      onChanged: (value) {
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
