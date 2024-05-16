//ignore_for_file: avoid_print, prefer_final_fields, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'sender_profile.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  String _statusMessage = "Initializing...";
  String get statusMessage => _statusMessage;
  set statusMessage(String value) {
    _statusMessage = value;
    notifyListeners();
  }

  List<SenderProfile>? _senderProfiles;

  Future<void> processEmails(GmailApi gmailApi, List<Message> messages) async {
    Profile profile = await gmailApi.users.getProfile("me");
    String userEmail = profile.emailAddress!;
    List<String> mimeTypes = [];

    List<SenderProfile> senders = [];
    statusMessage = "Processing emails...";

    for (Message message in messages) {
      String sender = getSender(message);
      String mimeType = message.payload!.mimeType!;
      if (!mimeTypes.contains(mimeType)) mimeTypes.add(mimeType);
      if (sender.contains(userEmail)) continue;
      bool flag = false;
      for (int i = 0; i < senders.length; i++) {
        SenderProfile profile = senders[i];
        if (profile.sender != sender) continue;
        profile.addMessage(message);
        while (i != 0 && senders[i - 1].numberOfMessages < senders[i].numberOfMessages) {
          var temp = senders[i];
          senders[i] = senders[i - 1];
          senders[i - 1] = temp;
          i--;
        }
        flag = true;
        break;
      }
      if (!flag) {
        SenderProfile profile = SenderProfile(sender, message);
        senders.add(profile);
      }
    }
    statusMessage = 'Done collecting and processing';

    senderProfiles = senders;
    _doneProcessing = true;
    for (var sender in senders) {
      sender.getUnsubLinks();
    }
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );

    FirebaseAuth.instance.userChanges().listen((user) {

      // If user is logged in:
      if (user != null) {
        loggedIn = true;
        user = user;
        initGmailApi();
      }

      // If user is not logged in:
      else {
        loggedIn = false;
        user = null;
      }
    });
  }
}

