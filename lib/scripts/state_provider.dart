// ignore_for_file: curly_braces_in_flow_control_structures

// State provider imports
import 'package:flutter/material.dart' show ChangeNotifier, BuildContext;
import 'sender_profile.dart';
import 'gmail_handler.dart';
import 'auth_handler.dart';

class StateProvider extends ChangeNotifier {

  List<SenderProfile> _senderProfiles = [];
  List<SenderProfile> get senderProfiles => _senderProfiles;

  String _status = 'Please wait for emails to be collected and processed';
  String get status => _status;

  bool _collectAll = true;
  bool get collectAll => _collectAll;
  void setCollectAll(bool value) {
    _collectAll = value;
    notifyListeners();
  }

  int _numberOfMessages = 100;
  int get numberOfMessages => _numberOfMessages;
  void setNumberOfMessages(int value) {
    _numberOfMessages = value;
    notifyListeners();
  }

  void signInWithGoogle() async {
    var api = await AuthHandler.initGmailApi();
    GmailHandler gmail = GmailHandler(api, _numberOfMessages, _collectAll);
    _senderProfiles = await gmail.collectEmails();
    _status = 'Done processing';
    notifyListeners();
  }

  // TEMP VARS
  void setFlagged(SenderProfile profile, bool value) {}
  void setTrash(SenderProfile profile, bool value) {}
  void setPermaDelete(SenderProfile profile, bool value) {}
  void initFlagHandler(BuildContext context) {}
}