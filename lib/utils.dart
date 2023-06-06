import 'package:cloud_firestore/cloud_firestore.dart';

String calculateDate(Timestamp value) {
  DateTime now = DateTime.now();
  Duration diff = value.toDate().difference(now);

  return "${diff.inHours.abs() < 24 ? diff.inHours : diff.inDays}";
}
