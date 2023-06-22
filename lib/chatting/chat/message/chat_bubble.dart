import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'save_important_message.dart';
import 'package:capston/widgets/CircularContainer.dart';

class ChatBubbles extends StatefulWidget {
  const ChatBubbles(
    this.message,
    this.isMe,
    this.userid,
    this.userName,
    this.userImage,
    this.sendTime,
    this.roomID, {
    Key? key,
  }) : super(key: key);

  final String userid;
  final String message;
  final String userName;
  final bool isMe;
  final String userImage;
  final Timestamp sendTime;
  final String roomID;

  @override
  State<ChatBubbles> createState() => _ChatBubblesState();
}

class _ChatBubblesState extends State<ChatBubbles> {
  late FToast fToast = FToast();

  //double tap 처리용 변수들
  TapDownDetails? _doubleTapDetails;
  late Offset _reactButtonBarPosition = Offset.zero;
  bool _showReactButtonBar = false;

  //Overlay용 변수들
  OverlayEntry? _overlayEntry;
  OverlayEntry? _currentOverlayEntry;

  void _handleDoubleTap(TapDownDetails details) {
    print('Double Tapped on Position: ${_doubleTapDetails?.globalPosition}');
    setState(() {
      _doubleTapDetails = details;

      _reactButtonBarPosition = details.localPosition;
      _showReactButtonBar = true;

      _removeCurrentOverlayEntry(); // 이전의 오버레이 제거
      _currentOverlayEntry = _createOverlayEntry();
      Overlay.of(context)?.insert(_currentOverlayEntry!);
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position =
        renderBox.localToGlobal(_reactButtonBarPosition, ancestor: overlay);
    final overlayPosition = position - overlay.localToGlobal(Offset.zero);

    return OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned(
            left: overlayPosition.dx,
            top: overlayPosition.dy,
            child: const ReactButtonBar(),
          ),
        ],
      );
    });
  }

  void _removeOverlayEntry() {
    setState(() {
      _showReactButtonBar = false;
    });

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _removeCurrentOverlayEntry() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
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
    //메세지 보낸 시간 표시 위젯
    final EdgeInsets padding = widget.isMe
        ? const EdgeInsets.fromLTRB(0, 0, 5, 15)
        : const EdgeInsets.fromLTRB(5, 0, 0, 5);

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
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final BubbleType decideBubbleType =
        widget.isMe ? BubbleType.sendBubble : BubbleType.receiverBubble;
    final EdgeInsets padding = widget.isMe
        ? const EdgeInsets.fromLTRB(0, 5, 0, 0)
        : const EdgeInsets.fromLTRB(45, 5, 0, 0);
    final Color decideBckgndColor =
        widget.isMe ? const Color(0xFF8754f8) : const Color(0xffE7E7ED);
    final Color txtColor = widget.isMe ? Colors.white : Colors.black;

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
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          )
        ],
        Row(
          children: [
            Padding(
              padding: padding,
              child: ChatBubble(
                clipper: ChatBubbleClipper4(type: decideBubbleType),
                alignment: widget.isMe ? Alignment.topRight : Alignment.topLeft,
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
                        widget.message,
                        style: TextStyle(color: txtColor),
                      ),
                    ],
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
              )
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
        backgroundImage: NetworkImage(
          widget.userImage,
        ),
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
                // Navigator.pop(context);
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
              onPressed: () {
                print(widget.message);
                saveImportantMessage(
                  // 중요한 메세지 컬렉션에 저장
                  widget.message,
                  widget.message,
                  widget.sendTime,
                  widget.userName,
                  widget.roomID,
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
    return WillPopScope(
      onWillPop: () async {
        _removeOverlayEntry();
        return true;
      },
      child: GestureDetector(
        onLongPressStart: (LongPressStartDetails longPressStartDetails) =>
            showMsgFuncDialog(context), //메시지 longpress하면 트리거
        onDoubleTapDown: (TapDownDetails details) {
          _removeOverlayEntry();

          _removeCurrentOverlayEntry();
          _handleDoubleTap(details);
          print('메인 위젯 더블 탭 액션 수행 하는 곳');
        },
        onTap: () {
          _removeOverlayEntry();
          _removeCurrentOverlayEntry();
        },
        onVerticalDragUpdate: (details) {
          _removeOverlayEntry();

          _removeCurrentOverlayEntry();
        },
        child: Stack(
          children: [
            // 챗버블
            Row(
              mainAxisAlignment:
                  widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (widget.isMe) //! 나일 때
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      sendTimeDisplay(),
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
          ],
        ),
      ),
    );
  }
}

class ReactButtonBar extends StatelessWidget {
  const ReactButtonBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey, borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ButtonBar(
          children: [
            TextButton(
                onPressed: () {
                  print('버튼 바 버튼 터치됨');
                },
                child: const Text('👍')),
            TextButton(
                onPressed: () {
                  print('버튼 바 버튼 터치됨');
                },
                child: const Text('✔️')),
            TextButton(
                onPressed: () {
                  print('버튼 바 버튼 터치됨');
                },
                child: const Text('🤔')),
            TextButton(
                onPressed: () {
                  print('버튼 바 버튼 터치됨');
                },
                child: const Text('📌')),
            TextButton(
                onPressed: () {
                  print('버튼 바 버튼 터치됨');
                },
                child: const Text('🛠️')),
          ],
        ),
      ),
    );
  }
}
