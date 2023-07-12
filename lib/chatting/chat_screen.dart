import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/chatting/modify_role.dart';
import 'package:capston/mypage/profile.dart';
import 'package:capston/notification.dart';
import 'package:capston/palette.dart';
import 'package:capston/quiz/solve_quiz.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/new_message.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';

class ChatScreen extends StatefulWidget {
  final String roomID; //체팅방 고유 ID
  final String roomName; //체팅방 이름

  const ChatScreen({
    Key? key,
    required this.roomID,
    required this.roomName,
  }) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final DocumentReference chatDocRef;
  late Chat chat;
  Map<String, String> userNameList = {};

  late final DocumentReference userDocRef;
  late final User currentUser;
  List<dynamic> userChatList = List<String>.empty(growable: true);

  late final CollectionReference toDoColRef;
  late Stream<QuerySnapshot<Object?>> progressPercentStream;
  late Stream<DocumentSnapshot<Object?>> chatStream;

  late final String roomCode;

  GlobalKey<NewMessageState> newMessageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    currentUser = _authentication.currentUser!;
    roomCode = widget.roomID.substring(0, 4);
    userDocRef = firestore.collection("user").doc(currentUser.uid);
    chatDocRef = firestore.collection('chat').doc(widget.roomID);
    toDoColRef =
        firestore.collection("chat").doc(widget.roomID).collection("todo");

    chat = Chat(roomName: widget.roomName, recentMessage: "", userList: []);
    readInitChatData();
    progressPercentStream = toDoColRef.snapshots();
    chatStream = chatDocRef.snapshots();
    showQuizSnackBar();
    FCMLocalNotification.currentRoomIDforNotification = widget.roomID;

