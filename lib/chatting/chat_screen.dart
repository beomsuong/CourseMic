import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/chatting/chat/chat_list.dart';
import 'package:capston/chatting/modify_role.dart';
import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:capston/quiz/solve_quiz.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_page.dart';
import 'package:cherry_toast/cherry_toast_icon.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/new_message.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String roomID;
  final ChatListState chatListParent;
  const ChatScreen(
      {Key? key, required this.roomID, required this.chatListParent})
      : super(key: key);

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
  late Future<double> progressPercentFuture;
  late Future<void> chatFuture;

  late final String roomCode;
  late FToast fToast;
  Widget toast = Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 36),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: Palette.toastGray,
    ),
    child: const Text("채팅방 코드가 클립보드에 복사되었습니다",
        style: TextStyle(color: Colors.white)),
  );

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    currentUser = _authentication.currentUser!;
    roomCode = widget.roomID.substring(0, 4);
    userDocRef = firestore.collection("user").doc(currentUser.uid);
    chatDocRef = firestore.collection('chat').doc(widget.roomID);
    toDoColRef =
        firestore.collection("chat").doc(widget.roomID).collection("todo");
    progressPercentFuture = calculateProgressPercent();
    chatFuture = readInitChatData();
    showInitialSnackBar();
  }

  Future<void> readInitChatData() async {
    // get user chatList data
    userDocRef.get().then((value) {
      userChatList = value.get('chatList');
    });

    // get chat data
    await readRoomName();
    for (var user in chat.userList) {
      firestore.collection('user').doc(user.userID).get().then((value) {
        userNameList[user.userID] = value.data()!['name'];
      });
    }
  }

  // also read chat data
  Future<String> readRoomName() async {
    await chatDocRef.get().then((value) {
      chat = Chat.fromJson(value);
    });
    return chat.roomName;
  }

  void updateChat() {
    setState(() {
      chatFuture = readInitChatData();
    });
  }

  String progressCount = "";
  Future<double> calculateProgressPercent() async {
    double progressPercent = 0.0;
    await toDoColRef
        .where('state', isEqualTo: ToDoState.Done.index)
        .get()
        .then((snapshot) {
      progressPercent =
          snapshot.docs.isEmpty ? 0.0 : snapshot.docs.length.toDouble();
      progressCount = progressPercent.toInt().toString();
    });
    if (progressPercent == 0.0) return progressPercent;
    await toDoColRef.get().then(
      (snapshot) {
        progressPercent /= snapshot.docs.length;
        progressCount += "/${snapshot.docs.length}";
      },
    );
    return progressPercent;
  }

  void updateProgressPercent() {
    setState(() {
      progressPercentFuture = calculateProgressPercent();
    });
  }

  Widget roleUser(String userID, String userName, int userRole) {
    return InkWell(
      onTap: () {
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
            if (userRole == 0)
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
              Image.asset(
                "assets/image/artist.png",
                width: 30,
                height: 30,
              )
            else if (userRole >= 2)
              Image.asset("assets/image/engineer.png",
                  width: 30, height: 30, color: Colors.deepPurple)
            else if (userRole >= 1)
              Image.asset(
                "assets/image/communicator.png",
                width: 30,
                height: 30,
              ),
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

  void showInitialSnackBar() async {
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
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            print('스낵바의 퀴즈 풀어라~ 버튼 눌림');
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
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      //! 스낵바 안보일 때 처리
      print('가장 최근 퀴즈가 없는거같다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            FutureBuilder(
                future: readRoomName(),
                builder: (context, snapshot) {
                  return Text(snapshot.hasData ? snapshot.data! : "RoomName",
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500));
                }),
            const SizedBox(
              width: 4,
            ),
            GestureDetector(
              onTap: copyRoomCode,
              child: const Icon(Icons.copy_rounded,
                  color: Palette.darkGray, size: 20),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: FutureBuilder(
            future: chatFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const CircularProgressIndicator(
                  color: Palette.pastelPurple,
                );
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
                          padding: const EdgeInsets.only(left: 12.0, bottom: 8),
                          child: Row(children: [
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
                              style: const TextStyle(color: Palette.darkGray),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: copyRoomCode,
                              child: const Icon(Icons.copy_rounded,
                                  color: Palette.darkGray, size: 20),
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ModifyRole(
                                        bCommander:
                                            chat.commanderID == currentUser.uid
                                                ? false
                                                : chat.commanderID.isNotEmpty,
                                        role: chat
                                            .userList[chat.getIndexOfUser(
                                                userID: currentUser.uid)]
                                            .role,
                                        roomID: widget.roomID,
                                        userID: currentUser.uid,
                                        returnRole: (int returnRole) {
                                          int currentRole = chat
                                              .getUser(userID: currentUser.uid)!
                                              .role;
                                          chat
                                              .userList[chat.getIndexOfUser(
                                                  userID: currentUser.uid)]
                                              .role = returnRole;
                                          chatDocRef.update(
                                            chat.userListToJson(),
                                          );

                                          if (returnRole >= 16) {
                                            chatDocRef.update({
                                              'commanderID': currentUser.uid,
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
                            title: Text('${chat.roomName} 나가기'),
                            widget: const Text(
                                '나가기를 하면 완료한 할 일 정보와 참여도 정보가 삭제됩니다.'),
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
                                              color: Palette.brightBlue))),
                                  TextButton(
                                      onPressed: () async {
                                        chat.userList
                                            .removeAt(chat.getIndexOfUser(
                                          userID: currentUser.uid,
                                        ));

                                        userChatList.remove(widget.roomID);
                                        chatDocRef
                                            .update(chat.userListToJson());
                                        userDocRef.update({
                                          'chatList': userChatList,
                                        });
                                        widget.chatListParent
                                            .leaveRoom(widget.roomID);

                                        // pop Dialog
                                        Navigator.of(context).pop();
                                        // pop Drawer
                                        Navigator.of(context).pop();
                                        // pop ChatScreen
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('나가기',
                                          style: TextStyle(
                                              color: Palette.brightViolet)))
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
          FutureBuilder(
              future: progressPercentFuture,
              builder: (context, snapshot) {
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
                    percent: snapshot.hasData ? snapshot.data! : 0.0,
                    center: Text(progressCount.isEmpty ? "" : progressCount,
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
          Builder(builder: (context) {
            //showInitialSnackBar();
            return Expanded(
              child: Messages(roomID: widget.roomID),
            );
          }),
          NewMessage(
            roomID: widget.roomID,
            chatScreenState: this,
          ),
        ],
      ),
    );
  }

  void copyRoomCode() {
    Clipboard.setData(ClipboardData(text: roomCode));
    fToast.showToast(
        child: toast,
        toastDuration: const Duration(milliseconds: 1250),
        fadeDuration: const Duration(milliseconds: 550));
  }

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
}
