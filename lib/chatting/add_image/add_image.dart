import 'dart:io';

import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo_node.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddImage extends StatefulWidget {
  const AddImage(this.addImageFunc, {Key? key}) : super(key: key);

  final Function(File pickedImage) addImageFunc;

  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File? pickedImage;

  Future<bool> requestCameraAndStoragePermisson() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (status[Permission.camera]!.isGranted &&
        status[Permission.storage]!.isGranted) {
      return true; //권한 허용
    } else {
      return false; //권한 거부
    }
  }

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

  void _pickImageFromGallery() async {
    //FilePickerResult? filePickResult = await FilePicker.platform.pickFiles();
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      widget.addImageFunc(imageFile);
    } else {
      Navigator.pop(context);
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                //Camera
                onPressed: () async {
                  requestCameraAndStoragePermisson();
                  if (await Permission.camera.isGranted) {
                    _pickImage();
                  } else {
                    requestCameraAndStoragePermisson();
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Palette.pastelPurple),
                label: const Text('Camera', style: purpleText),
              ),
              const SizedBox(
                width: 10,
              ),
              OutlinedButton.icon(
                //Gallery
                onPressed: () async {
                  requestCameraAndStoragePermisson();
                  if (await Permission.camera.isGranted) {
                    _pickImageFromGallery();
                  } else {
                    requestCameraAndStoragePermisson();
                  }
                },
                icon: const Icon(Icons.image_outlined,
                    color: Palette.pastelPurple),
                label: const Text('Gallery', style: purpleText),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
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
