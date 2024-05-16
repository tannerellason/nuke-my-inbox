// ignore_for_file: avoid_print, prefer_final_fields, unnecessary_getters_setters, curly_braces_in_flow_control_structures

import "package:googleapis/gmail/v1.dart";

class SenderProfile {

  bool _flagged = false;
  bool get flagged => _flagged;
  set flagged(bool value) => _flagged = value;

  String _sender = "UNKNOWN SENDER"; // Commonly 
  String get sender => _sender;

  String _email = "UNKNOWN EMAIL";
  String get email => _email;

  String _name = "UNKNOWN NAME";
  String get name => _name;

  List<Message> _messages = [];
  void addMessage(Message message) => { _messages.add(message) };
  int get numberOfMessages => _messages.length;

  List<String> _unsubLinks = [];
  void addLink(String link) => { if (link != '') _unsubLinks.add(link) };
  int get numberOfUnsubLinks => _unsubLinks.length;


  SenderProfile(String sender, Message message, String link) {
    _sender = sender;
    _flagged = true;
    _name = "NO NAME FOUND";
    _email = "NO EMAIL FOUND";
    
    addMessage(message);
    addLink(link);

    List<String> senderSplit = sender.split('<');
    if (senderSplit.length <= 1) return;
    if (senderSplit[0].length <= 1 || senderSplit[1].length <= 1) return;
    _name = senderSplit[0].substring(0, senderSplit[0].length - 1);
    _email = senderSplit[1].substring(0, senderSplit[1].length - 1);
  }
}