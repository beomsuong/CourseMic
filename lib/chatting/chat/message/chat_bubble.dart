import 'dart:io';

import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'save_important_message.dart';

class ChatBubbles extends StatefulWidget {
  const ChatBubbles(
    this.type,
    this.message,
    this.isMe,
    this.userid,
    this.userName,
    this.userImage,
    this.sendTime,
    this.roomID,
    this.react,
    this.chatDataParent, {
    Key? key,
  }) : super(key: key);

  final LogType type;
  final String message;
  final bool isMe;
  final String userid;
  final String userName;
  final String userImage;
  final Timestamp sendTime;
  final String roomID;
  final Map<String, dynamic> react;
  final ChatScreenState chatDataParent;

  @override
  State<ChatBubbles> createState() => _ChatBubblesState();
}

final user = FirebaseAuth.instance.currentUser;

class _ChatBubblesState extends State<ChatBubbles> {
  late FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    fToast = FToast();
  }

  Future<void> doReactMsg(String uid, String react) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chat')
          .doc(widget.roomID)
          .collection('log') //내가 가리킨 채팅과 파이어베이스에서 찾으려는 채팅이
          .where('uid', isEqualTo: uid) //보낸 사람이 같고
          .where('content', isEqualTo: widget.message) //내용이 같고
          .where('sendTime', isEqualTo: widget.sendTime) //보낸 시간이 같으면
          .get();

      final DocumentSnapshot docSnapshot = querySnapshot.docs.first;
      final Map<String, dynamic> reactMap = docSnapshot.get('react') ?? {};

      if (querySnapshot.docs.isNotEmpty) {
        if (reactMap.containsKey(user!.uid) && reactMap[user!.uid] == react) {
          reactMap.remove(user!.uid);
          await docSnapshot.reference.update({'react': reactMap});
          print('메세지 반응 삭제 성공!');
        } else {
          reactMap[user!.uid] = react;
          await docSnapshot.reference.update({'react': reactMap});
          print('메세지 반응 저장 성공!');
        }
      }
    } catch (error) {
      print('메세지 반응 저장 실패!');
    }
  }

  Container showReactCount() {
    final Map<String, int> reactCount = {};
    widget.react.forEach((key, value) {
      reactCount[value] = (reactCount[value] ?? 0) + 1;
    });

    return Container(
      padding: widget.react.isEmpty ? null : const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Palette.darkGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: reactCount.entries.map((entry) {
            final emoji = _getEmoji(entry.key);
            final count = entry.value;

            return Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      emoji,
                      style: const TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 4),
                //const VerticalDivider(color: Colors.white, thickness: 1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getEmoji(String key) {
    switch (key) {
      case "good":
        return "👍";
      case "check":
        return "✔️";
      case "think":
        return "🤔";
      case "pin":
        return "📌";
      case "fix":
        return "🛠️";
      default:
        return "";
    }
  }

  Widget toast = Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 36),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: Palette.toastGray,
    ),
    child: const Text(
      "해당 채팅이 클립보드에 복사되었습니다",
      style: TextStyle(color: Colors.white),
    ),
  );

  String getFormattedTime() {
    //formatted 메세지 보낸 시간 변수
    final DateTime dateTime = widget.sendTime.toDate();
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  Widget sendTimeDisplay() {
    final EdgeInsets padding = widget.isMe
        ? const EdgeInsets.fromLTRB(0, 25, 5, 5)
        : const EdgeInsets.fromLTRB(5, 25, 0, 5);

    final EdgeInsets paddingWithReact = widget.react.isNotEmpty
        ? padding.copyWith(bottom: padding.top - 5)
        : padding;

    return Padding(
      padding: paddingWithReact,
      child: Text(
        getFormattedTime(),
        style: const TextStyle(fontSize: 11, color: Palette.darkGray),
      ),
    );
  }

  Widget showChatBubble(BuildContext context) {
    //isMe 조건으로 통합 위젯화
    final CrossAxisAlignment crossAxisAlignment =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final BubbleType decideBubbleType =
        widget.isMe ? BubbleType.sendBubble : BubbleType.receiverBubble;
    final EdgeInsets padding = widget.isMe
        ? const EdgeInsets.fromLTRB(0, 5, 0, 3)
        : const EdgeInsets.fromLTRB(45, 5, 0, 3);
    final Color decideBckgndColor =
        widget.isMe ? const Color(0xFF8754f8) : const Color(0xffE7E7ED);
    final Color txtColor = widget.isMe ? Colors.white : Colors.black;

    late Widget contentWidget;
    switch (widget.type) {
      case LogType.text:
        contentWidget = Text(
          widget.message,
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        );
        break;
      case LogType.image:
        contentWidget = ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            widget.message,
          ),
        );
        break;
      case LogType.file:
        String fileName = widget.message.split(" ")[0];
        String fileURL = widget.message.split(" ")[1];

        contentWidget = TextButton.icon(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white)),
          onPressed: () async {
            Directory appDir = await getApplicationDocumentsDirectory();
            File downloadTo = File("${appDir.path}/$fileName");
            print("${appDir.path}/$fileName");

            // await FirebaseStorage.instance
            //     .ref()
            //     .child("shared_file")
            //     .child(fileName)
            //     .writeToFile(downloadTo);

            // await FirebaseStorage.instance.refFromURL(fileURL).getData();
          },
          icon: const Icon(
            Icons.description_rounded,
          ),
          label: Text(fileName),
        );
        break;
      // 나중에 위로 올릴 예정
      case LogType.video:
      default:
        contentWidget = const Text("hello");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isMe) ...[
          //조건이 거짓이면 조건문의 리스트가 빈 리스트가 됨
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
            child: Text(
              widget.userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontSize: 12),
            ),
          )
        ],
        Row(
          children: [
            if (widget.isMe)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [sendTimeDisplay()],
              ),
            Padding(
              padding: padding,
              child: Container(
                margin:
                    EdgeInsets.only(bottom: widget.react.isNotEmpty ? 10 : 0),
                child: ChatBubble(
                  clipper: ChatBubbleClipper8(type: decideBubbleType),
                  alignment:
                      widget.isMe ? Alignment.topRight : Alignment.topLeft,
                  margin:
                      EdgeInsets.only(bottom: widget.react.isNotEmpty ? 10 : 0),
                  backGroundColor: decideBckgndColor,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                    ),
                    child: Column(
                      crossAxisAlignment: crossAxisAlignment,
                      children: [
                        contentWidget,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!widget.isMe)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  sendTimeDisplay(),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Positioned showProfileImage() {
    //본인 외의 유저만 프로필 사진 표시
    Widget profileImage = const SizedBox.shrink(); // 초기값 설정
    if (!widget.isMe) {
      profileImage = CircleAvatar(
        backgroundImage: NetworkImage(widget.userImage),
        radius: 18,
      );
    }
    return Positioned(
      top: 0,
      right: widget.isMe ? 5 : null,
      left: widget.isMe ? null : 5,
      child: profileImage,
    );
  }

  Future<dynamic> showMsgFuncDialog(BuildContext context) {
    return showDialog(
      // 메시지 액션 다이얼로그
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.01,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IgnorePointer(
                ignoring: widget.chatDataParent.chat.bEndProject,
                child: reactbuttonBar()),
            // dialogDivider(),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Profile(
                        userID: widget.userid,
                        bMyProfile: false,
                      );
                    },
                  ),
                );
              },
              child: const Text('프로필'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.message));
                Navigator.pop(context);
              },
              child: const Text('복사'),
            ),
            TextButton(
              onPressed: widget.chatDataParent.chat.bEndProject
                  ? null
                  : () {
                      saveImportantMessage(
                          // 중요한 메세지 컬렉션에 저장
                          widget.message,
                          widget.message,
                          widget.sendTime,
                          widget.userName,
                          widget.roomID);
                      Navigator.pop(context);
                    },
              child: const Text('중요메세지 설정'),
            ),
            dialogDivider(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GestureDetector(
        onLongPressStart: (LongPressStartDetails longPressStartDetails) =>
            showMsgFuncDialog(context), //메시지 longpress하면 트리거
        child: Column(
          children: [
            Stack(
              children: [
                // 챗버블
                Row(
                  mainAxisAlignment: widget.isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (widget.isMe) //! 나일 때
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          //sendTimeDisplay(),
                          showChatBubble(context),
                        ],
                      ),
                    if (!widget.isMe) //! 나 아니여~
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          showChatBubble(context),
                        ],
                      ),
                  ],
                ),
                showProfileImage(),
                Positioned(
                  bottom: 0,
                  left: widget.isMe ? null : 55,
                  right: widget.isMe ? 10 : null,
                  child: showReactCount(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget reactbuttonBar() {
    String? react;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Palette.darkGray,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(6),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.white))),
              onPressed: () {
                react = "good";
                doReactMsg(widget.userid, react!);
                Navigator.pop(context);
              },
              child: const Text('👍', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(6),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.white))),
              onPressed: () {
                react = "check";
                doReactMsg(widget.userid, react!);
                Navigator.pop(context);
              },
              child: const Text('✔️',
                  style: TextStyle(color: Colors.green, fontSize: 14)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(6),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.white))),
              onPressed: () {
                react = "think";
                doReactMsg(widget.userid, react!);
                Navigator.pop(context);
              },
              child: const Text('🤔', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(6),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.white))),
              onPressed: () {
                react = "pin";
                doReactMsg(widget.userid, react!);
                Navigator.pop(context);
              },
              child: const Text('📌', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(6),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.white))),
              onPressed: () {
                react = "fix";
                doReactMsg(widget.userid, react!);
                Navigator.pop(context);
              },
              child: const Text('🛠️', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
  //! end of chatbubble class
}

Divider dialogDivider() {
  return const Divider(
    height: 1,
    color: Palette.pastelBlack,
    indent: 30,
    endIndent: 30,
  );
}
