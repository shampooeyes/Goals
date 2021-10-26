import 'package:flutter/material.dart';
import 'package:mygoals/models/habits.dart';

import '../Palette.dart';

class HabitDetailsScreen extends StatelessWidget {
  final Habit habit;

  HabitDetailsScreen(this.habit);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title,
            style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete,
              size: 24,
            ),
          )
        ],
      ),
    );
  }
}
