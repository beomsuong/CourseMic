import 'package:capston/chatting/chat/add_chat.dart';
import 'package:capston/chatting/chat/search_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capston/chatting/chat_screen.dart';

class GradientText extends StatelessWidget {
  const GradientText({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      'CourseMic',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Color.fromARGB(142, 141, 5, 187)],
          ).createShader(
            const Rect.fromLTWH(50.0, 0.0, 200.0, 0.0),
          ),
      ),
    );
  }
}

class RoomList extends StatefulWidget {
  const RoomList({Key? key}) : super(key: key);
  @override
  State<RoomList> createState() => RoomListState();
}

class RoomListState extends State<RoomList> {
  @override
  initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> loadingdata() async {
    final authentication = FirebaseAuth.instance;

    final user = authentication.currentUser;
    print(user!.uid);
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 최상위 컬렉션에서 하위 컬렉션까지 한 번에 지정하는 변수
    DocumentReference docRef = firestore.collection('exuser').doc(user.uid);

    // 문서의 데이터를 가져옵니다.
    DocumentSnapshot docSnapshot = await docRef.get();

    // 문서 내부의 사람리스트 필드를 가져옵니다.
    List<dynamic> roomIdList = docSnapshot.get('톡방리스트');
    print("!");

    roomList = [];
    for (var roomID in roomIdList) {
      DocumentReference roomRef = firestore.collection('exchat').doc(roomID);
      DocumentSnapshot roomnameSnapshot = await roomRef.get();
      String roomname = roomnameSnapshot.get('톡방이름');

      final chatDocsSnapshot = await FirebaseFirestore.instance
          .collection('exchat')
          .doc(roomID)
          .collection('message')
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      if (chatDocsSnapshot.docs.isNotEmpty) {
        final lastMessage = chatDocsSnapshot.docs[0]['text'];

        roomList.add([
          roomname,
          roomID,
          lastMessage,
        ]);
      } else {
        roomList.add([
          roomname,
          roomID,
          '',
        ]);
      }
    }
    roomIdList = [];
  }

  late List<List<dynamic>> roomList; //톡방 이름, UID, 마지막 메시지 저장
  Widget room(String name, String id, String message) {
    //UID는 onTap에서 톡방을 불러오기 위해 사용
    //톡방을 리스트를 보여주는 함수
    return InkWell(
      onTap: () {
        print("해당 톡방이 클릭됬음 $id");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                roomID: id,
              );
            },
          ),
        );
        ChatScreen(
          roomID: id,
        );
      },
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.only(top: 8), //톡방간 간격
          child: Row(children: [
            Image.asset(
              //톡방별 대표 이미지 개개인 프사나 해당 톡방에서의 역할 표시하면 좋을듯
              "assets/image/logo.png",
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //글자 왼쪽 정렬
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        // 톡방 제목은 굵게
                      ),
                      Text(
                        message,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    ); // SizedBox를 제거하고 Text 위젯만 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const GradientText(),
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: null,
            icon: Image.asset(
              "assets/image/logo.png",
              fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchChat()),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.purple,
                size: 30,
              ), // 원하는 아이콘을 선택합니다.
            ),
          ],
        ),
        body: FutureBuilder(
          future: loadingdata(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // 로딩 중일 때 표시될 위젯
            } else {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // 오류 발생 시 표시될 위젯
              } else {
                return ListView(
                  children: [
                    for (var data in roomList)
                      room(data[0], data[1], data[2]), // 자신이 속한 톡방의 갯수만큼 반복
                  ],
                );
              }
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
            tooltip: '톡방 추가',
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddChat();
                },
              );
            }));
  }
}
