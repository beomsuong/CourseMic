// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class imp_msg {
  late String msg_detail;
  late Timestamp timeStamp;
  late String user_id;

  imp_msg(
      {required this.msg_detail,
      required this.timeStamp,
      required this.user_id});

  factory imp_msg.fromJson(QueryDocumentSnapshot<Object?> json) {
    return imp_msg(
        msg_detail: json["msg_detail"],
        timeStamp: json["timeStamp"] as Timestamp,
        user_id: json["user_id"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "msg_detail": msg_detail,
      "timeStamp": timeStamp,
      "user_id": user_id,
    };
  }
}
