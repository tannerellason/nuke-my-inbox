// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:go_router/go_router.dart';

import 'sender_profile.dart';
import 'auth_handler.dart';
import 'status_handler.dart';
import 'gmail_handler.dart';


class StateProvider extends ChangeNotifier {

  late final GmailApi _gmailApi;
  String _status = '';
  List<Column> _statusWidgets = [];
  List<SenderProfile> _senderProfiles = []; // ignore: prefer_final_fields
  bool _collectAll = false;
  List<String> _flaggedLinks = []; // ignore: prefer_final_fields
  bool _collectionStarted = false;
  int _messagesToCollect = 100;
  bool _showAll = false;
  int _maxMessages = 0;

  String get status => _status;
  List<Column> get statusWidgets => _statusWidgets;
  List<SenderProfile> get senderProfiles => _senderProfiles;
  bool get collectAll => _collectAll;
  List<String> get flaggedLinks => _flaggedLinks;
  int get messagesToCollect => _messagesToCollect;
  bool get showAll => _showAll;
  int get maxMessages => _maxMessages;

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }
  void setStatusWidgets(List<Column> value) {
    _statusWidgets = value;
    notifyListeners();
  }
  void setCollectAll(bool value) {
    _collectAll = value;
    notifyListeners();
  }
  void setMessagesToCollect(int value) {
    if (value > _maxMessages) value = _maxMessages;
    _messagesToCollect = value;
    textController.text = '';
    notifyListeners();
  }
  void setFlagged(SenderProfile profile, bool value) {
    profile.setFlagged(value);
    notifyListeners();
  }
  void setTrash(SenderProfile profile, bool value) {
    profile.setTrash(value);
    notifyListeners();
  }
  void setPermaDelete(SenderProfile profile, bool value) {
    profile.setPermaDelete(value);
    notifyListeners();
  }
  void setShowAll(bool value) {
    _showAll = value;
    notifyListeners();
  }

  TextEditingController textController = TextEditingController();

  void signInWithGoogle(BuildContext context) async {
    setStatusWidgets(StatusHandler.stringStatusBuilder('Initializing gmail, please wait'));
    _gmailApi = await AuthHandler.initGmailApi();
    Profile profile = await _gmailApi.users.getProfile('me');
    _maxMessages = profile.messagesTotal!;
    context.go('/settings');     // ignore: use_build_context_synchronously
  }

  Future<void> collectEmails(BuildContext context) async {
    if (_collectionStarted) return;
    _collectionStarted = true;

    List<Message> messages = [];
    
    if (_collectAll) _messagesToCollect = _maxMessages;

    int messagesPerCall = _messagesToCollect < 500
        ? _messagesToCollect
        : 500;

    final Stopwatch collectionStopwatch = Stopwatch();
    collectionStopwatch.start();

    String? pageToken;
    int count = 0;
    while (true) {
      List<Message> listResponse = await GmailHandler.listMessages(_gmailApi, messagesPerCall, pageToken);
      for (Message message in listResponse) {
        messages.add(await GmailHandler.getMessage(_gmailApi, message.id!));

        count++;
        if (count > _messagesToCollect) break;

        setStatusWidgets(StatusHandler.collectionStatusBuilder(count, _messagesToCollect, collectionStopwatch.elapsedMilliseconds));
        notifyListeners();
      }
      if (count >= _messagesToCollect) break;
    }

    setStatusWidgets(StatusHandler.stringStatusBuilder('Please wait for emails to be processed'));
    notifyListeners();

    _senderProfiles = await GmailHandler.processMessages(messages);

    setStatusWidgets(StatusHandler.doneProcessingBuilder(context));
    notifyListeners();
  }

  void handleFlags() async {
    List<String> statusLines = [ 'Initializing...' ];
    setStatusWidgets(StatusHandler.flagHandlerStatusBuilder(statusLines)); 

    for (SenderProfile profile in _senderProfiles) {
      if (!profile.flagged) continue;

      _flaggedLinks.addAll(profile.unsubLinks);

      if (profile.permaDelete) {
        statusLines.add('Permanently deleting messages from ${profile.name} ...');
        setStatusWidgets(StatusHandler.flagHandlerStatusBuilder(statusLines));

        await GmailHandler.permaDeleteMessages(_gmailApi, profile.messages);

        statusLines.last = 'Permanently deleting messages from ${profile.name} ... Done';
        setStatusWidgets(StatusHandler.flagHandlerStatusBuilder(statusLines));
      }

      else if (profile.trash) {
        statusLines.add('Trashing messages from ${profile.name} ...');
        setStatusWidgets(StatusHandler.flagHandlerStatusBuilder(statusLines));

        for (int i = 0; i < profile.numberOfMessages; i++) {
          await GmailHandler.trashMessage(_gmailApi, profile.messages[i].id!);
        }

        statusLines.last = 'Trashing messages from ${profile.name} ... Done';
        setStatusWidgets(StatusHandler.flagHandlerStatusBuilder(statusLines));

      }
    }
  }
}