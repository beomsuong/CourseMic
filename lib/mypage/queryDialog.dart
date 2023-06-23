// ignore_for_file: non_constant_identifier_names

import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:capston/widgets/RoundButtonStyle.dart';
import 'package:flutter/material.dart';

class QueryDialog extends StatefulWidget {
  final ProfileState myPageState;

  const QueryDialog({
    Key? key,
    required this.myPageState,
  }) : super(key: key);
  @override
  State<QueryDialog> createState() => _AddDialog1State();
}

class _AddDialog1State extends State<QueryDialog> {
  ButtonStyle brightBlueButtonStyle = colorButtonStyle(Palette.brightBlue);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Palette.brightBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "완료한 과제 조회 (${widget.myPageState.myUser.doneProject.length})",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20)),
                IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    icon: const Icon(Icons.remove_circle_outline_rounded))
              ],
            ),
          ),
          widget.myPageState.myUser.doneProject.isEmpty
              ? const SizedBox(
                  height: 100,
                  child: Center(
                      child: Text("완료한 과제가 없습니다",
                          style: TextStyle(color: Palette.darkGray))))
              : SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      const SizedBox(
                        height: 11,
                      ),
                      for (int index = 0;
                          index < widget.myPageState.myUser.doneProject.length;
                          index++)
                        Column(
                          children: [
                            Text(
                              widget.myPageState.myUser.doneProject[index],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            index !=
                                    widget.myPageState.myUser.doneProject
                                            .length -
                                        1
                                ? const Padding(
                                    padding: EdgeInsets.fromLTRB(14, 9, 14, 9),
                                    child: Divider(
                                      color: Palette.brightBlue,
                                      thickness: 1.5,
                                    ),
                                  )
                                : const SizedBox(height: 15),
                          ],
                        )
                    ]),
                  ),
                ),
        ],
      ),
    );
  }
}
