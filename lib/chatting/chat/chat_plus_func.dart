import 'package:capston/chatting/chat/view_important_message.dart';
import 'package:flutter/material.dart';

class ChatPlusFunc extends StatelessWidget {
  final String roomId;

  const ChatPlusFunc({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 282,
      color: Colors.grey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    print('자료 조회 or 보내기');
                  },
                  child: const Text('자료'),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                  onPressed: () {
                    print('Todo리스트 조회');
                  },
                  child: const Text('Todo'),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                  onPressed: () {
                    print('중요한 메세지? 모아보기');
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         ImportantMessagesPage(),
                    //   ),
                    // );
                  },
                  child: const Text('중요한 일'),
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                ElevatedButton(
                  onPressed: () {
                    print('참여도 조회 창 예정 :)');
                  },
                  child: const Text('참여도'),
                ),
              ],
            ),
            Expanded(
              child: Container(
                //컨테이너 사이즈 확인
                color: Colors.amber,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
