import 'dart:async';

import 'package:flutter/material.dart' show ChangeNotifier, BuildContext;
import 'sender_profile.dart';
import 'gmail_handler.dart';
import 'auth_handler.dart';

class StateProvider extends ChangeNotifier {
  StateProvider() {
    init();
  }

  void init() {
    AuthHandler();
  }

  List<SenderProfile> _senderProfiles = [];
  List<SenderProfile> get senderProfiles => _senderProfiles;

  void signInWithGoogle() async {
    var api = await AuthHandler.initGmailApi();
    GmailHandler gmail = GmailHandler(api, 100);
    _senderProfiles = await gmail.collectEmails();
  }






  // TEMP VARS
  String statusMessage = '';
  void cancel() {}
  bool collectAll = true;
  void setCollectAll(bool value) {}
  void setNumberOfMessages(int value) {}
  void setFlagged(SenderProfile profile, bool value) {}
  void setTrash(SenderProfile profile, bool value) {}
  void setPermaDelete(SenderProfile profile, bool value) {}
  void initFlagHandler(BuildContext context) {}
}