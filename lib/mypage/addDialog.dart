import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  final String university, major, mbti, contacttime;
  AddDialog({
    Key? key,
    required this.university,
    required this.major,
    required this.mbti,
    required this.contacttime,
  }) : super(key: key);

  @override
  State<AddDialog> createState() => _AddDialog1State();
}

//요일을 int로 변환하기 위한 map
class _AddDialog1State extends State<AddDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('수정'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Row(children: [Text(widget.university), Text(widget.university)]),
            Text(widget.major),
            Text(widget.mbti),
            Text(widget.contacttime),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
