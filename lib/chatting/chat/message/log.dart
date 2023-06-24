import 'package:cloud_firestore/cloud_firestore.dart';

enum LogType {
  text,
  image,
  video,
  file,
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

  late Map<String, dynamic> react;
  late List<String> readers;

  late String replyID;

  MSG({
    required this.type,
    required this.uid,
    required this.sendTime,
    this.content = "",
    required this.react,
    required this.readers,
    this.replyID = "",
  });

  factory MSG.fromJson(DocumentSnapshot<Object?> json) {
    return MSG(
      type: LogType.values[json["type"]],
      uid: json["uid"],
      sendTime: json["sendTime"] as Timestamp,
      content: json["content"],
      react: json["react"],
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
      "react": react,
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
    required this.type,
    required this.uid,
    required this.sendTime,
  });

  factory EventLog.fromJson(DocumentSnapshot<Object?> json) {
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

class EndLog {
  late LogType type;
  late String uid;
  late List<String> calUserIDs;
  late Timestamp sendTime;

  EndLog({
    required this.type,
    required this.uid,
    required this.calUserIDs,
    required this.sendTime,
  });

  factory EndLog.fromJson(DocumentSnapshot<Object?> json) {
    return EndLog(
      type: LogType.values[json["type"]],
      uid: json["uid"],
      calUserIDs: List<String>.from(json["calUserIDs"]),
      sendTime: json["sendTime"] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.index,
      "uid": uid,
      "calUserIDs": calUserIDs,
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

void addImageMSG(
    {required String roomID, required String uid, required String content}) {
  addLog(roomID: roomID, type: LogType.image, uid: uid, content: content);
}

void addVideoMSG(
    {required String roomID, required String uid, required String content}) {
  addLog(roomID: roomID, type: LogType.video, uid: uid, content: content);
}

void addFileMSG(
    {required String roomID, required String uid, required String content}) {
  addLog(roomID: roomID, type: LogType.file, uid: uid, content: content);
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
    case LogType.image:
    case LogType.video:
    case LogType.file:
      final MSG msg = MSG(
        type: type,
        uid: uid,
        sendTime: Timestamp.now(),
        content: content,
        react: {},
        readers: [uid],
      );
      logColRef.add(msg.toJson());
      break;
    case LogType.enter:
    case LogType.exit:
    case LogType.date:
      final EventLog eventLog =
          EventLog(type: type, uid: uid, sendTime: Timestamp.now());
      logColRef.add(eventLog.toJson());
      break;
    case LogType.end:
      final EndLog endLog = EndLog(
          type: type, uid: uid, calUserIDs: [], sendTime: Timestamp.now());
      logColRef.add(endLog.toJson());
      break;
  }
}
