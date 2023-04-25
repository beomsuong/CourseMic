import 'package:flutter/material.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(
          "assets/image/logo.png",
          fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
        ),
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              labelText: '아이디',
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
          height: 10,
        ),
        SizedBox(
          width: 300,
          child: TextField(
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
        )
      ]),
    );
  }
}
