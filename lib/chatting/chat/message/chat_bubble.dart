import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'save_important_message.dart';

class ChatBubbles extends StatelessWidget {
  ChatBubbles(this.message, this.isMe, this.userid, this.userName,
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

  late FToast fToast = FToast();
  Widget toast = Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 36),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: Palette.toastGray,
    ),
    child: const Text("해당 채팅이 클립보드에 복사되었습니다",
        style: TextStyle(color: Colors.white)),
  );

  String getFormattedTime() {
    final DateTime dateTime = sendTime.toDate();
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

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
                                return Profile(
                                  userID: userid,
                                  bMyProfile: false,
                                );
                              },
                            ),
                          );
                          //Navigator.pop(context);
                        },
                        child: const Text('프로필'),
                      ),
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: message));
                          Navigator.pop(context);
                        },
                        child: const Text('복사'),
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      //   child: const Text('답장'), // 구현 미정
                      // ),
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
                        child: const Text('중요메세지 설정'),
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
            if (isMe) //! 나일 때
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        getFormattedTime(),
                        style: const TextStyle(
                            fontSize: 10, color: Palette.darkGray),
                      ),
                    ],
                  ),
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
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
                ],
              ),
            if (!isMe)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(45, 10, 0, 0),
                    child: ChatBubble(
                      clipper:
                          ChatBubbleClipper8(type: BubbleType.receiverBubble),
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
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        getFormattedTime(),
                        style: const TextStyle(
                            fontSize: 10, color: Palette.darkGray),
                      ),
                    ],
                  ),
                ],
              )
          ],
        ),
        Positioned(
          top: 0,
          right: isMe ? 5 : null,
          left: isMe ? null : 5,
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              userImage,
            ),
          ),
        ),
      ]),
    );
  }
}
