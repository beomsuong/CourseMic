import 'package:flutter/material.dart';

class Userdata with ChangeNotifier {
  String? _useruid;
  String get useruid => _useruid!;

  void setUserUid(String? value) {
    _useruid = value;
    notifyListeners();
  }

  initState() {
    notifyListeners();
  }
}
