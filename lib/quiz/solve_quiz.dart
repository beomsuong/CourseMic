import 'package:capston/chatting/chat/add_chat.dart';
import 'package:capston/chatting/chat/message/imp_msg.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/view_important_message.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

// class solve_quiz extends StatefulWidget {
//   const solve_quiz({super.key});

//   @override
//   State<solve_quiz> createState() => _solve_quizState();
// }

// class _solve_quizState extends State<solve_quiz> {
//   List<DocumentSnapshot> msgList = [];
//   List<DocumentSnapshot> quizMsgList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchMessagesFromFirestore();//아직 모름
//   }

//   Future<void> fetchMessageFromFirestore() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//     .collection('exchat')
//     .doc(roomname)
//     .collection('message')
//     .orderBy('timeStamp', descending: true)//최신 -> 오래됨
//     .get();

//     setState(() {
//       quizMsgList = snapshot.docs;
//       shuffleMessages();
//     });
//   }

//   void shuffleMessages() {
//     setState(() {
//       quizMsgList.shuffle(); // 메시지 순서 섞기
//     });
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("순서 맞추기 Quiz"),
//         backgroundColor: Colors.red,
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             //일단 만들어뒀음
//             padding: EdgeInsets.symmetric(),
//             child: Text('다음 대화들을 일이 일어난 순서대로 배치해주세요.'),
//           ),
//           ,
//           ElevatedButton.icon(
//             onPressed: () {
//               //이곳에 퀴즈 정답 제출
//             },
//             icon: const Icon(Icons.check),
//             label: const Text('제출'),
//           )
//         ],
//       ),
//     );
//   }
// }

//final List impMsgList = []; //중요한 메시지를 받아올 리스트

Future<int> getImpMsgCount(String roomname) async {
  //해당 톡방에 있는 중요한 메시지 개수
  final snapshot = await FirebaseFirestore.instance
      .collection('exchat')
      .doc(roomname)
      .collection('imp_msg')
      .get();

  return snapshot.size;
}

Future<void> generateImportantMessageQuiz(String roomname) async {
  //퀴즈 생성
  final impMsgCount = await getImpMsgCount(roomname);

  if (impMsgCount <= 3) {
    // 작성자 맞추기
    await generateWriterQuiz(roomname);
  } else if (impMsgCount >= 5) {
    //순서 맞추기
    await generateOrderQuiz(roomname);
  }
}

// Future<void> generateWriterQuiz(String roomname) async {
//   // 중요 메시지 보낸이 맞추기 퀴즈 생성
//   final querySnapshot = await FirebaseFirestore.instance
//       .collection('exchat')
//       .doc(roomname)
//       .collection('imp_msg')
//       .get();

//   final impMsgList = querySnapshot.docs; //리스트 형태
//   final randomIndex = Random().nextInt(impMsgList.length); //3개중 무작위 메시지 인덱스 추출
//   final randomImpMsg = impMsgList[randomIndex]; //3개중 랜덤 중요 메시지 픽
//   final senderID = randomImpMsg['userID']; // 보낸이의 userID 가져오기

//   //해당 userID에 대응하는 username 값 가져오기
//   final userNameDoc = await FirebaseFirestore.instance
//       .collection('username') // users 컬렉션명에 맞게 수정해야 함
//       .doc(senderID)
//       .get();

//   final senderUsername = userNameDoc['username']; // 보낸이의 username 가져오기

//   // TODO: 작성자 맞추기 퀴즈 생성 로직 작성, senderUsername 사용
// }

class writerQuiz extends StatefulWidget {
  final Key? superkey;
  final String? roomname;

  const writerQuiz({this.superkey, this.roomname});

  @override
  State<writerQuiz> createState() => _writerQuizState();
}

class _writerQuizState extends State<writerQuiz> {
  late String senderID;
  late String senderUsername;
  late String randomImpMsg;

  @override
  void initState() {
    super.initState();
    generateWriterQuiz(roomname);
  }

