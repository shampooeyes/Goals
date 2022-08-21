import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygoals/models/goals.dart';
import 'package:mygoals/models/habits.dart';
import 'package:mygoals/screens/goals/goals_screen.dart';
import 'package:mygoals/screens/history/history_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:provider/provider.dart';

import 'Palette.dart';
import 'models/history.dart';
import 'screens/new_goal/new_goal_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    final appId = "bbdc8751-01db-4011-b5c6-79c78b349bd6";
    OneSignal.shared.setAppId(appId);
  }

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
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Goals',
        theme: ThemeData(
          backgroundColor: Palette.background,
          textSelectionTheme:
              TextSelectionThemeData(selectionHandleColor: Palette.primary),
          textTheme: TextTheme(
              headline1: const TextStyle(
                // Habits and Goals
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Palette.primary,
              ),
              headline2: const TextStyle(
                // Goal tile header
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Palette.white,
              ),
              bodyText1: const TextStyle(
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
              subtitle1: DefaultTextStyle.of(context)
                  .style
                  .copyWith(color: Palette.secondary, fontWeight: FontWeight.w500)),
          appBarTheme: const AppBarTheme(
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
          HistoryScreen.routeName: (ctx) => HistoryScreen(),
        },
      ),
    );
  }
}
