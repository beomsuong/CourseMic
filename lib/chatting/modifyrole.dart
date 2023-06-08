import 'package:flutter/material.dart';

class ModifyRole extends StatefulWidget {
  final String roomid;
  final String useruid;
  final int role;
  final Function(int) returnuserrole;

  const ModifyRole(
      {Key? key,
      required this.useruid,
      required this.roomid,
      required this.role,
      required this.returnuserrole})
      : super(key: key);

  @override
  State<ModifyRole> createState() => _ModifyRoleState();
}

class _ModifyRoleState extends State<ModifyRole> {
  late int userRole;
  @override
  void initState() {
    userRole = widget.role;
    if (userRole >= 16) {
      _commander = true;
      userRole -= 16;
    }
    if (userRole >= 8) {
      _explorer = true;
      userRole -= 8;
    }
    if (userRole >= 4) {
      _artist = true;
      userRole -= 4;
    }
    if (userRole >= 2) {
      _engineer = true;
      userRole -= 2;
    }
    if (userRole >= 1) {
      _communicator = true;
      userRole -= 1;
    }
    userRole = widget.role;
    super.initState();
  }

  bool _commander = false;
  bool _engineer = false;
  bool _artist = false;
  bool _explorer = false;
  bool _communicator = false;

  Future<void> rolecomplete() async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Colors.white,
        centerTitle: true, // 중앙에 타이틀을 배치합니다.
        leading: Container(), // 이 공간을 비워둠으로써 actions과의 균형을 맞춥니다.
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3.0,
              width: 150.0,
              color: Colors.black,
            ),
            const Text(
              "역할 선택",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 3.0),
            Container(
              height: 3.0,
              width: 150.0,
              color: Colors.black,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              widget.returnuserrole(userRole);
              Navigator.of(context).pop();
            },
            child: const Text(
              '완료',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Checkbox(
                  value: _commander,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onChanged: (bool? value) {
                    setState(() {
                      _commander = value!;
                      if (_commander) {
                        userRole += 16;
                      } else {
                        userRole -= 16;
                      }
                    });
                  },
                  activeColor: Colors.black,
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // 테두리 색상
                    width: 3, // 테두리 두께
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      "assets/image/commander.png",
                      width: 70,
                      height: 70,
                      alignment: Alignment.bottomCenter, // 이미지를 바닥에 붙임
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text(
                            '커맨더',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Text(
                            ' (조장)',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        height: 1,
                        color: Colors.black,
                      ),
                      const Text(
                        '전체적인 일정을 조율하고 조별과제가 잘 마무리될 수 있도록 이끌어보자 !',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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

                      if (_engineer) {
                        userRole += 2;
                      } else {
                        userRole -= 2;
                      }
                    });
                  },
                  activeColor: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // 테두리 색상
                    width: 3, // 테두리 두께
                  ),
                ),
                child: Image.asset(
                  "assets/image/engineer.png",
                  width: 70,
                  height: 70,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text(
                            '엔지니어',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Text(
                            ' (개발자)',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        height: 1,
                        color: Colors.black,
                      ),
                      const Text(
                        '과제 수행에 필요한 기능이나 기획에 맞게 프로그램을 구현해보자 !',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (_artist) {
                        userRole += 4;
                      } else {
                        userRole -= 4;
                      }
                    });
                  },
                  activeColor: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text(
                            '아티스트',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Text(
                            ' (디자이너)',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        height: 1,
                        color: Colors.black,
                      ),
                      const Text(
                        'PPT, 사진 그리고 동영상 같은 자료들을 제작하고 멋지고 예쁘게 편집해보자 !',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (_explorer) {
                        userRole += 8;
                      } else {
                        userRole -= 8;
                      }
                    });
                  },
                  activeColor: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text(
                            '익스플로러',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Text(
                            ' (자료조사자)',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        height: 1,
                        color: Colors.black,
                      ),
                      const Text(
                        '과제 수행함에 있어 필요한 자료를 조사하고 팀원과 공유해 보자 !',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (_communicator) {
                        userRole += 1;
                      } else {
                        userRole -= 1;
                      }
                    });
                  },
                  activeColor: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // 테두리 색상
                    width: 3, // 테두리 두께
                  ),
                ),
                child: Image.asset(
                  "assets/image/communicator.png",
                  width: 70,
                  height: 70,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Text(
                            '커뮤니케이터',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Text(
                            ' (발표자)',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        height: 1,
                        color: Colors.black,
                      ),
                      const Text(
                        '그동안 팀원들과 함께 만든 작품을 교수님이나 다른 조원들 앞에서 열심히 발표해보자 !',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
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
        ],
      ),
    );
  }
}
