import 'package:capston/const.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getMyDeviceToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print("내 디바이스 토큰: $token");
  return token ?? "";
}

Future<void> sendNotificationToDevice(
    {required String deviceToken,
    required String title,
    required String content,
    required Map<String, dynamic> data}) async {
  final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final body = {
    'notification': {'title': title, 'body': content, 'data': data},
    'to': deviceToken,
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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // 세부 내용이 필요한 경우 추가...
}

@pragma('vm:entry-point')
void backgroundHandler(NotificationResponse details) {
  // 액션 추가... 파라미터는 details.payload 방식으로 전달
}

void initializeNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel', 'high_importance_notification',
          importance: Importance.max));

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (details) {
      // 액션 추가...
    },
    onDidReceiveBackgroundNotificationResponse: backgroundHandler,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Foregorund Alert
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
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
          payload: message.data['test_paremeter1']);
      print("foreground message alert");
    }
  });

  // Background Alert
  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    // 액션 부분 -> 파라미터는 message.data['test_parameter1'] 이런 방식으로...
    RemoteNotification? notification = message.notification;
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification!.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'high_importance_notification',
            importance: Importance.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['test_paremeter1']);
    print("background message alert");
  }
}

// sendNotificationToDevice(
//                   deviceToken: myDeviceToken,
//                   title: '푸시 알림 테스트',
//                   content: '푸시 알림 내용',
//                   data: {'test_parameter1': 1, 'test_parameter2': '테스트1'}),