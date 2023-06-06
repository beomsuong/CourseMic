import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/src/material/icons.dart';

class solve_quiz extends StatefulWidget {
  const solve_quiz({super.key});

  @override
  State<solve_quiz> createState() => _solve_quizState();
}

class _solve_quizState extends State<solve_quiz> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("순서 맞추기 Quiz"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          const Padding(
            //일단 만들어뒀음
            padding: EdgeInsets.symmetric(),
            child: Text('TOP'),
          ),
          const Expanded(
            //해당 요소가 꽉 차도록
            child: Text('Middle'),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check),
            label: const Text('제출'),
          )
        ],
      ),
    );
  }
}
