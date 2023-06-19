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
    //formatted 메세지 보낸 시간 변수
    final DateTime dateTime = sendTime.toDate();
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  Widget sendTimeDisplay() {
    //메세지 보낸 시간 표시 위젯
    final EdgeInsets padding = isMe
        ? const EdgeInsets.fromLTRB(0, 0, 5, 15)
        : const EdgeInsets.fromLTRB(5, 0, 0, 15);

    return Padding(
      padding: padding,
      child: Text(
        getFormattedTime(),
        style: const TextStyle(fontSize: 13, color: Palette.darkGray),
      ),
    );
  }

  Widget showChatBubble(BuildContext context) {
    //isMe 조건으로 통합 위젯화
    final CrossAxisAlignment crossAxisAlignment =
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final BubbleType decideBubbleType =
        isMe ? BubbleType.sendBubble : BubbleType.receiverBubble;
    final EdgeInsets padding = isMe
        ? const EdgeInsets.fromLTRB(0, 5, 0, 0)
        : const EdgeInsets.fromLTRB(45, 5, 0, 0);
    final Color decideBckgndColor =
        isMe ? const Color(0xFF8754f8) : const Color(0xffE7E7ED);
    final Color txtColor = isMe ? Colors.white : Colors.black;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe) ...[
          //조건이 거짓이면 조건문의 리스트가 빈 리스트가 됨
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
            child: Text(
              userName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          )
        ],
        Padding(
          padding: padding,
          child: ChatBubble(
            clipper: ChatBubbleClipper4(type: decideBubbleType),
            alignment: isMe ? Alignment.topRight : Alignment.topLeft,
            margin: const EdgeInsets.only(bottom: 10),
            backGroundColor: decideBckgndColor,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: txtColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Positioned showProfileImage() {
    //본인 외의 유저만 프로필 사진 표시
    Widget profileImage = const SizedBox.shrink(); // 초기값 설정
    if (!isMe) {
      profileImage = CircleAvatar(
        backgroundImage: NetworkImage(
          userImage,
        ),
      );
    }
    return Positioned(
      top: 0,
      right: isMe ? 5 : null,
      left: isMe ? null : 5,
      child: profileImage,
    );
  }

  Future<dynamic> showMsgFuncDialog(BuildContext context) {
    return showDialog(
      // 메시지 액션 다이얼로그
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
          horizontal: MediaQuery.of(context).size.width * 0.1,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('메시지 액션 메뉴'),
            const SizedBox(height: 15), // 공백용. 나중에 처리
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ButtonBar(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_down),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.question_mark),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.handyman),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.check_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.watch_later_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.smart_toy_outlined),
                  ),
                ],
              ),
            ),
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
                // Navigator.pop(context);
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
            TextButton(
              onPressed: () {
                print(message);
                saveImportantMessage(
                  // 중요한 메세지 컬렉션에 저장
                  message,
                  message,
                  sendTime,
                  userName,
                  roomID,
                );
                Navigator.pop(context);
              },
              child: const Text('중요메세지 설정'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails longPressStartDetails) => {
        //메시지 longpress하면 트리거
        showMsgFuncDialog(context),
      },
      child: Stack(children: [
        // 챗버블
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isMe) //! 나일 때
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  sendTimeDisplay(),
                  showChatBubble(context),
                ],
              ),
            if (!isMe) //! 나 아니여~
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  showChatBubble(context),
                  sendTimeDisplay(),
                ],
              )
          ],
        ),
        showProfileImage(),
      ]),
    );
  }
}
