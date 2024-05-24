// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'sender_profile.dart';
import 'firebase_options.dart';

/*
    This class has many responsibilities:
    - Initialize and destroy Firebase Auth objects when user logs in / out
    - Initialize and destroy Gmail API instance when user logs in / out
    - Collect and process all emails into SenderProfile objects
    - Grab the unsubscribe links from messages
*/

class Gmailhandler extends ChangeNotifier {
  Gmailhandler() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) initGmailApi();
    });
  }

  String _statusMessage = 'Initializing Gmail API';
  String get statusMessage => _statusMessage;

  List<SenderProfile> _senderProfiles = []; // ignore: prefer_final_fields
  List<SenderProfile> get senderProfiles {
    return _senderProfiles;
  }

  List<SenderProfile> _flaggedProfiles      = []; //ignore: prefer_final_fields
  List<SenderProfile> _trashProfiles        = []; //ignore: prefer_final_fields
  List<SenderProfile> _permaDeleteProfiles  = []; //ignore: prefer_final_fields

  void setFlagged(SenderProfile profile, bool value) {
    if (value) {
      profile.flagged = true;
      if (!_flaggedProfiles.contains(profile)) _flaggedProfiles.add(profile);
    } else {
      profile.flagged = false;
      profile.trash = false;
      profile.permaDelete = false;
      if (_flaggedProfiles.contains(profile)) _flaggedProfiles.remove(profile);
      if (_trashProfiles.contains(profile)) _trashProfiles.remove(profile);
    }
    notifyListeners();
  }

  void setTrash(SenderProfile profile, bool value) {
    if (value) {
      profile.flagged = true;
      profile.trash = true;
      if (!_flaggedProfiles.contains(profile)) _flaggedProfiles.add(profile);
      if (!_trashProfiles.contains(profile)) _trashProfiles.add(profile);
    } else {
      profile.trash = false;
      profile.permaDelete = false;
      if (_trashProfiles.contains(profile)) _trashProfiles.remove(profile);
      if (_permaDeleteProfiles.contains(profile)) _permaDeleteProfiles.remove(profile);
    }
    notifyListeners();
  }

  void setPermaDelete(SenderProfile profile, bool value) {
    if (value) {
      profile.flagged = true;
      profile.trash = true;
      profile.permaDelete = true;
      if (!_flaggedProfiles.contains(profile)) _flaggedProfiles.add(profile);
      if (!_trashProfiles.contains(profile)) _trashProfiles.add(profile);
      if (!_permaDeleteProfiles.contains(profile)) _permaDeleteProfiles.add(profile);
    } else {
      profile.permaDelete = false;
      if (_permaDeleteProfiles.contains(profile)) _permaDeleteProfiles.remove(profile);
    }
    notifyListeners();
  }

  List<Message> _messages = [];             // ignore: prefer_final_fields
  auth.AuthClient? _client;
  GmailApi? _gmailApi;
  Profile? _profile;

  final _googleSignIn = GoogleSignIn(
    clientId: '1031401823307-n1s116c4mortggf8dchnojmo8pupleot.apps.googleusercontent.com',
    scopes: [GmailApi.mailGoogleComScope],
  );

  void processStatus(int millis, int count, int total) {
    double secondsElapsed = millis / 1000;
    double messagesPerSecond = (count / secondsElapsed);
    int messagesLeft = total - count;
    int secondsLeft = messagesLeft ~/ messagesPerSecond;
    
    String roundedMessagesPerSecond = messagesPerSecond.toStringAsPrecision(4);

    String estimatedTimeLeft = secondsLeft > 60
        ? '${secondsLeft ~/ 60} minutes, ${secondsLeft % 60} seconds remaining'
        : '$secondsLeft seconds remaining';

    String timeElapsed = secondsElapsed > 60
        ? '${secondsElapsed ~/ 60} minutes, ${secondsElapsed.toInt() % 60} seconds elapsed'
        : '${secondsElapsed.toInt()} seconds elapsed';

    _statusMessage = 'Collected $count of $total emails, $roundedMessagesPerSecond/s'
        '\n$timeElapsed'
        '\n$estimatedTimeLeft';
    notifyListeners();
  }

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    context.go('/loading');    // ignore: use_build_context_synchronously
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> cancel() {
    exit(0);
  }

  Future<void> initGmailApi() async {
    _client = await _googleSignIn.authenticatedClient();
    _gmailApi = GmailApi(_client!);
    _profile = await _gmailApi!.users.getProfile('me');
    collectEmails(false);
  }

  Future<void> collectEmails(bool collectAll, {int messagesToCollect = 50}) async {
    bool errorFound = false;

    if (collectAll) messagesToCollect = _profile!.messagesTotal!;

    int messagesToCollectPerCall = messagesToCollect < 500 
        ? messagesToCollect   // Can get all messages in a single API call
        : 500;                // CANNOT get all, as maximum is 500. Simply call max

    final stopwatch = Stopwatch();
    stopwatch.start();

    String pageToken = '';
    int count = 0;

    try {
      while (true) {
        ListMessagesResponse response = pageToken == ''
            ? await _gmailApi!.users.messages.list('me', maxResults: messagesToCollectPerCall)
            : await _gmailApi!.users.messages.list('me', maxResults: messagesToCollectPerCall, pageToken: pageToken);
        
        for (Message msg in response.messages!) {
          final Message message = await _gmailApi!.users.messages.get('me', msg.id!);

          _messages.add(message);
          count++;
          processStatus(stopwatch.elapsedMilliseconds, count, messagesToCollect);
        }
        
        if (response.resultSizeEstimate! < messagesToCollectPerCall) break;
        if (count >= messagesToCollect) break;
      }
    } on Exception catch (_, e) {
      _statusMessage = 'An error has occurred, please try again  \n$e';
      notifyListeners();
      errorFound = true;
    }

    if (!errorFound) processEmails();
  }

  Future<void> processEmails() async {
    _statusMessage = 'Processing emails';
    notifyListeners();

    for (Message message in _messages) {
      String sender = getSenderFromHeaders(message.payload!.headers!);
      String unsubLink = getLinkFromPayload(message.payload!);

      if (sender.contains(_profile!.emailAddress!)) continue;
      
      bool senderFound = false;
      for (SenderProfile profile in _senderProfiles) {
        if (profile.sender != sender) continue;

        profile.addMessage(message);
        profile.addLink(unsubLink);
        senderFound = true;
        _statusMessage = 'Added to current profile $sender';
        notifyListeners();
      }

      if (!senderFound) {
        SenderProfile profile = SenderProfile(sender, message, unsubLink);
        _senderProfiles.add(profile);
        _statusMessage = 'Added new profile $sender';
        notifyListeners();
      }
    }

    _senderProfiles.sort((a, b) => b.numberOfMessages.compareTo(a.numberOfMessages));
    _statusMessage = 'Done processing';
    notifyListeners();
  }

  String getSenderFromHeaders(List<MessagePartHeader> headers) {
    for (MessagePartHeader header in headers) {
      if (header.name == 'From') return header.value!;
    }
    return 'NO_SENDER_FOUND';
  }

  String getLinkFromPayload(MessagePart payload) {
    Codec<String, String> decoder = utf8.fuse(base64);
    switch (payload.mimeType) {
      case 'text/html':
        return getLinkFromHtml(decoder.decode(payload.body!.data!));
      case 'text/plain':
        return getLinkFromPlain(decoder.decode(payload.body!.data!));
      case 'multipart/alternative' || 'multipart/related' || 'multipart/signed' || 'multipart/mixed': 
        return getLinkFromMultipart(payload, decoder);
    }
    return '';
  }

  String getLinkFromHtml(String decodedData) {
    String link = '';

    html_dom.Document document = html_parser.parse(decodedData);

    for (var node in document.nodes) {
      if (node.nodeType != html_dom.Node.TEXT_NODE) continue;
      if (!node.text!.toLowerCase().contains('unsubscribe')) continue;

      if (node.parentNode != null && node.parentNode is html_dom.Element) {
        html_dom.Element parent = node.parentNode as html_dom.Element;
        if (parent.localName == 'a') link = parent.attributes['href'] ?? '';
      }
    }
    return link;
  }

  String getLinkFromPlain(String decodedData) {
    String link = '';
    List<String> lines = decodedData.split('\n');

    for (String line in lines) {
      if (!line.toLowerCase().contains('unsubscribe')) continue;

      RegExp regex = RegExp(r'https?://\S+');
      Iterable<Match> matches = regex.allMatches(line);

      for (Match match in matches) {
        link = match.group(0) ?? '';
      }
    }

    return link;
  }

  String getLinkFromMultipart(MessagePart payload, Codec<String, String> decoder) {
    // Strategy for multipart is just to keep going deeper in the part tree until we find
    // a text/* part

    if (payload.parts == null) return '';
    
    for (MessagePart part in payload.parts!) {
      if (part.mimeType == 'text/html') 
        return getLinkFromHtml(decoder.decode(part.body!.data!));

      if (part.mimeType == 'text/plain')
        return getLinkFromPlain(decoder.decode(part.body!.data!));

      else return getLinkFromMultipart(part, decoder);
    }

    return '';
  }
}