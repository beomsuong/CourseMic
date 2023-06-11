import 'package:capston/palette.dart';
import 'package:capston/widgets/GradientText.dart';
import 'package:capston/widgets/RoundButtonStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Viewuserprofile extends StatefulWidget {
  String? userID;
  Viewuserprofile({required this.userID, super.key});

  @override
  State<Viewuserprofile> createState() => _ViewuserprofileState();
}

class _ViewuserprofileState extends State<Viewuserprofile> {
  Future<DocumentSnapshot> readUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore.collection('user').doc(widget.userID);
    DocumentSnapshot docSnapshot = await docRef.get();
    return docSnapshot;
  }

  SizedBox print_info(String a, String b) {
    //기본 정보 출력 함수
    //파이어 베이스에서 해당 정보를 받아온다

    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Text(
            ' $a : $b',
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const GradientText(
          text: "CourseMic",
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: null,
          icon: Image.asset(
            "assets/image/logo.png",
            fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: readUserData(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                DocumentSnapshot docSnapshot = snapshot.data!;
                return ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.center, // 가운데 정렬
                      child: SizedBox(
                        child: Material(
                          borderRadius: BorderRadius.circular(50),
                          elevation: 1,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Palette.lightGray,
                            child: CircleAvatar(
                              radius: 49,
                              backgroundImage:
                                  NetworkImage(docSnapshot.get("imageURL")),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      docSnapshot.get("name"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 5, bottom: 5),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(
                                          child: Text(
                                            ' 기본 정보',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // showDialog(
                                        //   context: context,
                                        //   builder: (BuildContext context) {
                                        //     return AddDialog(
                                        //       myPageState: this,
                                        //     );
                                        //   },
                                        // ).then((value) {
                                        //   setState(() {});
                                        // });
                                      },
                                      style: buttonStyle,
                                      child: const Text(
                                        '+ 수정',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        print_info("대학교",
                                            docSnapshot.get("university")),
                                        const Divider(),
                                        print_info("학과 ",
                                            docSnapshot.get("department")),
                                        const Divider(),
                                        print_info(
                                            "MBTI ", docSnapshot.get("MBTI")),
                                        const Divider(),
                                        print_info("연락 가능 시간 ",
                                            docSnapshot.get("contactTime")),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.subject_rounded),
                                        SizedBox(
                                          child: Text(
                                            ' 활동 이력',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // 버튼을 눌렀을 때 실행되는 코드
                                      },
                                      style: buttonStyle,
                                      child: const Text(
                                        '+ 조회',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              Text(
                                                '현재 참여중인 과제 : ' 'N' '(개)',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              Text(
                                                '완료한 과제 : ' '0' '(개)',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            'Level 0',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w900),
                          ),
                        ),
                        LinearPercentIndicator(
                          alignment: MainAxisAlignment.center,
                          width: 280.0,
                          lineHeight: 20.0,
                          leading: const Text(
                            //좌측 문자열 Leading
                            "EXP",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                          trailing: const Text(
                            //우측 문자열 trailing
                            "80%",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                          percent: 0.8,
                          center: const Text("80.0%",
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Palette.lightGray,
                          linearGradient: const LinearGradient(colors: [
                            Palette.brightViolet,
                            Palette.pastelPurple,
                            Palette.brightBlue
                          ]),
                          animation: true,
                          animationDuration: 2500,
                          barRadius: const Radius.circular(30.0),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
          }),
    );
  }
}
