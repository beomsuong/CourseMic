import 'package:flutter/material.dart';

import '../../widgets/GradientText.dart';

class Meetinglist extends StatefulWidget {
  const Meetinglist({super.key});

  @override
  State<Meetinglist> createState() => _MeetinglistState();
}

class _MeetinglistState extends State<Meetinglist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GradientText(text: "회의록"),
        centerTitle: false,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: const Column(
        children: [
          SizedBox(
            child: Text('123'),
          )
        ],
      ),
    );
  }
}
