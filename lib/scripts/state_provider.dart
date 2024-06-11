// ignore_for_file: curly_braces_in_flow_control_structures

// State provider imports
import 'package:flutter/material.dart' show ChangeNotifier, BuildContext;
import 'sender_profile.dart';


// Gmail handler imports
import 'dart:io' show exit;
import 'dart:convert' show Codec, base64, utf8;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:googleapis/gmail/v1.dart';


// Auth handler imports
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'firebase_options.dart';



class StateProvider extends ChangeNotifier {

  List<SenderProfile> _senderProfiles = [];
  List<SenderProfile> get senderProfiles => _senderProfiles;

  String _status = 'first status'; // ignore: prefer_final_fields
  String get status => _status;

  void updateStatus(String status) {
    _status = status;
    print('updated status to $_status');
    notifyListeners();
  }

  void signInWithGoogle() async {
    var api = await _AuthHandler.initGmailApi();
    _GmailHandler gmail = _GmailHandler(api, 100);
    _senderProfiles = await gmail.collectEmails();
  }

  // TEMP VARS
  void cancel() {}
  bool collectAll = true;
  void setCollectAll(bool value) {}
  void setNumberOfMessages(int value) {}
  void setFlagged(SenderProfile profile, bool value) {}
  void setTrash(SenderProfile profile, bool value) {}
  void setPermaDelete(SenderProfile profile, bool value) {}
  void initFlagHandler(BuildContext context) {}
}


class _GmailHandler extends StateProvider {
  late final GmailApi _gmailApi;
  late final int _messagesToCollect;

  _GmailHandler(GmailApi api, int messagesToCollect) {
    _gmailApi = api;
    _messagesToCollect = messagesToCollect;
    init();
  }

  void init() {
    print('collecting');
    updateStatus('collecting');
    notifyListeners();
    collectEmails();
  }

  Future<List<SenderProfile>> collectEmails() async {
    List<Message> messages = [];

    int messagesPerCall = _messagesToCollect < 500
        ? _messagesToCollect
        : 500;

    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    String? pageToken;
    int count = 0;
    try {
      while (true) {
        ListMessagesResponse response = 
          await _gmailApi.users.messages.list('me', maxResults: messagesPerCall, pageToken: pageToken);
        
        for (Message msg in response.messages!) {
          final Message message = await _gmailApi.users.messages.get('me', msg.id!);
          messages.add(message);
          count++;
        }

        if (response.resultSizeEstimate! < messagesPerCall) break;
        if (count >= _messagesToCollect) break;
      }
    } on Exception catch (_) {
      exit(0);
    }

    return _processMessages(messages);
  }

  Future<List<SenderProfile>> _processMessages(List<Message> messages) async {
    List<SenderProfile> profiles = [];

    for (Message message in messages) {
      String sender = getSenderFromMessage(message);
      String name = getNameFromSender(sender);
      String email = getEmailFromSender(sender);
      String link = getLinkFromPayload(message.payload!);

      bool senderFound = false;
      for (SenderProfile profile in profiles) {
        if (profile.sender != sender) continue;

        profile.addMessage(message);
        profile.addLink(link);
        senderFound = true;
        
      }

      if (!senderFound) {
        SenderProfile profile = SenderProfile(sender, name, email, message, link);
        profiles.add(profile);
        // status jank here
      }
    }

    profiles.sort((a, b) => b.numberOfMessages.compareTo(a.numberOfMessages));
    return profiles;
  }

  String getSenderFromMessage(Message message) {
    List<MessagePartHeader> headers = message.payload!.headers!;
    for (MessagePartHeader header in headers) {
      if (header.name == 'From') return header.value!;
    }

    return 'NO_SENDER_FOUND';
  }

  String getNameFromSender(String sender) {
    List<String> senderSplit = sender.split('<');
    if (senderSplit.length <= 1 || senderSplit[0].length <= 1) return 'NO_NAME_FOUND';
    String name = senderSplit[0].substring(0, senderSplit[0].length - 1);

    if (name.startsWith('"') || name.startsWith("'")) name = name.substring(1);
    if (name.endsWith('"') || name.endsWith("'")) name = name.substring(0, name.length - 2);
    return name;
  }

  String getEmailFromSender(String sender) {
    List<String> senderSplit = sender.split('<');
    if (senderSplit.length <= 1 || senderSplit[1].length <= 1) return 'NO_EMAIL_FOUND';
    String email = senderSplit[1].substring(0, senderSplit[1].length - 1);

    if (email.startsWith('"') || email.startsWith("'")) email = email.substring(1);
    if (email.endsWith('"') || email.endsWith("'")) email = email.substring(0, email.length - 2);
    return email;
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


class _AuthHandler {

  static Future<GmailApi> initGmailApi() async {
    String? name;
    if (kIsWeb) {}
    else if (Platform.isIOS) name = 'NukeMyInbox';

    Firebase.initializeApp(
      name: name,
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await signInWithGoogle();
    final AuthClient? client = await _googleSignIn.authenticatedClient();
    final GmailApi gmailApi = GmailApi(client!);
    return gmailApi;
  }

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: DefaultFirebaseOptions.clientId,
    scopes: [GmailApi.mailGoogleComScope],
  );

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth 
      = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}