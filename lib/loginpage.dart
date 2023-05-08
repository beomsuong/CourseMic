import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Loginpage extends StatefulWidget {
  Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  late String id = "123", pwd = "123";
  void press_login() {
    //로그인 버튼을 누르면 실행되는 함수
    //id와 pwd 가 NULL은 아니지만 공백인 경우도 고려해야함
    if (id != "123" && pwd != "123") {
      print("$id $pwd");
    } else {
      print("안출력");
    }
  }

  Map<String, List<List<dynamic>>> datas = {
    '수학': [
      [1, 9, 30, 60],
      [2, 9, 30, 60],
    ],
    '과학': [
      [3, 9, 30, 60],
    ]
  };
  int i = 0;
  @override
  void initState() {
    for (var key in datas.keys) {
      print("!");
      final usercol =
          FirebaseFirestore.instance.collection("!@#users12").doc(key);
      usercol.set({});

      for (final value in datas[key]!) {
        i++;

        final usercol =
            FirebaseFirestore.instance.collection("!@#users12").doc(key);
        usercol.update({
          i.toString(): value,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
      onTap: () {
        //키보드를 꺼내고 따른 곳을 누르면 바로 키보드가 사라지게 위해 추가
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        //키보드를 꺼내면 픽셀을 초과하는 문제가 생겨서 리스트뷰로 변경
        child: Center(
          //키보드를 꺼내고 따른 곳을 누르면 바로 키보드가 사라지게 위해 추가
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              "assets/image/logo.png",
              fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
            ),
            SizedBox(
              child: Text(
                'CouserMic',
                style: TextStyle(
                  fontSize: 40,
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
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    id = text;
                  });
                },
                decoration: InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(80)), //둥글게
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 204, 199, 191),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    pwd = text;
                  });
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 204, 199, 191),
                ),
              ),
            ),
            SizedBox(
              //버튼간 공백용 사이즈 박스
              height: 10,
            ),
            SizedBox(
              width: 300,
              height: 55,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      //버튼을 둥글게 처리
                      borderRadius: BorderRadius.circular(10)),
                  foregroundColor: Colors.black,
                  backgroundColor: Color.fromARGB(255, 204, 199, 191),
                ),
                onPressed: () {
                  press_login();
                }, //로그인 함수 호출
                child: Text(
                  '로그인',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(
              //버튼간 공백용 사이즈 박스
              height: 10,
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            //버튼을 둥글게 처리
                            borderRadius: BorderRadius.circular(10)),
                        foregroundColor: Colors.black,
                        backgroundColor: Color.fromARGB(255, 204, 199, 191),
                      ),
                      onPressed: () {}, //로그인 함수 호출
                      child: Text(
                        '회원가',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          //버튼을 둥글게 처리
                          borderRadius: BorderRadius.circular(10)),
                      foregroundColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 204, 199, 191),
                    ),
                    onPressed: () {}, //로그인 함수 호출
                    child: Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    ));
  }
}
