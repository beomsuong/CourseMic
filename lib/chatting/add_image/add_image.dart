import 'dart:io';

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
      padding: EdgeInsets.only(top: 10),
      width: 150,
      height: 300,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            backgroundImage:
                pickedImage != null ? FileImage(pickedImage!) : null,
          ),
          SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: () {
              _pickImage();
            },
            icon: Icon(Icons.image),
            label: Text('Add image'),
          ),
          SizedBox(
            height: 80,
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            label: Text('Close'),
          ),
        ],
      ),
    );
  }
}
