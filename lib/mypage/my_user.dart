// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  late String name;
  late String MBTI;
  late String university;
  late String department;
  late String contactTime;
  late String imageURL;

  MyUser(
      {required this.name,
      this.MBTI = "???",
      this.university = "???",
      this.department = "???",
      this.contactTime = "???",
      required this.imageURL});

  MyUser.fromJson(DocumentSnapshot<Object?> json)
      : this(
          name: json['name'],
          MBTI: json['MBTI'],
          university: json['university'],
          department: json['department'],
          contactTime: json['contactTime'],
          imageURL: json['imageURL'],
        );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "MBTI": MBTI,
      "university": university,
      "department": department,
      "contactTime": contactTime,
      "imageURL": imageURL,
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
    }

    return {
      field: data,
    };
  }
}
