import 'package:capston/chatting/chat/viewuserprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'save_important_message.dart';

class ChatBubbles extends StatelessWidget {
  const ChatBubbles(this.message, this.isMe, this.userid, this.userName,
      this.userImage, this.sendTime, this.roomID,
      {Key? key})
      : super(key: key);
  final String userid;
  final String message;
  final String userName;
  final bool isMe;
  final String userImage;
  final Timestamp sendTime;
  final String roomID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails longPressStartDetails) => {
        //메시지 longpress하면 트리거
        showDialog(
          // 메시지 액션 다이얼로그
          context: context,
          builder: (BuildContext context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('메시지 액션 메뉴'),
                  const SizedBox(height: 15), //공백용. 나중에 처리
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Viewuserprofile(userid: userid);
                              },
                            ),
                          );
                          //Navigator.pop(context);
                        },
                        child: const Text('프로필'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('복사'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('답장'), // 구현 미정
                      ),
                      TextButton(
                        onPressed: () {
                          print(message);
                          saveImportantMessage(
                            //중요한 메세지 컬렉션에 저장
                            message,
                            message,
                            sendTime,
                            userName,
                            roomID,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('> !중요! <'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      },
      child: Stack(children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isMe)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 45, 0),
                child: ChatBubble(
                  clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(bottom: 10),
                  backGroundColor: const Color(0xFF8754f8),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (!isMe)
              Padding(
                padding: const EdgeInsets.fromLTRB(45, 10, 0, 0),
                child: ChatBubble(
                  clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                  backGroundColor: const Color(0xffE7E7ED),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
        Positioned(
          top: 0,
          right: isMe ? 5 : null,
          left: isMe ? null : 5,
          child: CircleAvatar(
            backgroundImage: NetworkImage(userImage),
          ),
        ),
      ]),
    );
  }
}
