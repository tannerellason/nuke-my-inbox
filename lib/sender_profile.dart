// ignore_for_file: avoid_print, prefer_final_fields, unnecessary_getters_setters, curly_braces_in_flow_control_structures

import "package:googleapis/gmail/v1.dart";
import "dart:convert";
import "package:html/parser.dart" as html_parser;
import "package:html/dom.dart" as html_dom;

class SenderProfile {

  bool _flagged = false;
  bool get flagged => _flagged;
  set flagged(bool flagged) {
    _flagged = flagged;
  }

  String _sender = "UNKNOWN SENDER";
  String get sender => _sender;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  List<String> _unsubLinks = [];
  List<String> get unsubLinks => _unsubLinks;

  int get numberOfMessages => _messages.length;

  void addMessage(Message messageToAdd) {
    _messages.add(messageToAdd);
  }

  void getUnsubLinks() {
    for (Message message in _messages) {
      getLink(message.payload!);
    }
  }

  void getLink(MessagePart payload) {
    String link = "";
    switch (payload.mimeType) {
      case "text/html":
        link = getHtmlData(payload.body!.data!);
        break;
    }
    print(link);
  }

  String getHtmlData(String htmlData) {
    String link = "No unsub link found";

    html_dom.Document document = html_parser.parse(htmlData);
    
    for (var node in document.nodes) {
      if (node.nodeType != html_dom.Node.TEXT_NODE) continue;
      if (!node.text!.toLowerCase().contains('unsubscribe')) continue;

      if (node.parentNode != null && node.parentNode is html_dom.Element) {
        html_dom.Element parent = node.parentNode as html_dom.Element;

        if (parent.localName == "a") link = parent.attributes['href'] ?? 'No unsub link found';
      }
    }

    return link;
  }

  SenderProfile(String sender, Message firstMessage) {
    _sender = sender;
    _messages = <Message>[firstMessage];
  }
}