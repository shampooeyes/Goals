import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Palette.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final String desc;
  final List types;

  const GoalCard({
    required this.title,
    required this.desc,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: const Color(0x4d000000),
              offset: Offset(1.2246467991473532e-16, 2),
              blurRadius: 10,
              spreadRadius: 0)
        ],
        color: Palette.primary,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 12,
            top: 12,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Positioned(
            left: 15,
            bottom: 18.5,
            child: Text(
              desc,
              style: const TextStyle(
                  color: const Color(0xffbeffec),
                  fontFamily: "Poppins",
                  fontSize: 12.0),
            ),
          ),
          Positioned(
            child: Row(
              children: [
                GestureDetector(
                  child: SvgPicture.asset("assets/icons/drawable/edit.svg"),
                  onTap: () {}, // Edit Page
                ),
                GestureDetector(
                  child: SvgPicture.asset("assets/icons/drawable/round_checkbox.svg"),
                  onTap: () {}, // Complete Goal
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
