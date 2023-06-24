import 'dart:io';
import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_with_main_child/flex_with_main_child.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'save_important_message.dart';
import 'package:capston/chatting/chat/message/log.dart';

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
    this.readers,
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
  final List<String> readers;
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
    fToast.init(context);
  }

  showExpiredFileToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "만료된 파일입니다, 다운로드 받을 수 없습니다",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showExpiredImageToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "만료된 사진입니다, 사진 뷰어로 볼 수 없습니다",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showDownloadAlreadyToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "해당 파일이 이미 다운로드 폴더에 있습니다\n해당 파일을 열었습니다!",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showDownloadEndToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "파일이 다운로드가 완료되었습니다\n다운로드 폴더를 확인해주세요!",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
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

  Padding showReadersCount() {
    final List<String> localReadersList = widget.readers;
    final int unreadReadersCount =
        widget.chatDataParent.chat.userList.length - localReadersList.length;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.isMe ? 10 : 0,
        right: widget.isMe ? 0 : 10,
      ),
      child: Column(
        children: [
          Text(
            unreadReadersCount > 0 ? unreadReadersCount.toString() : '',
            style: const TextStyle(
              color: Palette.brightBlue,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Padding showReaderandSendtime() {
    const EdgeInsets padding = EdgeInsets.zero;

    final EdgeInsets paddingWithReact = widget.react.isNotEmpty
        ? padding.copyWith(bottom: padding.bottom + 20)
        : padding;

    return Padding(
      padding: paddingWithReact,
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: showReadersCount(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: sendTimeDisplay(),
          ),
        ],
      ),
    );
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
    return Padding(
      padding: EdgeInsets.zero,
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
        ValueNotifier<bool> bExpiredNotifier = ValueNotifier(false);
        contentWidget = ValueListenableBuilder(
            valueListenable: bExpiredNotifier,
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () async {
                  if (value) await showExpiredFileToast();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeroPhotoViewRouteWrapper(
                        roomName: widget.chatDataParent.chat.roomName,
                        userName:
                            widget.chatDataParent.userNameList[widget.userid] ??
                                "userName",
                        tag: widget.message,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 2.0,
                        imageURL: widget.message,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: widget.message,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      fit: BoxFit.cover,
                      widget.message,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: LinearProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        bExpiredNotifier.value = true;
                        return const Icon(
                          Icons.broken_image_rounded,
                        );
                      },
                    ),
                  ),
                ),
              );
            });
        break;
      case LogType.file:
        String fileName = widget.message.split(" ")[0];
        String fileURL = widget.message.split(" ")[1];
        ValueNotifier<double> percentageNotifier = ValueNotifier(1);
        GlobalKey textButtonKey = GlobalKey();

        contentWidget =
            ColumnWithMainChild(mainChildKey: textButtonKey, children: [
          TextButton.icon(
            key: textButtonKey,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              iconColor: txtColor,
            ),
            onPressed: () async {
              var status = await Permission.storage.status;
              if (!status.isGranted) {
                await Permission.storage.request();
                return;
              }

              percentageNotifier.value = 0;
              String downloadDirPath = "/storage/emulated/0/Download/";
              (await Directory(downloadDirPath).exists())
                  ? null
                  : downloadDirPath = "/storage/emulated/0/Downloads/";

              final path = "$downloadDirPath/$fileName";

              if (await Directory(path).exists()) {
                percentageNotifier.value = 1;
                await showDownloadAlreadyToast();
                OpenFile.open(path);
                return;
              }

              try {
                await Dio().download(fileURL, path,
                    onReceiveProgress: (received, total) {
                  percentageNotifier.value = (received / total);
                });
              } on DioException {
                await showExpiredFileToast();
                return;
              }

              showDownloadEndToast();
            },
            icon: const Icon(
              Icons.description_rounded,
            ),
            label: Text(fileName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: txtColor)),
          ),
          ValueListenableBuilder(
            valueListenable: percentageNotifier,
            builder: (context, value, child) => LinearProgressIndicator(
              color: txtColor,
              value: value,
            ),
          ),
        ]);
        break;
      // 나중에 위로 올릴 예정
      case LogType.video:
      default:
        contentWidget = const Text("This is Video");
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.isMe)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //! 이곳에 읽은 사람 수 표시
                  showReaderandSendtime(),
                ],
              ),
            Padding(
              padding: padding,
              child: Container(
                margin:
                    EdgeInsets.only(bottom: widget.react.isNotEmpty ? 10 : 0),
                child: ChatBubble(
                  clipper: ChatBubbleClipper8(
                    type: decideBubbleType,
                    radius: 15,
                  ),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //! 여기에 읽은 사람 수 표시
                  showReaderandSendtime(),
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

  Future<List<String>> getUserNames(List<String> readers) async {
    final List<String> userNames = [];

    for (String userID in readers) {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userID).get();

      if (docSnapshot.exists) {
        final userName = docSnapshot.get('name');
        userNames.add(userName);
      }
    }

    return userNames;
  }

  Widget showreadersDialog() {
    if (widget.readers.length > 1) {
      return FilledButton.tonalIcon(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => Palette.brightViolet,
          ),
        ),
        onPressed: () async {
          List<String> userNames = await getUserNames(widget.readers);
          showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: SizedBox(
                width: 100,
                height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: userNames
                              .map((userName) => Text(userName))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.done_all_sharp),
        label: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: //!
                    widget.readers.length.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Palette.lightGray,
                  fontSize: 18,
                ),
              ),
              const TextSpan(
                text: '명이 읽음',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
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
            showreadersDialog(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // 챗버블
            Row(
              mainAxisAlignment:
                  widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPressStart:
                      (LongPressStartDetails longPressStartDetails) =>
                          showMsgFuncDialog(context), //메시지 longpress하면 트리거,
                  child: showChatBubble(context),
                ),
              ],
            ),
            showProfileImage(),
            Positioned(
              bottom: 0,
              left: widget.isMe ? null : 55,
              right: widget.isMe ? 10 : null,
              child: showReactCount(),
            ),
          ],
        ),
      ],
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

