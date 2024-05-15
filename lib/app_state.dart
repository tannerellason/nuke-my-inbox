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

  List<SenderProfile>? senderProfiles;
  
  bool _doneProcessing = false;
  bool get doneProcessing => _doneProcessing;
  set doneProcessing(bool value) {
    _doneProcessing = value;
    notifyListeners();
  }

  bool _loggedIn = false; // Authentication does NOT persist between sessions. This is on purpose.
  bool get loggedIn => _loggedIn;
  set loggedIn(bool value) {
    _loggedIn = value;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;
  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  // 1: Trash, 2: Perma delete, 3: Starred for future delete, 4: Nothing
  // ignore: unused_field
  int _currentDestination = 1;
  int get currentDestination => _currentDestination;
  set currentDestination(int value) {
    _currentDestination = value;
    notifyListeners();
  }

  Set<int> _currentDestinationSet = {1};
  Set<int> get currentDestinationSet => _currentDestinationSet;
  set currentDestinationSet(Set<int> value) {
    _currentDestinationSet = value;
    notifyListeners();
  }

  bool _compileInTextFile = false;
  bool get compileInTextFile => _compileInTextFile;
  set compileInTextFile(bool value) {
    _compileInTextFile = value;
    notifyListeners();
  }

  bool _attemptUnsubscribes = false;
  bool get attemptUnsubscribes => _attemptUnsubscribes;
  set attemptUnsubscribes(bool value) {
    _attemptUnsubscribes = value;
    notifyListeners();
  }

  bool _blockSenders = false;
  bool get blockSenders => _blockSenders;
  set blockSenders(bool value) {
    _blockSenders = value;
    notifyListeners();
  }

  final _googleSignIn = GoogleSignIn(
    clientId: '1031401823307-n1s116c4mortggf8dchnojmo8pupleot.apps.googleusercontent.com',
    scopes: <String>[GmailApi.mailGoogleComScope],
  );

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    statusMessage = "Signing in...";
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    _loggedIn = true;
    var ret = await FirebaseAuth.instance.signInWithCredential(credential);
    context.go('/settings');
    return ret;
  }

  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    _loggedIn = false;
    context.go("/");
  }

  Future<void> initGmailApi() async {
    statusMessage = "Connecting to Gmail API...";

    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    assert(client != null, 'Authenticated client missing');

    final GmailApi gmailApi = GmailApi(client!);

    collectEmails(gmailApi);
  }

  Future<void> collectEmails(GmailApi gmailApi) async {

    Profile profile = await gmailApi.users.getProfile("me");
    int profileMessages = profile.messagesTotal!;

    int userSetMessages = 3000;

    bool collectAll = true; // Allow user to control this eventually

    int messageCount = 0;
    if (collectAll) messageCount = profileMessages; // ignore: dead_code
    else messageCount = userSetMessages; // ignore: dead_code

    final stopwatch = Stopwatch();
    stopwatch.start();
    List<Message> messages = [];

    String? pageToken = "";

    int emailsToCollectPerCall = 0;
    if (messageCount < 500) {
      emailsToCollectPerCall = messageCount;
    } else {
      emailsToCollectPerCall = 500;
    }

    int count = 0;

    while (true) {
      if (loggedIn == false) break;

      ListMessagesResponse response;

      pageToken == ""
      ? response = await gmailApi.users.messages.list("me", maxResults: emailsToCollectPerCall)
      : response = await gmailApi.users.messages.list("me", maxResults: emailsToCollectPerCall, pageToken: pageToken);

      pageToken = response.nextPageToken;

      for (Message message in response.messages!) {
        final Message msg =
            await gmailApi.users.messages.get("me", message.id!, format: "full");
        
        messages.add(msg);
        count++;
        double secondsElapsed = stopwatch.elapsedMilliseconds / 1000;
        double messagesPerSecond = (count / secondsElapsed);

        int messagesLefft = messageCount - count;
        int secondsLeft = messagesLefft ~/ messagesPerSecond;

        String estimatedTimeLeft = "";
        if (secondsLeft > 60) {
          estimatedTimeLeft = '${secondsLeft ~/ 60} minutes, ${secondsLeft % 60} seconds remaining';
        } else {
          estimatedTimeLeft = '$secondsLeft seconds remaining';
        }

        String timeElapsed = "";
        if (secondsElapsed > 60) {
          timeElapsed = '${secondsElapsed ~/ 60} minutes, ${secondsElapsed.toInt() % 60} seconds elapsed';
        } else {
          timeElapsed = '${secondsElapsed.toInt()} seconds elapsed';
        }

        statusMessage = 'Collected $count of $messageCount emails, ${messagesPerSecond.toStringAsPrecision(3)}/s'
            '\n$timeElapsed'
            '\n$estimatedTimeLeft';
      }

      if (response.resultSizeEstimate! < emailsToCollectPerCall) break; // KEEP
      if (count >= messageCount) break;
    } 

    if (loggedIn == true) processEmails(gmailApi, messages);
  }

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

  String getSender(Message msg) {
    List<MessagePartHeader> headers = msg.payload!.headers!;
    for (MessagePartHeader header in headers) {
      if (header.name != "From") continue;
      return header.value!;
    }
    return ("NO_SENDER_FOUND");
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

