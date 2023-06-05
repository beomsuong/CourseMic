// import 'package:capston/chatting/chat/view_important_message.dart';
// import 'package:flutter/material.dart';

// class ChatPlusFunc extends StatelessWidget {
//   final String roomId;

//   const ChatPlusFunc({Key? key, required this.roomId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 282,
//       color: Colors.grey,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 ElevatedButton(
//                   onPressed: () {
//                     print('자료 조회 or 보내기');
//                   },
//                   child: const Text('자료'),
//                 ),
//                 Padding(padding: EdgeInsets.all(10.0)),
//                 ElevatedButton(
//                   onPressed: () {
//                     print('Todo리스트 조회');
//                   },
//                   child: const Text('Todo'),
//                 ),
//                 Padding(padding: EdgeInsets.all(10.0)),
//                 ElevatedButton(
//                   onPressed: () {
//                     print('중요한 메세지? 모아보기');

//                     //이곳에 심플뷰

//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) =>
//                     //         ImportantMessagesPage(roomname: roomId),
//                     //   ),
//                     // );
//                   },
//                   child: const Text('중요한 일'),
//                 ),
//                 Padding(padding: EdgeInsets.all(10.0)),
//                 ElevatedButton(
//                   onPressed: () {
//                     print('참여도 조회 창 예정 :)');
//                   },
//                   child: const Text('참여도'),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Container(
//                 //컨테이너 사이즈 확인
//                 color: Colors.amber,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//                                      *OLD CODE*

import 'package:capston/chatting/chat/view_important_message.dart';
import 'package:capston/message/addmessage.dart';
import 'package:flutter/material.dart';

class ChatPlusFunc extends StatefulWidget {
  final String roomId;

  const ChatPlusFunc({Key? key, required this.roomId}) : super(key: key);

  @override
  _ChatPlusFuncState createState() => _ChatPlusFuncState();
}

class _ChatPlusFuncState extends State<ChatPlusFunc> {
  String currentFunction = '';
  Widget? dynamicWidget;

  void setFunction(String function) {
    //setState로 미리보기 창 제어. 각 위젯 명은 가칭이니, 변경 가능
    setState(() {
      currentFunction = function;
      if (function == '자료 조회 or 보내기') {
        dynamicWidget = const DataWidget();
      } else if (function == 'Todo리스트 조회') {
        dynamicWidget = const TodoListWidget();
      } else if (function == '중요한 메세지? 모아보기') {
        dynamicWidget = SimpleImportantMessage(
          roomname: widget.roomId,
        );
      } else if (function == '참여도 점수 보기') {
        dynamicWidget = const ParticipationWidget();
      } else {
        dynamicWidget = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 282,
      color: Colors.grey,
      child: Center(
        child: Column(
          //버튼 리스트 칼럼
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setFunction('자료 조회 or 보내기');
                  },
                  child: const Text('자료'),
                ),
                const Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                  onPressed: () {
                    setFunction('Todo리스트 조회');
                  },
                  child: const Text('Todo'),
                ),
                const Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                  onPressed: () {
                    setFunction('중요한 메세지? 모아보기');
                  },
                  child: const Text('중요한 일'),
                ),
                const Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                  onPressed: () {
                    setFunction('참여도 점수 보기');
                  },
                  child: const Text('참여도'),
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.amber,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: dynamicWidget ??
                      const Text(
                        'No widget selected',
                        style: TextStyle(fontSize: 24),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataWidget extends StatelessWidget {
  const DataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Data Widget');
  }
}

class TodoListWidget extends StatelessWidget {
  const TodoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Todo List Widget');
  }
}

class ImportantMessagesWidget extends StatelessWidget {
  //중요한 메시지 보기
  const ImportantMessagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleImportantMessage(
      roomname: roomname,
    );
  }
}

class ParticipationWidget extends StatelessWidget {
  const ParticipationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Participation score Widget');
  }
}
