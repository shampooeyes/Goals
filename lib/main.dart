import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygoals/models/goals.dart';
import 'package:mygoals/models/habits.dart';
import 'package:mygoals/screens/goals_screen.dart';

import 'package:provider/provider.dart';

import 'Palette.dart';
import 'models/history.dart';
import 'screens/new_goal_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoalList>(
          create: (_) => GoalList(),
        ),
        ChangeNotifierProvider<HabitList>(
          create: (_) => HabitList(),
        ),
        ChangeNotifierProvider<History>(
          create: (_) => History(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Goals',
        theme: ThemeData(
          backgroundColor: Palette.background,
          textTheme: TextTheme(
            headline1: TextStyle(
              // Habits and Goals
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: Palette.primary,
            ),
            headline2: TextStyle(
              // Goal tile header
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: Palette.white,
            ),
            bodyText1: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Palette.text,
            ),
            bodyText2: const TextStyle(
                color: Palette.white,
                fontWeight: FontWeight.w600,
                fontFamily: "OpenSans",
                fontSize: 13.0),
            button: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Palette.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            toolbarHeight: 56,
            titleTextStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              fontSize: 24,
            ),
            backgroundColor: Palette.secondary,
            systemOverlayStyle:
                SystemUiOverlayStyle(statusBarColor: Palette.status),
          ),
        ),
        routes: {
          "/": (ctx) => GoalsScreen(),
          NewGoalScreen.routeName: (ctx) => NewGoalScreen(),
        },
      ),
    );
  }
}
