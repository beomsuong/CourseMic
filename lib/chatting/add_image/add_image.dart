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
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color.fromARGB(255, 75, 75, 75),
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
            label: const Text('Add image', style: purpleText),
          ),
          const SizedBox(
            height: 40,
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Palette.pastelPurple),
            label: const Text('Close', style: purpleText),
          ),
        ],
      ),
    );
  }
}
