import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Searchmessage extends StatefulWidget {
  const Searchmessage({super.key});

  @override
  State<Searchmessage> createState() => _SearchmessageState();
}

class _SearchmessageState extends State<Searchmessage> {
  String groupname = '';
  String groupcode = '코드 불명??';
  String groupmember = '맴버 불명??';
  String groupmessage = '';
  bool btn = false;
  searchdata(String a) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore.collection('exchat').get();

    for (var doc in querySnapshot.docs) {
      if ("mH2p" == doc.id.substring(0, 4)) {
        print(doc['톡방이름'].toString());
        groupname = doc['톡방이름'].toString();
        final chatDocsSnapshot = await FirebaseFirestore.instance
            .collection('exchat')
            .doc(doc.id)
            .collection('message')
            .orderBy('time', descending: true)
            .limit(1)
            .get();

        if (chatDocsSnapshot.docs.isNotEmpty) {
          Timestamp timestamp = chatDocsSnapshot.docs[0]['time'];
          DateTime dateTime = timestamp.toDate();
          String formattedDate = DateFormat('M월d일').format(dateTime);
          groupmessage = formattedDate;
          btn = true;
          setState(() {});
          return;
        }
      }
    }
    btn = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 30,
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 100.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 3.0,
                  width: 150.0,
                  color: Colors.black,
                ),
                Text(
                  "톡방 검색",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 3.0),
                Container(
                  height: 3.0,
                  width: 150.0,
                  color: Colors.black,
                ),
              ],
            ),
            SizedBox(width: 60),
          ],
        ),
      ),
      body: Column(children: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
            ),
            SizedBox(
                width: 200,
                child: TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '코드를 입력하세요',
                  ),
                )),
            IconButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                searchdata("a");
              },
              icon: Icon(
                Icons.search,
                color: Colors.purple,
                size: 30,
              ), // 원하는 아이콘을 선택합니다.
            ),
          ],
        ),
        Container(
            width: 370,
            height: 400,
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 6, // 선의 굵기 설정
              ),
              borderRadius: BorderRadius.circular(20), // 둥근 정도 설정
            ),
            child: Column(
              children: [
                Text(
                  "선택한 톡방 정보",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 2.0,
                  width: 250.0,
                  color: Colors.black,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                            children: [
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  "그룹 이름 :",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  "그룹 코드 :",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  "현재 참가자 :",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  "최근 메시지 :",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  groupname,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  groupcode,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  groupmember,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                height: 35,
                                child: Text(
                                  groupmessage,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: btn ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: Text(
                    '입장',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )),
      ]),
    );
  }
}
