//정보 수정
import 'package:capston/mypage/profile.dart';
import 'package:capston/palette.dart';
import 'package:capston/widgets/RoundButtonStyle.dart';
import 'package:flutter/material.dart';

class ModifyDialog extends StatefulWidget {
  final ProfileState myPageDataParent;
  final Function(String) returnData;
  String fieldData;
  String fieldName;
  ModifyDialog({
    Key? key,
    required this.returnData,
    required this.myPageDataParent,
    required this.fieldData,
    required this.fieldName,
  }) : super(key: key);

  @override
  State<ModifyDialog> createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<ModifyDialog> {
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
                      },
                      icon: const Icon(Icons.cancel))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100, // 원하는 너비 제약 조건을 설정합니다.
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          widget.fieldData = value;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.myPageDataParent.userDocRef
                          .update({widget.fieldName: widget.fieldData});
                      widget.returnData(widget.fieldData);
                      Navigator.of(context).pop();
                    },
                    style: colorButtonStyle(Palette.brightBlue),
                    child: const Text(
                      '변경',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            )
          ],
        ));
  }
}
