//체팅방 참가자의 역할을 수정

import 'package:capston/palette.dart';
import 'package:capston/widgets/RoundButtonStyle.dart';
import 'package:flutter/material.dart';

class ModifyRole extends StatefulWidget {
  final bool bCommander;
  final String roomID;
  final String userID;
  final int role;
  final Function(int) returnRole;

  const ModifyRole(
      {Key? key,
      required this.bCommander,
      required this.userID,
      required this.roomID,
      required this.role,
      required this.returnRole})
      : super(key: key);

  @override
  State<ModifyRole> createState() => _ModifyRoleState();
}

class _ModifyRoleState extends State<ModifyRole> {
  late int userRole; //유저의 역할 계산 비트 연산
  @override
  void initState() {
    super.initState();
    userRole = widget.role;
    int initRole = userRole;
    if (initRole >= 16) {
      _commander = true;
      initRole -= 16;
    }
    if (initRole >= 8) {
      _explorer = true;
      initRole -= 8;
    }
    if (initRole >= 4) {
      _artist = true;
      initRole -= 4;
    }
    if (initRole >= 2) {
      _engineer = true;
      initRole -= 2;
    }
    if (initRole >= 1) {
      _communicator = true;
      initRole -= 1;
    }
  }

  bool _commander = false; //각 역할 변수
  bool _engineer = false;
  bool _artist = false;
  bool _explorer = false;
  bool _communicator = false;

  Future<void> rolecomplete() async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "역할 선택",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Palette.darkGray),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Checkbox(
                        value: _commander,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onChanged: widget.bCommander
                            ? null
                            : (bool? value) {
                                setState(() {
                                  _commander = value!;
                                  _commander ? userRole += 16 : userRole -= 16;
                                });
                              },
                        activeColor: Colors.black,
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 75,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 3, // 테두리 두께
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/image/commander.png",
                          scale: 9,
                          // alignment: Alignment.bottomCenter, // 이미지를 바닥에 붙임
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '커맨더',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                Text(
                                  ' (조장)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Text(
                              '전체적인 일정을 조율하고 조별과제가 잘 마무리될 수 있도록 이끌어보자 !',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Checkbox(
                        value: _explorer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onChanged: (bool? value) {
                          setState(() {
                            _explorer = value!;
                            _explorer ? userRole += 8 : userRole -= 8;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 3, // 테두리 두께
                        ),
                      ),
                      child: Image.asset(
                        "assets/image/explorer.png",
                        width: 70,
                        height: 70,
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '익스플로러',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                Text(
                                  ' (자료조사자)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Text(
                              '과제 수행함에 있어 필요한 자료를 조사하고 팀원과 공유해 보자 !',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Checkbox(
                        value: _artist,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onChanged: (bool? value) {
                          setState(() {
                            _artist = value!;
                            _artist ? userRole += 4 : userRole -= 4;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 3, // 테두리 두께
                        ),
                      ),
                      child: Image.asset(
                        "assets/image/artist.png",
                        width: 70,
                        height: 70,
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '아티스트',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                Text(
                                  ' (디자이너)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Text(
                              'PPT, 사진 그리고 동영상 같은 자료들을 제작하고 멋지고 예쁘게 편집해보자 !',
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Checkbox(
                        value: _engineer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onChanged: (bool? value) {
                          setState(() {
                            _engineer = value!;
                            _engineer ? userRole += 2 : userRole -= 2;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 3, // 테두리 두께
                        ),
                      ),
                      child: Image.asset(
                        "assets/image/engineer.png",
                        scale: 9,
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '엔지니어',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                Text(
                                  ' (개발자)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Text(
                              '과제 수행에 필요한 기능이나 기획에 맞게 프로그램을 구현해보자 !',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Checkbox(
                        value: _communicator,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onChanged: (bool? value) {
                          setState(() {
                            _communicator = value!;
                            _communicator ? userRole += 1 : userRole -= 1;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 3, // 테두리 두께
                        ),
                      ),
                      child: Image.asset(
                        "assets/image/communicator.png",
                        scale: 9,
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '커뮤니케이터',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                                Text(
                                  ' (발표자)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Text(
                              '그동안 팀원들과 함께 만든 작품을 교수님 또는 다른 조원들 앞에서 열심히 발표해보자 !',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () {
                widget.returnRole(userRole);
                Navigator.of(context).pop();
              },
              style: colorButtonStyle(Palette.brightBlue),
              child: const Text(
                '완료',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
