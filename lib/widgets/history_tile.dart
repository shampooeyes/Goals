import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygoals/Palette.dart';

class HistoryTile extends StatefulWidget {
  final String title;
  final String desc;
  final bool isGoal;
  final DateTime targetDate;
  final DateTime finishedDate;

  HistoryTile({
    Key? key,
    required this.title,
    required this.desc,
    required this.isGoal,
    required this.targetDate,
    required this.finishedDate,
  }) : super(key: key);

  @override
  _HistoryTileState createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          "${widget.isGoal ? "Goal" : "Milestone"} - ${widget.title}",
          style: const TextStyle(color: Palette.primary, fontSize: 18),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(left: 8, top: 5),
          child: Wrap(children: [
            Text(
              widget.desc,
              style: const TextStyle(
                fontSize: 16,
                color: Palette.primary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ]),
        ),
        tilePadding: const EdgeInsets.only(left: 20, right: 30, top: 5),
        trailing: Text(
          DateFormat("dd MMM yyyy").format(widget.finishedDate),
          style: const TextStyle(color: Color(0xff97b1aa)),
        ),

        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 7, right: 30),
                alignment: Alignment.bottomRight,
                child: Text(
                  "Target Date: ${DateFormat("dd MMM yyyy").format(widget.targetDate)}",
                  style: const TextStyle(
                      color: const Color(0xff97b1aa),
                      fontWeight: FontWeight.w400),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: .7,
                          child: Container(
                            color: Color(0xff97b1aa),
                          ),
                        ),
                        IconButton(
                          onPressed: () {}, // share
                          icon: Icon(
                            Icons.share,
                            color: Color(0xff97b1aa),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    width: 1,
                    child: Container(color: Color(0xff97b1aa)),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 15),
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: .7,
                          child: Container(
                            color: Color(0xff97b1aa),
                          ),
                        ),
                        IconButton(
                          onPressed: () {}, // delete
                          icon: Icon(
                            Icons.delete,
                            color: Color(0xff97b1aa),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          )
        ], // when tile expands
      ),
    );
  }
}
