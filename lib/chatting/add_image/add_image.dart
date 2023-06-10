import 'dart:io';

import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo_node.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage(this.addImageFunc, {Key? key}) : super(key: key);

  final Function(File pickedImage) addImageFunc;

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? pickedImage;

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxHeight: 150);
    setState(() {
      if (pickedImageFile != null) {
        pickedImage = File(pickedImageFile.path);
      }
    });
    widget.addImageFunc(pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pickedImage != null
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: FileImage(pickedImage!),
                )
              : const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/image/user.png"),
                ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: () {
              _pickImage();
            },
            icon: const Icon(Icons.image, color: Palette.pastelPurple),
            label: const Text('이미지 추가', style: purpleText),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 30, bottom: 10),
            child: Text("기본 프로필 이미지를 사용하려면 닫기를 눌러주세요.",
                style: TextStyle(
                    color: Palette.brightBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Palette.pastelPurple),
            label: const Text('닫기', style: purpleText),
          ),
        ],
      ),
    );
  }
}
