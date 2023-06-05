import 'package:capston/mypage/ModifyDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  late String university, major, mbti, contacttime;
  AddDialog({
    Key? key,
    required this.university,
    required this.major,
    required this.mbti,
    required this.contacttime,
  }) : super(key: key);
  @override
  State<AddDialog> createState() => _AddDialog1State();
}

@override
void initState() {}

Future<DocumentSnapshot> loadingdata() async {
  final authentication = FirebaseAuth.instance;

  final user = authentication.currentUser;
  print(user!.uid);
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 최상위 컬렉션에서 하위 컬렉션까지 한 번에 지정하는 변수
  DocumentReference docRef = firestore.collection('exuser').doc(user.uid);

  // 문서의 데이터를 가져옵니다.
  DocumentSnapshot docSnapshot = await docRef.get();

  return docSnapshot;
}

class _AddDialog1State extends State<AddDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("수정하기",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20)),
                IconButton(
                    color: Colors.white,
                    iconSize: 30,
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    icon: const Icon(Icons.check))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.university,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ModifyDialog(
                          returndata: (String value) {
                            widget.university = value;
                            setState(() {});
                          },
                          university: widget.university,
                          datatype: "대학",
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1.0,
            width: 500.0,
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.major,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ModifyDialog(
                          returndata: (String value) {
                            widget.major = value;
                            setState(() {});
                          },
                          university: widget.major,
                          datatype: "학과",
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1.0,
            width: 500.0,
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.mbti,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1.0,
            width: 500.0,
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.contacttime,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ModifyDialog(
                          returndata: (String value) {
                            widget.contacttime = value;
                            setState(() {});
                          },
                          university: widget.contacttime,
                          datatype: "연락가능시간",
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
