import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

enum LogType {
  text,
  media,
  enter,
  exit,
  date,
  end,
}

class MSG {
  late LogType type;
  late String uid;
  late Timestamp sendTime;
  late String content;

  late Map<String, String> react;
  late List<String> readers;

  late String replyID;

  MSG({
    this.type = LogType.text,
    required this.uid,
    required this.sendTime,
    this.content = "",
    required this.react,
    required this.readers,
    this.replyID = "",
  });

  factory MSG.fromJson(QueryDocumentSnapshot<Object?> json) {
    return MSG(
      type: LogType.values[json["type"]],
      uid: json["uid"],
      sendTime: json["sendTime"] as Timestamp,
      content: json["content"],
      react: jsonDecode(json["react"]),
      readers: List<String>.from(json['readers']),
      replyID: json["replyID"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.index,
      "uid": uid,
      "sendTime": sendTime,
      "content": content,
      "react": jsonEncode(react),
      "readers": readers,
      "replyID": replyID,
    };
  }
}

class EventLog {
  late LogType type;
  late String uid;
  late Timestamp sendTime;

  EventLog({
    this.type = LogType.date,
    required this.uid,
    required this.sendTime,
  });

  factory EventLog.fromJson(QueryDocumentSnapshot<Object?> json) {
    return EventLog(
      type: LogType.values[json["type"]],
      uid: json["uid"],
      sendTime: json["sendTime"] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.index,
      "uid": uid,
      "sendTime": sendTime,
    };
  }
}

bool checkMSG(int logTypeindex) {
  return logTypeindex < LogType.enter.index;
}

// Firebase 에 로그 추가할 때, 이거 쓰면 됨
void addTextMSG(
    {required String roomID, required String uid, required String content}) {
  addLog(roomID: roomID, type: LogType.text, uid: uid, content: content);
}

void addMediaMSG(
    {required String roomID, required String uid, required String content}) {
  addLog(roomID: roomID, type: LogType.media, uid: uid, content: content);
}

void addEnterEventLog({required String roomID, required String uid}) {
  addLog(roomID: roomID, type: LogType.enter, uid: uid);
}

void addExitEventLog({required String roomID, required String uid}) {
  addLog(roomID: roomID, type: LogType.exit, uid: uid);
}

void addDateEventLog({required String roomID}) {
  addLog(roomID: roomID, type: LogType.date, uid: "");
}

void addEndEventLog({required String roomID, required String uid}) {
  addLog(roomID: roomID, type: LogType.end, uid: uid);
}

void addLog(
    {required String roomID,
    required LogType type,
    required String uid,
    String content = ""}) {
  final logColRef = FirebaseFirestore.instance
      .collection("chat")
      .doc(roomID)
      .collection("log");
  switch (type) {
    case LogType.text:
    case LogType.media:
      final MSG msg = MSG(
        type: type,
        uid: uid,
        sendTime: Timestamp.now(),
        content: content,
        react: {},
        readers: [],
      );
      logColRef.add(msg.toJson());
      break;
    case LogType.enter:
    case LogType.exit:
    case LogType.date:
    case LogType.end:
      final EventLog eventLog = EventLog(uid: uid, sendTime: Timestamp.now());
      logColRef.add(eventLog.toJson());
      break;
  }
}
