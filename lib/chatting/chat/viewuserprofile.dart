import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

class Viewuserprofile extends StatefulWidget {
  String? userid;
  Viewuserprofile({required this.userid, super.key});

  @override
  State<Viewuserprofile> createState() => _ViewuserprofileState();
}

class _ViewuserprofileState extends State<Viewuserprofile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<DocumentSnapshot> loadingdata() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 최상위 컬렉션에서 하위 컬렉션까지 한 번에 지정하는 변수
    DocumentReference docRef =
        firestore.collection('exuser').doc(widget.userid);

    // 문서의 데이터를 가져옵니다.
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
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
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: loadingdata(),
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
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        child: Text('● 프로필',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center, // 가운데 정렬
                      child: SizedBox(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(docSnapshot.get('이미지')),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          docSnapshot.get('이름'),
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                          height: 10,
                          indent: 70,
                          endIndent: 70,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30, left: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SizedBox(
                            child: Text(
                              '기본 정보',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
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
                            print_info("대학", docSnapshot.get('대학')),
                            print_info("학과 ", docSnapshot.get('학과')),
                            print_info("MBTI ", docSnapshot.get('MBTI')),
                            print_info("연락 가능 시간 ", docSnapshot.get('연락가능시간')),
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
                      padding:
                          const EdgeInsets.only(right: 30, left: 30, top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            child: Text(
                              '활동 이력',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // 버튼을 눌렀을 때 실행되는 코드
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 148, 61, 255), // 버튼 배경색 지정
                            ),
                            child: const Text(
                              '+ 조회',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
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
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearPercentIndicator(
                            width: 200.0,
                            lineHeight: 20.0,
                            leading: const Text(
                              //좌측 문자열 Leading
                              "EXP",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                            trailing: const Text(
                              //우측 문자열 trailing
                              "% 변수",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                            percent: 0.8,
                            center: const Text("80.0%"),
                            backgroundColor:
                                const Color.fromARGB(255, 198, 198, 198),
                            progressColor:
                                const Color.fromRGBO(237, 145, 255, 1),
                            animation: true,
                            animationDuration: 2500,
                            barRadius: const Radius.circular(30.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }
          }),
    );
  }
}
