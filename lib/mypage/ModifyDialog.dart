import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ModifyDialog extends StatefulWidget {
  final Function(String) returndata;
  String? university;
  String? datatype;
  ModifyDialog({
    Key? key,
    required this.returndata,
    this.university,
    this.datatype,
  }) : super(key: key);

  @override
  State<ModifyDialog> createState() => _ModifyDialogState();
}

Future<DocumentSnapshot> loadingdata(
    String datatype, String universistyname) async {
  final authentication = FirebaseAuth.instance;
  final user = authentication.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference docRef = firestore.collection('exuser').doc(user?.uid);
  DocumentSnapshot docSnapshot = await docRef.get();
  await docRef.update({datatype: universistyname});
  return docSnapshot;
}

class _ModifyDialogState extends State<ModifyDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              padding: EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("수정하기",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20)),
                  IconButton(
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100, // 원하는 너비 제약 조건을 설정합니다.
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          widget.university = value;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      loadingdata(widget.datatype!, widget.university!);
                      widget.returndata(widget.university!);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                    ),
                    child: Text(
                      '변경',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ));
  }
}
