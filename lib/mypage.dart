import 'package:capston/provider/userdata.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class Mypage extends StatelessWidget {
  Mypage({super.key});
  late Userdata data;
  SizedBox print_info(String a, String b) {
    //기본 정보 출력 함수
    //파이어 베이스에서 해당 정보를 받아온다
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Text(
            ' $a : $b',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    data = Provider.of<Userdata>(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          const Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              child: Text('● 내 프로필',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
            ),
          ),
          Align(
            alignment: Alignment.center, // 가운데 정렬
            child: SizedBox(
              child: Image.asset(
                "assets/image/logo.png",
                fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
              ),
            ),
          ),
          Column(
            children: const [
              Text(
                '이름 예정',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Divider(
                thickness: 2,
                height: 10,
                indent: 70,
                endIndent: 70,
                color: Colors.black,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30, left: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Text(
                    '기본 정보',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 버튼을 눌렀을 때 실행되는 코드
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: Text(
                    '+ 수정',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 25, left: 25),
              child: Column(
                children: [
                  const Divider(
                    thickness: 2,
                    height: 3,
                    color: Colors.black,
                  ),
                  print_info("대학", "대학 정보 변수"),
                  print_info("학과 ", "학과 변수"),
                  print_info("MBTI ", "MBTI 변수"),
                  print_info("연락 가능 시간 ", "연락가능 시간 변수"),
                  const Divider(
                    thickness: 2,
                    height: 10,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30, left: 30, top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Text(
                    '활동 이력',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 버튼을 눌렀을 때 실행되는 코드
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: Text(
                    '+ 조회',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 25, left: 25),
              child: Column(
                children: [
                  const Divider(
                    thickness: 2,
                    height: 3,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: const [
                        Text(
                          '현재 참여중인 과제 : ' '갯수 변수' '(개)',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: const [
                        Text(
                          '완료한 과제 : ' '갯수 변수' '(개)',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    height: 10,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 7, bottom: 7),
                  child: Text(
                    'Level : ' '레벨변수',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //이하 주석 부분 LinearPercentIndicator에 병합
                // Text(
                //   'EXP',
                //   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                // ),
                LinearPercentIndicator(
                  width: 200.0,
                  lineHeight: 20.0,
                  leading: Text(
                    //좌측 문자열 Leading
                    "EXP",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  trailing: Text(
                    //우측 문자열 trailing
                    "% 변수",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  percent: 0.8,
                  center: Text("80.0%"),
                  backgroundColor: const Color.fromARGB(255, 198, 198, 198),
                  progressColor: Color.fromRGBO(237, 145, 255, 1),
                  animation: true,
                  animationDuration: 2500,
                  barRadius: Radius.circular(30.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
