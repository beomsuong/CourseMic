//사용자 알림메시지 능

import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FCMLocalNotification {
  FCMLocalNotification._();

  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const secureStorage = FlutterSecureStorage();

  static String currentRoomIDforNotification = "";
  static String? currentMyDeviceToken = "";

  static Future<String?> getMyDeviceToken() async {
    currentMyDeviceToken = await FirebaseMessaging.instance.getToken();
    return currentMyDeviceToken;
  }

  static sendEndProjectNotification(
      {required String roomID, required String roomName}) {
    sendNotificationWithTopic(
        topic: roomID,
        title: roomName,
        content: "$roomName 과제가 마무리되었습니다! 참여도를 정산해주세요!",
        data: {"roomID": roomID});
  }

  static sendToDoNotification(
      {required String deviceToken,
      required String roomID,
      required String roomName,
      required String task}) {
    sendNotificationToDevice(
        token: deviceToken,
        title: roomName,
        content: "할 일 : $task (이)가 추가되었습니다!",
        data: {"roomID": roomID});
  }

  static sendQuizNotification(
      {required String roomID, required String roomName}) {
    sendNotificationWithTopic(
        topic: roomID,
        title: roomName,
        content: "새로운 퀴즈가 생성되었습니다!",
        data: {"roomID": roomID});
  }

  static sendMessageNotification(
      {required String roomID,
      required String roomName,
      required String userName,
      required String message}) {
    sendNotificationWithTopic(
        topic: roomID,
        title: roomName,
        content: "$userName : $message",
        data: {"roomID": roomID});
  }

  static Future<void> sendNotificationToDevice(
      {required String token,
      required String title,
      required String content,
      Map<String, dynamic>? data}) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final body = {
      // 'notification': {'title': title, 'body': content, 'data': data},
      'notification': {
        'title': title,
        'body': content,
      },
      'to': token,
      'data': data,
    };

    final response =
        await http.post(url, headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      // Notification sent successfully
      print("성공적으로 전송되었습니다.");
      print("$title $content");
    } else {
      // Failed to send notification
      print("전송에 실패하였습니다.");
    }
  }

  static Future<void> sendNotificationWithTopic(
      {required String topic,
      required String title,
      required String content,
      Map<String, dynamic>? data}) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final body = {
      // 'notification': {'title': title, 'body': content, 'data': data},
      'notification': {
        'title': title,
        'body': content,
      },
      'to': '/topics/$topic',
      'data': data,
    };

    final response =
        await http.post(url, headers: headers, body: json.encode(body));

    if (response.statusCode == 200) {
      // Notification sent successfully
      print("성공적으로 전송되었습니다.");
      print("$title $content");
    } else {
      // Failed to send notification
      print("전송에 실패하였습니다.");
    }
  }

  // background message to payload
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    secureStorage.write(
        key: "lastNotification",
        value:
            "roomID ${message.data["roomID"]} message ${message.notification?.body}");
    // 세부 내용이 필요한 경우 추가...
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'high_importance_notification',
            importance: Importance.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['roomID'],
      );
    }
  }

  // @pragma('vm:entry-point')
  // static void backgroundHandler(NotificationResponse details) async {
  //   // 액션 추가... 파라미터는 details.payload 방식으로 전달
  //   // print("페이로드: ${details.payload!}");
  // }

  static void initializeNotification(BuildContext context) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            'high_importance_channel', 'high_importance_notification',
            importance: Importance.max));

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("@drawable/notification_icon"),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) async {
        // 알림 클릭 관련 액션
        if (currentRoomIDforNotification != details.payload &&
            currentRoomIDforNotification.isNotEmpty) {
          Navigator.of(context).pop();
        }

        var roomName = (await FirebaseFirestore.instance
                .collection('chat')
                .doc(details.payload)
                .get())
            .get('roomName');

        if (context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChatScreen(
                  roomID: details.payload!,
                  roomName: roomName,
                );
              },
            ),
          );
        }
      },
      // onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // foreground message to payload
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (currentRoomIDforNotification == message.data['roomID']) return;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: message.data['roomID'],
        );
        print(
            "foreground message alert ${notification.hashCode}, ${notification.title}, ${notification.body}");
      }
    });
  }

  static Future<String> getInitalMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    return message?.notification?.body ?? " ";
  }
}
