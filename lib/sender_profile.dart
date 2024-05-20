// ignore_for_file: avoid_print, prefer_final_fields, unnecessary_getters_setters, curly_braces_in_flow_control_structures

import 'package:googleapis/gmail/v1.dart';

class SenderProfile {

  bool _flagged = false;
  bool _trash = false;
  bool _permaDelete = false;
  String _sender = 'UNKNOWN SENDER';
  String _email = 'UNKNOWN EMAIL';
  String _name = 'UNKNOWN NAME';
  List<Message> _messages = [];
  List<String> _unsubLinks = [];

  bool get flagged => _flagged;
  bool get trash => _trash;
  bool get permaDelete => _permaDelete;
  String get sender => _sender;
  String get email => _email;
  String get name => _name;
  int get numberOfMessages => _messages.length;
  int get numberOfUnsubLinks => _unsubLinks.length;
  
  set flagged(bool value) => _flagged = value;
  set trash(bool value) => _trash = value;
  set permaDelete(bool value) => _permaDelete = value;

  void addMessage(Message message) { 
    _messages.add(message);
  }

  void addLink(String link) { 
    if (link != '') _unsubLinks.add(link);
  }

  SenderProfile(String sender, Message message, String link) {
    _sender = sender;
    _name = 'NO NAME FOUND';
    _email = 'NO EMAIL FOUND';
    
    addMessage(message);
    addLink(link);

    List<String> senderSplit = sender.split('<');
    if (senderSplit.length <= 1) return;
    if (senderSplit[0].length <= 1 || senderSplit[1].length <= 1) return;
    _name = senderSplit[0].substring(0, senderSplit[0].length - 1);
    _email = senderSplit[1].substring(0, senderSplit[1].length - 1);
  }
}