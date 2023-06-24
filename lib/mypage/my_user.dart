// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  late String name;
  late String MBTI;
  late String university;
  late String department;
  late String contactTime;
  late String imageURL;
  late List<String> chatList;
  late int exp;
  late List<String> doneProject;
  late String deviceToken;

  MyUser({
    required this.name,
    this.MBTI = "???",
    this.university = "???",
    this.department = "???",
    this.contactTime = "???",
    required this.imageURL,
    required this.chatList,
    this.exp = 0,
    required this.doneProject,
    required this.deviceToken,
  });

  factory MyUser.fromJson(DocumentSnapshot<Object?> json) {
    return MyUser(
        name: json['name'],
        MBTI: json['MBTI'],
        university: json['university'],
        department: json['department'],
        contactTime: json['contactTime'],
        imageURL: json['imageURL'],
        chatList: List<String>.from(json['chatList']),
        exp: json['exp'],
        doneProject: List<String>.from(json['doneProject']),
        deviceToken: json['deviceToken']);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "MBTI": MBTI,
      "university": university,
      "department": department,
      "contactTime": contactTime,
      "imageURL": imageURL,
      "chatList": chatList,
      "exp": exp,
      "doneProject": doneProject,
      "deviceToken": deviceToken,
    };
  }

  Map<String, dynamic> chosenToJson(String field) {
    dynamic data;
    switch (field) {
      case "name":
        data = name;
        break;
      case "MBTI":
        data = MBTI;
        break;
      case "university":
        data = university;
        break;
      case "department":
        data = department;
        break;
      case "contactTime":
        data = contactTime;
        break;
      case "imageURL":
        data = imageURL;
        break;
      case "chatList":
        data = chatList;
        break;
      case "exp":
        data = exp;
        break;
      case "doneProject":
        data = doneProject;
        break;
      case "deviceToken":
        data = deviceToken;
        break;
    }

    return {
      field: data,
    };
  }
}
