// ignore_for_file: curly_braces_in_flow_control_structures

// State provider imports
import 'dart:io' show exit;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'sender_profile.dart';
import 'auth_handler.dart';

// Gmail handler imports
import 'dart:convert' show Codec, base64, utf8;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:googleapis/gmail/v1.dart';


class StateProvider extends ChangeNotifier {
  List<Column> _statusWidgets = [
    const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Initializing')]
        )
      ]
    )
  ]; // ignore: prefer_final_fields
  List<Column> get statusWidgets => _statusWidgets;
  void setStatusWidgets(List<Column> value) {
    _statusWidgets = value;
    notifyListeners();
  }

  List<SenderProfile> _senderProfiles = [];
  List<SenderProfile> get senderProfiles => _senderProfiles;

  bool _collectAll = true;
  bool get collectAll => _collectAll;
  void setCollectAll(bool value) {
    _collectAll = value;
    notifyListeners();
  }

  List<String> _flaggedLinks = []; // ignore: prefer_final_fields
  List<String> get flaggedLinks => _flaggedLinks;

  void signInWithGoogle(BuildContext context) async {
    _gmailApi = await AuthHandler.initGmailApi();
    _senderProfiles = await collectEmails(context);
  }

  void setFlagged(SenderProfile profile, bool value) {
    if (value) {
      profile.flagged = true;
    } else {
      profile.flagged = false;
      profile.trash = false;
      profile.permaDelete = false;
    }
    notifyListeners();
  }

  void setTrash(SenderProfile profile, bool value) {
    if (value) {
      profile.flagged = true;
      profile.trash = true;
    } else {
      profile.trash = false;
      profile.permaDelete = false;
    }
    notifyListeners();
  }

  void setPermaDelete(SenderProfile profile, bool value) {
    if (value) {
      profile.flagged = true;
      profile.trash = true;
      profile.permaDelete = true;
    } else {
      profile.permaDelete = false;
    }
    notifyListeners();
  }

  void initFlagHandler(BuildContext context) {
    context.go('/loading');
    addToStatus('Performing chosen actions...');

    for (SenderProfile profile in _senderProfiles) {
      if (profile.flagged) {
        addToStatus('Performing actions for ${profile.name}');
        _flaggedLinks.addAll(profile.unsubLinks);
      }

      if (profile.permaDelete)  permaDeleteMessages(profile.messages);
      else if (profile.trash)   trashMessages(profile.messages);
    }
  }







  // GMAIL HANDLER STARTS HERE
  late final GmailApi _gmailApi;
  bool collectionStarted = false;
  int _messagesToCollect = 100;
  void setNumberOfMessages(int value) {
    _messagesToCollect = value;
    notifyListeners();
  }

  Stopwatch stopwatch = Stopwatch();
  int trashCallsPerSecond = 0;

  Future<List<SenderProfile>> collectEmails(BuildContext context) async {
    if (collectionStarted) return [];
    collectionStarted = true;

    List<Message> messages = [];
    
    if (_collectAll) {
      Profile profile = await _gmailApi.users.getProfile('me');
      _messagesToCollect = profile.messagesTotal!;
    }

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
          debugPrint('Collected email #$count of $_messagesToCollect');
          if (count > _messagesToCollect) break;
          collectionStatusBuilder(count, _messagesToCollect, stopwatch.elapsedMilliseconds);
        }

        if (response.resultSizeEstimate! < messagesPerCall) break;
        if (count >= _messagesToCollect) break;
      }
    } on Exception catch (_) {
      exit(0);
    }

    return _processMessages(messages, context);
  }

  Future<List<SenderProfile>> _processMessages(List<Message> messages, BuildContext context) async {
    stringStatusBuilder('Collection done, processing');
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

    _statusWidgets = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Done processing')
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 30)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.go('/flagger'),
                child: const Text('Next page'),

              )
            ]
          )
        ]
      )
    ];

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

  void permaDeleteMessages(List<Message> messages) {
    List<String> idsToDelete = [];

    for (Message message in messages) {
      idsToDelete.add(message.id!);
    }

    BatchDeleteMessagesRequest request = BatchDeleteMessagesRequest(ids: idsToDelete);
    _gmailApi.users.messages.batchDelete(request, 'me');
    addToStatus('Permanently deleted ${idsToDelete.length} messages');
  }

  void trashMessages(List<Message> messages) {
    int currentSecond = (stopwatch.elapsedMilliseconds ~/ 1000);
    int index = 0;
    bool flag = false;
    while (index < messages.length) {
      if (stopwatch.elapsedMilliseconds ~/ 1000 == currentSecond && trashCallsPerSecond >= 20) {
        flag = true;
        continue;
      } else if (flag) {
        currentSecond = stopwatch.elapsedMilliseconds ~/ 1000;
        trashCallsPerSecond = 0;
        flag = false;
      }

      _gmailApi.users.messages.trash('me', messages[index].id!);
      addToStatus('Deleted msg ${index + 1} of ${messages.length} (RATE LIMITED BY GMAIL)');
      trashCallsPerSecond++;
      index++;
    }
  }

  void collectionStatusBuilder(int numberCollected, int totalMessages, int millisElapsed) {
    double secondsElapsed = millisElapsed / 1000;
    double collectionsPerSecond = numberCollected / secondsElapsed;
    String collectionsPerSecondString = collectionsPerSecond.toStringAsPrecision(4);

    String timeElapsed = secondsElapsed > 60
        ? '${secondsElapsed ~/ 60} minutes, ${(secondsElapsed % 60).toStringAsPrecision(4)} seconds elapsed'
        : '$secondsElapsed seconds elapsed';
    
    int messagesRemaining = totalMessages - numberCollected;
    int estimatedSecondsRemaining = messagesRemaining ~/ collectionsPerSecond;
    String estimatedTimeRemaining = estimatedSecondsRemaining > 60
        ? '${estimatedSecondsRemaining ~/ 60} minutes, ${estimatedSecondsRemaining % 60} seconds remaining'
        : '$estimatedSecondsRemaining seconds remaining';

    List<Column> widgetList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('$numberCollected collected of $totalMessages, $collectionsPerSecondString/s')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(timeElapsed)]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(estimatedTimeRemaining)],
          )
        ]
      )
    ];

    setStatusWidgets(widgetList);
  }

  void stringStatusBuilder(String statusMessage) {
    List<Column> widgetList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(statusMessage)]
          )
        ]
      )
    ];

    setStatusWidgets(widgetList);
  }

  void addToStatus(String message) {
    final Column column = _statusWidgets[0];
    List<Widget> children = column.children;
    
    Widget widgetToInsert = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(message)]
    );

    children.insert(0, widgetToInsert);
    notifyListeners();
  }
}