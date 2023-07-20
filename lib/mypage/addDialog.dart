//정보 수정 다이얼로그

// ignore_for_file: non_constant_identifier_names

import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:capston/widgets/RoundButtonStyle.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  final ProfileState myPageState;

  const AddDialog({
    Key? key,
    required this.myPageState,
  }) : super(key: key);
  @override
  State<AddDialog> createState() => _AddDialog1State();
}

class _AddDialog1State extends State<AddDialog> {
  ButtonStyle brightBlueButtonStyle = colorButtonStyle(Palette.brightBlue);

  late TextEditingController universityController;
  late TextEditingController departmentController;
  late TextEditingController MBTIController;
  late TextEditingController contactTimeController;

  @override
  void initState() {
    super.initState();
    universityController = TextEditingController(
        text: initText(widget.myPageState.myUser.university));
    departmentController = TextEditingController(
        text: initText(widget.myPageState.myUser.department));
    MBTIController =
        TextEditingController(text: initText(widget.myPageState.myUser.MBTI));
    contactTimeController = TextEditingController(
        text: initText(widget.myPageState.myUser.contactTime));
  }

  String initText(String data) {
    return data == "???" ? "" : data;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Palette.brightBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
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
                    icon: const Icon(Icons.remove_circle_outline_rounded))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: 200,
                    child: TextField(
                        textAlign: TextAlign.start,
                        controller: universityController,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '대학교를 입력해주세요',
                          hintStyle: TextStyle(
                              color: Palette.textColor1, fontSize: 12),
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 4),
                        ),
                        onChanged: (value) {
                          widget.myPageState.myUser.university = value;
                        })),
                ElevatedButton(
                  onPressed: () {
                    widget.myPageState.userDocRef.update(
                        widget.myPageState.myUser.chosenToJson("university"));
                  },
                  style: brightBlueButtonStyle, // 버튼 배경색 지정
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Palette.brightBlue,
            thickness: 1.5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: 200,
                    child: TextField(
                        textAlign: TextAlign.start,
                        controller: departmentController,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '학과를 입력해주세요',
                          hintStyle: TextStyle(
                              color: Palette.textColor1, fontSize: 12),
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 4),
                        ),
                        onChanged: (value) {
                          widget.myPageState.myUser.department = value;
                        })),
                ElevatedButton(
                  onPressed: () {
                    widget.myPageState.userDocRef.update(
                        widget.myPageState.myUser.chosenToJson("department"));
                  },
                  style: brightBlueButtonStyle, // 버튼 배경색 지정
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Palette.brightBlue,
            thickness: 1.5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: 200,
                    child: TextField(
                        textAlign: TextAlign.start,
                        controller: MBTIController,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'MBTI를 입력해주세요',
                          hintStyle: TextStyle(
                              color: Palette.textColor1, fontSize: 12),
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 4),
                        ),
                        onChanged: (value) {
                          widget.myPageState.myUser.MBTI = value;
                        })),
                ElevatedButton(
                  onPressed: () {
                    widget.myPageState.userDocRef
                        .update(widget.myPageState.myUser.chosenToJson("MBTI"));
                  },
                  style: brightBlueButtonStyle, // 버튼 배경색 지정
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Palette.brightBlue,
            thickness: 1.5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: 200,
                    child: TextField(
                        textAlign: TextAlign.start,
                        controller: contactTimeController,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '연락 가능한 시간대를 입력해주세요',
                          hintStyle: TextStyle(
                              color: Palette.textColor1, fontSize: 12),
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: 4),
                        ),
                        onChanged: (value) {
                          widget.myPageState.myUser.contactTime = value;
                        })),
                ElevatedButton(
                  onPressed: () {
                    widget.myPageState.userDocRef.update(
                        widget.myPageState.myUser.chosenToJson("contactTime"));
                  },
                  style: brightBlueButtonStyle, // 버튼 배경색 지정
                  child: const Text(
                    '변경',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }
}