    // 기존 유저들 구독 완료되면 삭제
    FirebaseMessaging.instance.subscribeToTopic(widget.roomID);
  }

  Future<void> readInitChatData() async {
    // get user chatList data
    await chatDocRef.get().then((value) {
      chat = Chat.fromJson(value);
    });

    userDocRef.get().then((value) {
      userChatList = value.get('chatList');
    });

    for (var user in chat.userList) {
      firestore.collection('user').doc(user.userID).get().then((value) {
        userNameList[user.userID] = value.data()!['name'];
      });
    }
  }

  Stream<DocumentSnapshot<Object?>> updateUserNameList(
      DocumentSnapshot<Object?> chatSnapshot) async* {
    Chat chat = Chat.fromJson(chatSnapshot);
    for (var user in chat.userList) {
      firestore.collection('user').doc(user.userID).get().then((value) {
        userNameList[user.userID] = value.data()!['name'];
      });
    }
    yield chatSnapshot;
  }

  Widget roleUser(String userID, String userName, int userRole) {
    //참가 유저의 역할 표시
    return InkWell(
      onTap: () {
        //클릭시 해당 유저 프로필 확인
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Profile(
                userID: userID,
                bChild: true,
                bMyProfile: userID == currentUser.uid,
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8), //참여자
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(children: [
            if (userRole == 0) //역할의 숫자가 큰 거만 표시
              Image.asset(
                "assets/image/logo.png",
                width: 30,
                height: 30,
                color: Colors.deepPurple,
              )
            else if (userRole >= 16)
              Image.asset("assets/image/commander.png",
                  width: 30, height: 30, color: Colors.deepPurple)
            else if (userRole >= 8)
              Image.asset("assets/image/explorer.png",
                  width: 30, height: 30, color: Colors.deepPurple)
            else if (userRole >= 4)
              Image.asset("assets/image/artist.png",
                  width: 30, height: 30, color: Colors.deepPurple)
            else if (userRole >= 2)
              Image.asset("assets/image/engineer.png",
                  width: 30, height: 30, color: Colors.deepPurple)
            else if (userRole >= 1)
              Image.asset("assets/image/communicator.png",
                  width: 30, height: 30, color: Colors.deepPurple),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  if (userID == currentUser.uid)
                    const Icon(Icons.verified_rounded,
                        color: Palette.brightBlue, size: 20),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getLatestQuiz() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> latestQuizQuerySnapshot =
          await chatDocRef
              .collection('quiz')
              .orderBy('quiz_C_date', descending: true)
              .limit(1)
              .get();

      if (latestQuizQuerySnapshot.docs.isNotEmpty) {
        return latestQuizQuerySnapshot.docs.first;
      } else {
        return null;
      }
    } catch (error) {
      print('Failed to get latest quiz: $error');
      return null;
    }
  }

  bool isWithin24(DocumentSnapshot<Map<String, dynamic>> quiz) {
    final Timestamp quizTimestamp = quiz.data()!['quiz_C_date'];
    final DateTime quizDateTime = quizTimestamp.toDate();
    final DateTime currentDateTime = DateTime.now();
    final Duration difference = currentDateTime.difference(quizDateTime);

    return difference.inHours < 24;
  }

  Duration calculateDifference(DocumentSnapshot<Map<String, dynamic>> quiz) {
    final Timestamp quizTimestamp = quiz.data()!['quiz_C_date'] as Timestamp;
    final DateTime quizDateTime = quizTimestamp.toDate();
    final DateTime currentDateTime = DateTime.now();
    final Duration difference = currentDateTime.difference(quizDateTime);
    return difference;
  }

  bool isUserInPasserList(DocumentSnapshot<Map<String, dynamic>> quiz) {
    final List<dynamic> passerList =
        quiz.data()!['quiz_passer'] as List<dynamic>;
    final String currentUserId = currentUser.uid;

    return passerList.contains(currentUserId);
  }

  void showQuizSnackBar() async {
    DocumentSnapshot<Map<String, dynamic>>? latestQuiz = await getLatestQuiz();

    if (latestQuiz != null &&
        isWithin24(latestQuiz) &&
        !isUserInPasserList(latestQuiz)) {
      Duration difference = calculateDifference(latestQuiz);
      int durationMilliseconds = difference.inMilliseconds;
      print('가장 최근 퀴즈 있음');
      final snackBar = SnackBar(
        duration: Duration(milliseconds: durationMilliseconds),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(100),
        content: const Text('퀴즈를 푸세요'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        action: SnackBarAction(
          label: '풀기',
          onPressed: () {
            print('스낵바 버튼 눌림');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    solve_quiz(roomID: widget.roomID, chatScreenState: this),
              ),
            );
          },
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      //! 스낵바 안보일 때 처리
      print('가장 최근 퀴즈가 없음');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        FCMLocalNotification.currentRoomIDforNotification = "";
        return true;
      },
      child: Scaffold(
        // chatting room background
        backgroundColor: Palette.lightGray,
        appBar: AppBar(
          // appBar background
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black54),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.roomName,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              const SizedBox(
                width: 4,
              ),
              StreamBuilder(
                  stream: chatDocRef.snapshots(),
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: snapshot.hasData &&
                              snapshot.data?.get('bEndProject')
                          ? null
                          : () =>
                              Clipboard.setData(ClipboardData(text: roomCode)),
                      child: const Icon(Icons.copy_rounded,
                          color: Palette.darkGray, size: 20),
                    );
                  }),
            ],
          ),
        ),
        onEndDrawerChanged: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        endDrawer: Drawer(
          child: StreamBuilder(
              stream: chatStream.asyncExpand(
                  (chatSnapshot) => updateUserNameList(chatSnapshot)),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return const CircularProgressIndicator(
                    color: Palette.pastelPurple,
                  );
                }
                chat = Chat.fromJson(snapshot.data!);
                // 유저 들어오거나 나갈때, 이름 파싱
                for (var user in chat.userList) {
                  firestore
                      .collection('user')
                      .doc(user.userID)
                      .get()
                      .then((value) {
                    userNameList[user.userID] = value.data()!['name'];
                  });
                }

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              // chat.roomName,
                              "채팅방 서랍",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, bottom: 8),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        '코드',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        roomCode,
                                        style: const TextStyle(
                                            color: Palette.darkGray),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      GestureDetector(
                                        onTap: chat.bEndProject
                                            ? null
                                            : () => Clipboard.setData(
                                                ClipboardData(text: roomCode)),
                                        child: const Icon(Icons.copy_rounded,
                                            color: Palette.darkGray, size: 20),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                        onTap: chat.bEndProject
                                            ? null
                                            : () {
                                                Share.share(
                                                    "CourseMic 을 다운 받고 무임승차 없는 조별과제를 진행해보세요!"
                                                    "\n\n플레이스토어 링크"
                                                    "\n\n채팅방 코드 : $roomCode");
                                              },
                                        child: const Icon(
                                            Icons.ios_share_rounded,
                                            color: Palette.darkGray,
                                            size: 20)),
                                  ),
                                ]),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8),
                            child: Divider(
                              height: 1,
                              color: Palette.darkGray,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, top: 10, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '참여자',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: chat.bEndProject
                                      ? null
                                      : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ModifyRole(
                                                  bCommander:
                                                      chat.commanderID ==
                                                              currentUser.uid
                                                          ? false
                                                          : chat.commanderID
                                                              .isNotEmpty,
                                                  role: chat
                                                      .userList[
                                                          chat.getIndexOfUser(
                                                              userID:
                                                                  currentUser
                                                                      .uid)]
                                                      .role,
                                                  roomID: widget.roomID,
                                                  userID: currentUser.uid,
                                                  returnRole: (int returnRole) {
                                                    int currentRole = chat
                                                        .getUser(
                                                            userID: currentUser
                                                                .uid)!
                                                        .role;
                                                    chat
                                                        .userList[
                                                            chat.getIndexOfUser(
                                                                userID:
                                                                    currentUser
                                                                        .uid)]
                                                        .role = returnRole;
                                                    chatDocRef.update(
                                                      chat.userListToJson(),
                                                    );

                                                    if (returnRole >= 16) {
                                                      chatDocRef.update({
                                                        'commanderID':
                                                            currentUser.uid,
                                                      });
                                                    }
                                                    if (currentRole >= 16 &&
                                                        returnRole < 16) {
                                                      chatDocRef.update({
                                                        'commanderID': "",
                                                      });
                                                    }
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                  child: const Text(
                                    '+ 역할 수정하기',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Palette.brightBlue,
                                        fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                          ),
                          for (var user in chat.userList)
                            roleUser(
                              user.userID,
                              userNameList[user.userID] ?? "userName",
                              user.role,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton.icon(
                          onPressed: chat.bEndProject
                              ? null
                              : () {
                                  showWidget(
                                      title: Center(
                                          child:
                                              Text('${chat.roomName} 과제 마무리!')),
                                      widget: Wrap(
                                          alignment: WrapAlignment.center,
                                          children: [
                                            RichText(
                                                textAlign: TextAlign.center,
                                                text: const TextSpan(children: [
                                                  TextSpan(
                                                      text: "과제 마무리를 하면 ",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16)),
                                                  TextSpan(
                                                    text: "오직 읽기만",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: "\n가능해집니다.",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                      )),
                                                ])),
                                            const Padding(
                                              padding: EdgeInsets.only(top: 16),
                                              child: Text(
                                                "마지막 인사를 나누고 마무리를 눌러주세요!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Palette.pastelRed,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ]),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('취소',
                                                    style: TextStyle(
                                                        color:
                                                            Palette.brightBlue,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            TextButton(
                                                onPressed: () async {
                                                  addEndEventLog(
                                                      roomID: widget.roomID,
                                                      uid: currentUser.uid);
                                                  FCMLocalNotification
                                                      .sendEndProjectNotification(
                                                          roomID: widget.roomID,
                                                          roomName:
                                                              chat.roomName);
                                                  chat.bEndProject = true;
                                                  chatDocRef.update({
                                                    "bEndProject":
                                                        chat.bEndProject
                                                  });

                                                  if (!mounted) return;
                                                  // pop Dialog
                                                  Navigator.of(context).pop();
                                                  // pop Drawer
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('마무리',
                                                    style: TextStyle(
                                                        color:
                                                            Palette.brightRed,
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ],
                                        ),
                                      ]);
                                },
                          icon: const Icon(
                            Icons.sports_kabaddi_outlined,
                          ),
                          label: const Text("과제 마무리하기"),
                        ),
                      ),
                    ),
                    SizedBox(
                      //톡방 나가기
                      height: 65,
                      child: ListTile(
                        tileColor: Palette.lightGray,
                        leading: const Icon(Icons.exit_to_app_rounded,
                            color: Palette.pastelPurple),
                        title: const Text('나가기',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Palette.pastelPurple)),
                        onTap: () async {
                          showWidget(
                              title:
                                  Center(child: Text('${chat.roomName} 나가기')),
                              widget: const Text(
                                '나가기를 하면 완료한 할 일 정보와 참여도 정보가 삭제됩니다.',
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('취소',
                                            style: TextStyle(
                                                color: Palette.brightBlue,
                                                fontWeight: FontWeight.bold))),
                                    TextButton(
                                        onPressed: () async {
                                          FirebaseMessaging.instance
                                              .unsubscribeFromTopic(
                                                  widget.roomID);
                                          addExitEventLog(
                                              roomID: widget.roomID,
                                              uid: currentUser.uid);
                                          if (chat.userList.length == 1) {
                                            chatDocRef.delete();
                                          } else {
                                            chat.userList
                                                .removeAt(chat.getIndexOfUser(
                                              userID: currentUser.uid,
                                            ));
                                            chatDocRef
                                                .update(chat.userListToJson());
                                          }
                                          userChatList.remove(widget.roomID);
                                          userDocRef.update({
                                            'chatList': userChatList,
                                          });

                                          // Delete user in all Todo
                                          var snapshot = (await toDoColRef
                                              .where("userIDs",
                                                  arrayContains:
                                                      currentUser.uid)
                                              .get());

                                          for (var doc in snapshot.docs) {
                                            var userIDs = List<String>.from(
                                                doc.get('userIDs'));
                                            userIDs.remove(currentUser.uid);
                                            toDoColRef
                                                .doc(doc.id)
                                                .update({"userIDs": userIDs});
                                          }

                                          if (!mounted) return;
                                          // pop Dialog
                                          Navigator.of(context).pop();
                                          // pop Drawer
                                          Navigator.of(context).pop();
                                          // pop ChatScreen
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('나가기',
                                            style: TextStyle(
                                                color: Palette.brightRed,
                                                fontWeight: FontWeight.bold)))
                                  ],
                                ),
                              ]);
                        },
                      ),
                    ),
                  ],
                );
              }),
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: progressPercentStream,
                builder:
                    (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  double progressPercent = 0.0;
                  String progressCount = "0";
                  if (snapshot.hasData) {
                    var todoDocs = snapshot.data!.docs;

                    if (todoDocs.isNotEmpty) {
                      progressPercent = todoDocs.length.toDouble();
                      int doneCount = todoDocs
                          .where((element) =>
                              element["state"] == ToDoState.Done.index)
                          .length;
                      progressPercent = doneCount / progressPercent;

                      progressCount = doneCount.toString();
                      progressCount += " / ${todoDocs.length}";
                    }
                  }

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ToDoPage(
                          roomID: widget.roomID,
                          chatScreenState: this,
                        ),
                      ),
                    ),
                    child: LinearPercentIndicator(
                      padding: const EdgeInsets.all(0),
                      animation: true,
                      animationDuration: 500,
                      lineHeight: 15.0,
                      percent: progressPercent,
                      center: Text(progressCount,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                      // only one color can accept
                      linearGradient: const LinearGradient(colors: [
                        Palette.brightViolet,
                        Palette.pastelPurple,
                        Palette.brightBlue
                      ]),
                    ),
                  );
                }),
            Expanded(
                child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                newMessageKey.currentState?.setBlockFalse();
              },
              child: Messages(
                // 톡방 특수 메시지 표시
                roomID: widget.roomID,
                chatDataParent: this,
              ),
            )),
            NewMessage(
              key: newMessageKey,
              roomID: widget.roomID,
              chatDataParent: this,
            ),
          ],
        ),
      ),
    );
  }

  // void copyRoomCode() {
  //   Clipboard.setData(ClipboardData(text: roomCode));
  //   fToast.showToast(
  //       child: toast,
  //       toastDuration: const Duration(milliseconds: 1250),
  //       fadeDuration: const Duration(milliseconds: 550));
  // }

  void showWidget(
      {Widget? title, required Widget? widget, List<Widget>? actions}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: title,
              backgroundColor: Colors.white,
              content: widget,
              actions: actions,
            ));
  }

  void updateRecentMessage(String content) {
    chat.recentMessage = content;
    chatDocRef.update(chat.toJson());
  }
}
