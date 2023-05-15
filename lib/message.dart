import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomList extends StatefulWidget {
  RoomList({Key? key}) : super(key: key);
  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    loadingdata();
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
    List<dynamic> roomList1 = docSnapshot.get('톡방리스트');
    print(roomList1);
    roomList = roomList1;
  }

  // 수정된 생성자
  late List<dynamic> roomList;
  //자신이 속한 톡방을 저장하는 리스트 파이어 베이스 연동 예정
  Widget room(String a) {
    //톡방을 리스트를 보여주는 함수
    return InkWell(
      onTap: () {
        //톡방 클릭시 이벤트 발생 톡방 안으로 들어가면 댈거같음
        print("해당 톡방이 클릭됬음 $a");
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
                        a,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        // 톡방 제목은 굵게
                      ),
                      Text('해당 톡방 최근 대화 내역이 나오면 좋겠다'),
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
      body: FutureBuilder(
        future: loadingdata(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시될 위젯
          } else {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}')); // 오류 발생 시 표시될 위젯
            } else {
              return ListView(
                children: [
                  for (var data in roomList) room(data), // 자신이 속한 톡방의 갯수만큼 반복
                ],
              );
            }
          }
        },
      ),
    );
  }
}