class HeroPhotoViewRouteWrapper extends StatefulWidget {
  const HeroPhotoViewRouteWrapper(
      {super.key,
      required this.imageURL,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      required this.userName,
      required this.tag,
      required this.roomName});

  final String imageURL;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String tag;
  final String userName;
  final String roomName;

  @override
  State<HeroPhotoViewRouteWrapper> createState() =>
      _HeroPhotoViewRouteWrapperState();
}

class _HeroPhotoViewRouteWrapperState extends State<HeroPhotoViewRouteWrapper> {
  late FToast fToast;
  ValueNotifier<double> percentageNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PhotoView(
            imageProvider: NetworkImage(widget.imageURL),
            backgroundDecoration: widget.backgroundDecoration,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.tag),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
              child: Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: percentageNotifier,
                    builder: (context, value, child) => LinearProgressIndicator(
                      backgroundColor: Palette.darkGray,
                      color: Colors.white,
                      value: value,
                    ),
                  ),
                  const SizedBox(height: 15),
                  IconButton(
                    onPressed: () async {
                      var status = await Permission.photos.status;
                      if (!status.isGranted) {
                        await Permission.photos.request();
                      }

                      final tempDir = await getTemporaryDirectory();

                      final path =
                          "${tempDir.path}/${widget.imageURL.substring(widget.imageURL.length - 4, widget.imageURL.length)}.jpg";

                      try {
                        await Dio().download(widget.imageURL, path,
                            onReceiveProgress: (received, total) {
                          percentageNotifier.value = (received / total);
                        });
                      } on DioException {
                        await showExpiredImageToast();
                        return;
                      }

                      await GallerySaver.saveImage(
                          albumName: widget.roomName, path);

                      final file = File(path);
                      if (await file.exists()) file.delete();
                      await showDownloadEndToast();
                    },
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showExpiredImageToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "만료된 사진입니다, 다운로드 받을 수 없습니다",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showDownloadAlreadyToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text("해당 사진이 이미 갤러리에 있습니다",
              style: TextStyle(color: Colors.white)),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showDownloadEndToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "사진 다운로드가 완료되었습니다\n갤러리를 확인해주세요!",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }
}
