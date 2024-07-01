// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:go_router/go_router.dart';

import 'sender_profile.dart';
import 'auth_handler.dart';
import 'status_handler.dart';
import 'gmail_handler.dart';


class StateProvider extends ChangeNotifier {

  GmailApi? _gmailApi;
  String _status = '';
  List<Column> _statusWidgets = [];
  List<SenderProfile> _senderProfiles = []; // ignore: prefer_final_fields
  bool _collectAll = false;
  List<String> _flaggedLinks = []; // ignore: prefer_final_fields
  bool _collectionStarted = false;
  int _messagesToCollect = 100;
  bool _showAll = false;
  int _maxMessages = 0;
  String _confirmation = '';
  bool _onFlagger = true;

  String get status => _status;
  List<Column> get statusWidgets => _statusWidgets;
  List<SenderProfile> get senderProfiles => _senderProfiles;
  bool get collectAll => _collectAll;
  List<String> get flaggedLinks => _flaggedLinks;
  int get messagesToCollect => _messagesToCollect;
  bool get showAll => _showAll;
  int get maxMessages => _maxMessages;
  String get confirmation => _confirmation;
  bool get validConfirmation => _confirmation == 'DELETE';
  bool get onFlagger => _onFlagger;

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
  void setConfirmation(String value) {
    _confirmation = value;
    notifyListeners();
  }
  void setOnFlagger(bool value) {
    _onFlagger = value;
    notifyListeners();
  }

  TextEditingController textController = TextEditingController();

  void signInWithGoogle(BuildContext context) async {
    setStatusWidgets(StatusHandler.stringStatusBuilder('Initializing gmail, please wait'));
    _gmailApi = await AuthHandler.initGmailApi();
    Profile profile = await _gmailApi!.users.getProfile('me');
    _maxMessages = profile.messagesTotal!;
    context.go('/settings');     // ignore: use_build_context_synchronously
  }

  void signOut(BuildContext context) async {
    await AuthHandler.signOut();
    _gmailApi = null;
    _maxMessages = 0;
    context.pop(); // ignore: use_build_context_synchronously
  }

  Future<void> collectEmails(BuildContext context) async {
    if (_collectionStarted) return;
    _collectionStarted = true;

    List<int> messageTimes = [];
    int millisForLast25 = 0;
    
    if (_collectAll) _messagesToCollect = _maxMessages;

    int messagesPerCall = _messagesToCollect < 500
        ? _messagesToCollect
        : 500;

    final Stopwatch collectionStopwatch = Stopwatch();
    collectionStopwatch.start();

    String? pageToken;
    int count = 0;
    while (true) {
      
      List<Message> listResponse = await GmailHandler.listMessages(_gmailApi!, messagesPerCall, pageToken);

      for (Message msg in listResponse) {
        Message message = await GmailHandler.getMessage(_gmailApi!, msg.id!);

        String sender  = Utils.getSenderFromMessage(message);
        String name    = Utils.getNameFromSender(sender);
        String email   = Utils.getEmailFromSender(sender);
        String link    = Utils.getLinkFromPayload(message.payload!);
        DateTime time  = Utils.getDateTimeFromMessage(message);
        String snippet = message.snippet!;

        if (snippet.length >= 50) snippet = '${snippet.substring(0, 49)}...';

        bool senderFound = false;
        for (SenderProfile profile in _senderProfiles) {
          if (profile.sender != sender) continue;

          profile.addMessageId(message.id!);
          if (!profile.unsubLinks.contains(link)) profile.addLink(link);
          senderFound = true;
        }

        if (!senderFound)
          _senderProfiles.add(SenderProfile(sender, name, email, message.id!, link, time, snippet));

        messageTimes.insert(0, collectionStopwatch.elapsedMilliseconds);
        if (messageTimes.length > 25) {
          millisForLast25 = messageTimes[0] - messageTimes[24];
        }

        count++;
        if (count > _messagesToCollect) break;

        setStatusWidgets(StatusHandler.collectionStatusBuilder(count, _messagesToCollect, collectionStopwatch.elapsedMilliseconds, millisForLast25));
        notifyListeners();
      }

      if (count >= _messagesToCollect) break;
    }

    _senderProfiles.sort((a, b) => b.numberOfMessages.compareTo(a.numberOfMessages));

    setStatusWidgets(StatusHandler.doneProcessingBuilder(context)); // ignore: use_build_context_synchronously
  }

  List<String> messageIds = [];
  bool trashing = false;

  void trashMessages(SenderProfile profile) {
    profile.handled = true;
    setOnFlagger(false);
    messageIds.addAll(profile.messageIds);
    trashMessagesRecursively(profile, 0);
  }

  void trashMessagesRecursively(SenderProfile profile, int depth) async {
    if (depth == 0 && trashing == true) return;
    trashing = true;
    if (messageIds.isEmpty) {
      trashing = false;
      setStatus('Done trashing messages. It is safe to leave.');
      return;
    }

    String messageId = messageIds[0];
    await GmailHandler.trashMessage(_gmailApi!, messageId);

    setStatus('Still trashing messages. Do not close this tab!');

    messageIds.removeAt(0);
    trashMessagesRecursively(profile, depth + 1);
  }

  Future<void> permaDeleteMessages(SenderProfile profile) async {
    await GmailHandler.permaDeleteMessages(_gmailApi!, profile.messageIds);
    profile.handled = true;
    _confirmation = '';
    notifyListeners();
  }

  void dismissSender(SenderProfile profile) {
    profile.handled = true;
    notifyListeners();
  }

  List<Widget> buildUnsubLinks(SenderProfile profile) {
    return StatusHandler.unsubLinksBuilder(profile.unsubLinks);
  }
}