  Future<void> generateWriterQuiz(String roomname) async {
    //!반드시 3개 이하일 때만 실행되는 코드
    // 중요 메시지 보낸이 맞추기 퀴즈 생성
    final querySnapshot = await FirebaseFirestore.instance
        .collection('exchat')
        .doc(roomname)
        .collection('imp_msg')
        .get();

    final List<DocumentSnapshot> impMsgListDoc = querySnapshot.docs;
    final int randomIndex = Random().nextInt(impMsgListDoc.length);
    final DocumentSnapshot randomImpMsgDoc = impMsgListDoc[randomIndex];
    final DocumentSnapshot randomImpMsg = impMsgListDoc[randomIndex];

    final Map<String, dynamic> impMsgData =
        randomImpMsgDoc.data() as Map<String, dynamic>;

    final String msgDetail = impMsgData['msg_detail'].toString();
    final String msgID = impMsgData['msg_id'].toString();
    final DateTime timeStamp = impMsgData['timeStamp'].toDate();
    final String username = impMsgData['username'].toString();

    //해당 userID에 대응하는 username 값 가져오기
    final userNameDoc = await FirebaseFirestore.instance
        .collection('username')
        .doc(senderID)
        .collection('')
        .get();

    final senderUsername = userNameDoc['username']; // 보낸이의 username 가져오기

    // TODO: 작성자 맞추기 퀴즈 생성 로직 작성, senderUsername 사용
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("누가 보낸 메시지인가요?"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center, //spaceEvently?
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.purpleAccent,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.message_rounded),
                    title: Text(randomImpMsg),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> generateOrderQuiz(String roomname) async {
  // 최근 중요 메시지 순서 맞추기 퀴즈 생성
  final querySnapshot = await FirebaseFirestore.instance
      .collection('exchat')
      .doc(roomname)
      .collection('imp_msg')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .get();

  final impMsgList = querySnapshot.docs; //메시지 5개 저장
  final impMsgListSize = impMsgList.length;
  print("generateOrderQuiz의 impMsgList의 크기는 $impMsgListSize 입니다.\n");
  final shuffledImpMsgs = impMsgList.toList()..shuffle(); //순서가 섞인 리스트

  // TODO: 순서 맞추기 퀴즈 생성 로직 작성
}

Future<void> createQuizFromImpMessages(String roomname) async {
  // Firestore에서 해당 채팅방의 imp_msg 컬렉션에 접근하여 중요한 메시지 개수 확인
  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('exchat')
      .doc(roomname)
      .collection('imp_msg')
      .get();

  int impMessageCount = snapshot.docs.length;

  if (impMessageCount <= 3) {
    generateWriterQuiz(roomname);
    // 중요한 메시지 개수가 3개 이하인 경우: 누가 보낸 메시지인지 보낸 이를 맞추는 퀴즈 생성
    // TODO: 퀴즈 생성 및 표시 로직 구현
    print('누가 보낸 메시지인지 보낸 이를 맞추는 퀴즈 생성');
  } else if (impMessageCount >= 5) {
    generateWriterQuiz(roomname);
    // 중요한 메시지 개수가 5개 이상인 경우: 최근 중요 메시지 5개를 가져와 순서를 뒤섞은 후 순서 맞추기 퀴즈 생성
    // TODO: 최근 중요 메시지 5개 가져오고 순서를 뒤섞어 퀴즈 생성하는 로직 구현
    print('최근 중요 메시지 5개를 가져와 순서를 뒤섞은 후 순서 맞추기 퀴즈 생성');
  }
}

//----------------------------------------------------------
//----------------------------------------------------------
//----------------------------------------------------------
class solve_quiz extends StatefulWidget {
  Stream<ImpMsgSnapshot> impMsgStream;

  solve_quiz({super.key, required this.impMsgStream});

  @override
  State<solve_quiz> createState() => _solve_quizState();
}

class _solve_quizState extends State<solve_quiz> {
  List<imp_msg> impMsgList = List<imp_msg>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getImpMsgList();
  }

  void getImpMsgList() async {
    int count = 0;
    await for (var snapshot in widget.impMsgStream) {
      for (var doc in snapshot.docs) {
        if (count >= 5) return;
        impMsgList.add(imp_msg.fromJson(doc));
        count++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
