import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:capston/quiz/solve_quiz.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final currentYear = DateTime.now().year; //실제 시간의 년도

typedef ImpMsgSnapshot = QuerySnapshot<Map<String, dynamic>>;

class ImportantMessagesPage extends StatefulWidget {
  final ChatScreenState chatScreenState;
  final String roomID;

  const ImportantMessagesPage(
      {Key? key, required this.roomID, required this.chatScreenState})
      : super(key: key);

  @override
  State<ImportantMessagesPage> createState() => _ImportantMessagesPageState();
}

class _ImportantMessagesPageState extends State<ImportantMessagesPage> {
  late Stream<QuerySnapshot<Object?>> imgMsgStream;

  bool isBtnEnable = false;
  @override
  void initState() {
    super.initState();
    imgMsgStream = loadImpMsgList();
    checkBtnStatus();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> loadImpMsgList() async* {
    var snapshot = await widget.chatScreenState.chatDocRef
        .collection('imp_msg')
        .orderBy('timeStamp', descending: true) // 시간 역순으로 정렬
        .get();
    yield snapshot;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getLatestQuiz() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> latestQuizQuerySnapshot =
          await widget.chatScreenState.chatDocRef
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
    final String currentUserId = widget.chatScreenState.currentUser.uid;

    return passerList.contains(currentUserId);
  }

  void checkBtnStatus() async {
    DocumentSnapshot<Map<String, dynamic>>? latestQuiz = await getLatestQuiz();

    setState(() {
      if (latestQuiz != null && //퀴즈가 존재함
          isWithin24(latestQuiz) && //24시간 내에 생긴 퀴즈가 있음
          isUserInPasserList(//정답자 리스트에 있음
              latestQuiz)) {
        isBtnEnable = false;
      } else if (latestQuiz == null || //퀴즈가 존재하지 않음
          !isWithin24(latestQuiz) || //24시간 내에 생긴 퀴즈 없음
          !isUserInPasserList(latestQuiz)) {
        //정답자 리스테 없음
        isBtnEnable = true;
      }
    });
  }

//-----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // appBar background
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text("중요메세지 목록",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
      body: StreamBuilder<QuerySnapshot>(
        stream: imgMsgStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          // 해당 채팅방의 중요한 메시지만 필터링하여 보여줌

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              final messageDetail = data['msg_detail'] ?? '';
              final sendTime = data['timeStamp'] as Timestamp;
              final userId = data['user_id'] ?? '';
              final impMsgId = documents[index].id;

              final dateTime = sendTime.toDate();
              late var fmtTime = DateFormat('M월 dd일 h:mm a').format(dateTime);
              final msgYear = dateTime.year;

              if (currentYear != msgYear) {
                //년도 비교. 년도가 다를 때만 년도 표기
                fmtTime = DateFormat('yyyy년 M월 d일 hh:mm').format(dateTime);
              } else {
                fmtTime = DateFormat('M월 d일 h:mm a').format(dateTime);
              }

              return Card(
                color: Palette.pastelYellow,
                margin: const EdgeInsets.only(top: 14, left: 12, right: 12),
                child: GestureDetector(
                  onLongPress: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('이 메시지를 삭제하시겠습니까?'),
                      content: Text(messageDetail),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            print(documents[index].id);
                            deleteImpMsg(widget.roomID, impMsgId);
                            setState(() {
                              imgMsgStream = loadImpMsgList();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      userId,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Palette.pastelBlack),
                    ),
                    subtitle: Text(
                      messageDetail,
                      style: const TextStyle(
                          fontSize: 14, color: Palette.pastelBlack),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmtTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isBtnEnable
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => solve_quiz(
                      chatScreenState: widget.chatScreenState,
                      roomID: widget.roomID,
                    ),
                  ),
                );
              },
              child: const Text("Quiz!"),
            )
          : null,
    );
  }
}

//---------------------------------------------------------------------------------------------------
Future<void> deleteImpMsg(String roomID, String impMsgId) async {
  try {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(roomID)
        .collection('imp_msg')
        .doc(impMsgId)
        .delete();
    print('중요한 메시지 삭제 완료!');
  } catch (error) {
    print('중요한 메시지 삭제 실패!: $error');
  }
}

//----------------------------------------------------------------------------------------------------
//--------------------------------- Simple Message View Code------------------------------------------

class SimpleImportantMessage extends StatelessWidget {
  final String roomID;
  final ChatScreenState chatScreenState;

  const SimpleImportantMessage(
      {Key? key, required this.roomID, required this.chatScreenState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: chatScreenState.chatDocRef
            .collection('imp_msg')
            .orderBy('timeStamp', descending: true) // 최근 시간 순으로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          return Column(
            children: [
              Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.lightGray,
                      offset: Offset(0.0, 5.0), //(x,y)
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImportantMessagesPage(
                            roomID: roomID,
                            chatScreenState: chatScreenState,
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(
                          left: 8.0, right: 14.0, top: 4.0, bottom: 12.0),
                      child: Text(
                        '+ 중요 메시지 전부 보기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Palette.brightBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data =
                        documents[index].data() as Map<String, dynamic>;

                    final messageDetail = data['msg_detail'] ?? '';
                    final sendTime = data['timeStamp'] as Timestamp;
                    final userId = data['user_id'] ?? '';
                    final dateTime = sendTime.toDate();
                    final fmtTime = DateFormat('MM/dd').format(dateTime);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0 ||
                            isDifferentDate(
                                //  !CAUTION!: 성능에 문제를 일으킬 수 있음
                                documents[index - 1],
                                documents[index]))
                          Padding(
                            //if문이 true일 때만 실행. 시간을 패딩으로 같은 날짜의 시간 기입'
                            padding: const EdgeInsets.only(
                                top: 12, bottom: 4, left: 12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, //제거시 날짜 중앙 정렬
                              children: [
                                // const Divider(color: Palette.darkGray),
                                Text(
                                  fmtTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Card(
                            margin: const EdgeInsets.all(4),
                            color: Palette.pastelYellow,
                            child: ListTile(
                              //메시지 본문. trailing의 날짜 삭제
                              contentPadding: const EdgeInsets.only(left: 12),
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              title: Text(
                                '$userId : $messageDetail',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: false,
                                style: const TextStyle(
                                    fontSize: 14, color: Palette.pastelBlack),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //! 문제될 시 삭제 혹은 개선
  bool isDifferentDate(QueryDocumentSnapshot<Object?> prev,
      QueryDocumentSnapshot<Object?> current) {
    final prevTime =
        (prev.data() as Map<String, dynamic>)['timeStamp'] as Timestamp;
    final currentTime =
        (current.data() as Map<String, dynamic>)['timeStamp'] as Timestamp;

    final prevDateTime = prevTime.toDate();
    final currentDateTime = currentTime.toDate();

    return prevDateTime.day != currentDateTime.day ||
        prevDateTime.month != currentDateTime.month ||
        prevDateTime.year != currentDateTime.year;
  }
}
