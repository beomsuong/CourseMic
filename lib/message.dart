import 'package:flutter/material.dart';

class RoomList extends StatelessWidget {
  RoomList({Key? key}) : super(key: key); // 수정된 생성자
  final List<String> roomList = [
    "즐거운 조별과제",
    "화나는 조별과제",
    "너무 미운 조별과제",
    "즐거운 조별과제",
    "화나는 조별과제",
    "너무 미운 조별과제",
    "즐거운 조별과제",
    "화나는 조별과제",
    "너무 미운 조별과제",
    "즐거운 조별과제",
    "화나는 조별과제",
    "너무 미운 조별과제"
  ]; //자신이 속한 톡방을 저장하는 리스트 파이어 베이스 연동 예정

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
      body: ListView(
        children: [
          for (var data in roomList) room(data), // 자신이 속한 톡방의 갯수만큼 반복
        ],
      ),
    );
  }
}
