import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygoals/Palette.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/history.dart';

class HistoryCard extends StatelessWidget {
  final String itemKey;
  final String title;
  final String desc;
  final bool isGoal;
  final DateTime targetDate;
  final DateTime finishedDate;

  HistoryCard({
    required this.itemKey,
    required this.title,
    required this.desc,
    required this.isGoal,
    required this.targetDate,
    required this.finishedDate,
  });

  @override
  Widget build(BuildContext context) {
    void confirmDelete() {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text("Are you sure?"),
                // content: Text("Delete \"$title\""),
                actions: [
                  TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.subtitle1,
                      )),
                  TextButton(
                      onPressed: () {
                        Provider.of<History>(context, listen: false)
                            .removeItem(itemKey);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "OK",
                        style: Theme.of(context).textTheme.subtitle1,
                      ))
                ],
              ));
    }

    void _showInfoDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: 
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                actions: [TextButton(
                    onPressed: () {
                      Share.share(
                          "Look what I accomplished!\n•$title\n\nKeep track of your goals with this app!\nhttps://play.google.com/store/apps/details?id=com.kareemelkadery.mygoals");
                    },
                    child: Text(
                      "SHARE",
                      style: Theme.of(context).textTheme.subtitle1,
                    )),
                TextButton(
                    onPressed: confirmDelete,
                    child: Text("DELETE",
                        style: Theme.of(context).textTheme.subtitle1)),
                ],
            );
          });
    }

    return Container(
      height: 70,
      child: Card(
        color: Palette.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showInfoDialog();
          },
          child: Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Text(
                  isGoal ? "Goal - $title" : "Milestone - $title",
                  style: const TextStyle(color: Palette.primary, fontSize: 16),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(DateFormat("dd MMM yyyy").format(finishedDate),
                  style: const TextStyle(color: Color(0xff97b1aa))),
              SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
