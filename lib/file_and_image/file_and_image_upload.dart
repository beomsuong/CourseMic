import 'dart:io';

import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/notification.dart';
import 'package:capston/palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';

class File_And_Image_Picker extends StatefulWidget {
  final String roomID;
  final ChatScreenState chatDataParent;
  const File_And_Image_Picker(
      {super.key, required this.roomID, required this.chatDataParent});

  @override
  State<File_And_Image_Picker> createState() => _File_And_Image_PickerState();
}

class _File_And_Image_PickerState extends State<File_And_Image_Picker> {
  final String resetText = "공유할 자료를 선택해주세요";
  PlatformFile? localFile;
  ValueNotifier<String> selectedFileNameNotifier =
      ValueNotifier("공유할 자료를 선택해주세요");
  ValueNotifier<double> percentageNotifier = ValueNotifier(0.0);
  late FToast fToast = FToast();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  late final String firebaseStoragePath;
  FileType? fileType;
  final int MAX_BYTE = 200 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    firebaseStoragePath = "shared_file/${widget.roomID}/";
  }

  resetVariable({bool bError = false}) {
    localFile = null;
    fileType = null;
    selectedFileNameNotifier.value = bError ? "다른 자료를 선택해주세요" : resetText;
  }

  showPickRequestToast() {
    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: const Text(
            "공유할 파일 또는 사진을 선택해주세요!",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showPickErrorToast(FileType type) {
    final String text = type == FileType.any ? "파일" : "사진";

    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: Text(
            "해당 $text의 용량이 200MB이상입니다\n다른 $text을 선택해주세요!",
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  showUploadEndToast(FileType type) {
    final String text = type == FileType.any ? "파일" : "사진";

    fToast.showToast(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Palette.toastGray,
          ),
          child: Text(
            "해당 $text이 공유되었습니다!",
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        toastDuration: const Duration(milliseconds: 1500),
        fadeDuration: const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: ValueListenableBuilder(
            valueListenable: percentageNotifier,
            builder: (context, value, child) => LinearProgressIndicator(
              minHeight: 5,
              value: value,
              backgroundColor: Palette.darkGray,
              color: Palette.brightBlue,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: selectedFileNameNotifier,
                        builder: (context, value, child) => Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.brightBlue,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          if (localFile == null) {
                            showPickRequestToast();
                            return;
                          }

                          String content = "${localFile!.name} ";

                          UploadTask putFileProgress = firebaseStorage
                              .ref(firebaseStoragePath + localFile!.name)
                              .putFile(File(localFile!.path!));
                          putFileProgress.snapshotEvents.listen((event) {
                            percentageNotifier.value =
                                (event.bytesTransferred / event.totalBytes);
                          });
                          await putFileProgress.then((snapshot) async {
                            content += await snapshot.ref.getDownloadURL();
                          });

                          if (fileType == FileType.any) {
                            addFileMSG(
                                roomID: widget.roomID,
                                uid: widget.chatDataParent.currentUser.uid,
                                content: content);
                          } else if (fileType == FileType.image) {
                            addImageMSG(
                                roomID: widget.roomID,
                                uid: widget.chatDataParent.currentUser.uid,
                                content: content);
                          }

                          String fileTypeStr =
                              fileType == FileType.any ? "파일" : "사진";
                          widget.chatDataParent
                              .updateRecentMessage(fileTypeStr);
                          FCMLocalNotification.sendMessageNotification(
                            roomID: widget.roomID,
                            roomName: widget.chatDataParent.chat.roomName,
                            userName: widget.chatDataParent.userNameList[
                                widget.chatDataParent.currentUser.uid]!,
                            message: "$fileTypeStr을 보냈습니다",
                          );
                          await showUploadEndToast(fileType!);
                          resetVariable();
                        },
                        icon: const Icon(
                          Icons.rocket_launch_rounded,
                        ),
                        label: const Text("공유")),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => chooseFileWithType(FileType.any),
                      icon: const Icon(
                        Icons.description_rounded,
                      ),
                      label: const Text("파일 선택")),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => chooseFileWithType(FileType.image),
                      icon: const Icon(
                        Icons.image_rounded,
                      ),
                      label: const Text("사진 선택")),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> chooseFileWithType(FileType type) async {
    percentageNotifier.value = 0.0;
    fileType = type;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType!,
    );

    if (result != null) {
      localFile = result.files.first;

      late int fileBytes;
      await File(localFile!.path!).length().then((value) {
        fileBytes = value;
      });

      if (fileBytes >= MAX_BYTE) {
        await showPickErrorToast(fileType!);
        resetVariable(bError: true);
        return;
      }

      selectedFileNameNotifier.value = localFile!.name;
    }
  }
}
