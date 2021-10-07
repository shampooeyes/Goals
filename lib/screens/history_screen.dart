import 'package:flutter/material.dart';
import 'package:mygoals/models/history.dart';
import 'package:mygoals/widgets/date_scroller.dart';
import 'package:mygoals/widgets/history_tile.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  static const routeName = "history-screen";
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 6, top: 10, right: 16, bottom: 10),
              child: Row(
                children: [
                  DateScroller(),
                ],
              ),
            ),
            Divider(
              endIndent: 25,
              indent: 25,
              thickness: 1,
              color: Color(0xffebcca5),
              height: 0,
            ),
            //History items filtered by datescroller
            Consumer<History>(builder: (ctx, snapshot, child) {
              List<HistoryItem> _items = snapshot.getHistory();
              return ListView.builder(
                itemCount: _items.length,
                itemBuilder: (ctx, index) {
                  return HistoryTile(
                    title: _items[index].title,
                    desc: _items[index].desc,
                    isGoal: _items[index].isGoal,
                    targetDate: _items[index].targetDate,
                    finishedDate: _items[index].targetDate,
                  );
                },
              );
            }),
            Divider(
              endIndent: 35,
              indent: 35,
              // color: Color(0xff97b1aa),
              thickness: 1,
              height: 0,
            )
          ],
        ),
      ),
    );
  }
}
