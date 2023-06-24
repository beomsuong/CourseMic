import 'package:capston/chatting/main_screen.dart';
import 'package:capston/mypage/my_user.dart';
import 'package:capston/mypage/queryDialog.dart';
import 'package:capston/palette.dart';
import 'package:capston/widgets/GradientText.dart';
import 'package:capston/widgets/RoundButtonStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:capston/mypage/addDialog.dart';

class Profile extends StatefulWidget {
  final String userID;
  final bool bChild;
  final bool bMyProfile;
  const Profile(
      {super.key,
      required this.userID,
      this.bChild = true,
      this.bMyProfile = false});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  late MyUser myUser;
  late DocumentReference userDocRef;

  @override
  void initState() {
    super.initState();
    userDocRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userID);
  }

  SizedBox print_info(String a, String b) {
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
        title: widget.bChild
            ? const Text(
                "프로필",
                style: TextStyle(color: Colors.black, fontSize: 20),
              )
            : const GradientText(text: "프로필"),
        centerTitle: !widget.bMyProfile,
        elevation: 0.5,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: !widget.bMyProfile,
        leading: widget.bChild
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Palette.darkGray),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        actions: [
          if (!widget.bChild)
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text(
                            "로그아웃",
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('취소',
                                        style: TextStyle(
                                            color: Palette.brightBlue,
                                            fontWeight: FontWeight.bold))),
                                TextButton(
                                    onPressed: () {
                                      const FlutterSecureStorage()
                                          .delete(key: "login");

                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(
                                        builder: (context) {
                                          return const LoginSignupScreen();
                                        },
                                      ));
                                    },
                                    child: const Text('확인',
                                        style: TextStyle(
                                            color: Palette.brightRed,
                                            fontWeight: FontWeight.bold)))
                              ],
                            )
                          ],
                        ));
              },
              icon: const Icon(Icons.exit_to_app_rounded,
                  color: Palette.pastelPurple),
            )
        ],
      ),
      body: StreamBuilder(
          stream: userDocRef.snapshots(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            myUser = MyUser.fromJson(snapshot.data!);
            List<dynamic> level = calculateLevel(myUser.exp);

            return ListView(
              children: <Widget>[
                SizedBox(
                  height: widget.bMyProfile ? 15 : 30,
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
                          backgroundImage: NetworkImage(myUser.imageURL),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  myUser.name,
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
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: widget.bMyProfile ? 5 : 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                if (widget.bMyProfile)
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddDialog(
                                            myPageState: this,
                                          );
                                        },
                                      ).then((value) {
                                        setState(() {});
                                      });
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
                                    print_info("대학교", myUser.university),
                                    const Divider(color: Palette.darkGray),
                                    print_info("학과 ", myUser.department),
                                    const Divider(color: Palette.darkGray),
                                    print_info("MBTI ", myUser.MBTI),
                                    const Divider(color: Palette.darkGray),
                                    print_info("연락 가능 시간 ", myUser.contactTime),
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
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: widget.bMyProfile ? 5 : 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return QueryDialog(
                                          myPageState: this,
                                        );
                                      },
                                    );
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
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: Row(
                                        children: [
                                          Text(
                                            '현재 참여중인 과제 : ${myUser.chatList.length}(개)',
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(color: Palette.darkGray),
                                    SizedBox(
                                      height: 30,
                                      child: Row(
                                        children: [
                                          Text(
                                            '완료한 과제 : ${myUser.doneProject.length}(개)',
                                            style: const TextStyle(
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
                    Padding(
                      padding: EdgeInsets.only(
                          top: widget.bMyProfile ? 5 : 15, bottom: 5),
                      child: Text(
                        'Level ${level[0]}',
                        style: const TextStyle(
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
                      trailing: Text(
                        //우측 문자열 trailing
                        "${(level[1] * 100).floor()}%",
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      percent: level[1],
                      center: Text("${(level[1] * 100).floor()}%",
                          style: const TextStyle(color: Colors.white)),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            );
          }),
    );
  }

  List<dynamic> calculateLevel(int exp) {
    return [(exp ~/ 300), (exp / 300) - (exp ~/ 300)];
  }
}
