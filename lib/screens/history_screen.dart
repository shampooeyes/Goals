import 'package:flutter/material.dart';
import 'package:mygoals/models/history.dart';
import 'package:mygoals/widgets/date_scroller.dart';
import 'package:mygoals/widgets/history_tile.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = "history-screen";
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime filterDate = DateTime.now();

  void _changePeriod(DateTime date) {
    setState(() {
      filterDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context);
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
                  DateScroller(_changePeriod, filterDate),
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
              List<HistoryItem> _items = snapshot.getHistory(filterDate);
              return Container(
                height: device.size.height -
                    device.viewPadding.bottom -
                    device.viewPadding.top -
                    128,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (ctx, index) {
                    return HistoryTile(
                      itemKey: _items[index].key,
                      title: _items[index].title,
                      desc: _items[index].desc,
                      isGoal: _items[index].isGoal,
                      targetDate: _items[index].targetDate,
                      finishedDate: _items[index].targetDate,
                    );
                  },
                ),
              );
            }),
            Divider(
              endIndent: 35,
              indent: 35,
              color: Color(0xff97b1aa).withOpacity(0.6),
              thickness: 0.5,
              height: 0,
            )
          ],
        ),
      ),
    );
  }
}
