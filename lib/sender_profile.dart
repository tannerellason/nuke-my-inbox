// ignore_for_file: avoid_print, prefer_final_fields, unnecessary_getters_setters, curly_braces_in_flow_control_structures

import "package:googleapis/gmail/v1.dart";
import "dart:convert";
import "package:html/parser.dart" as html_parser;
import "package:html/dom.dart" as html_dom;

class SenderProfile {

  Codec<String, String> decoder = utf8.fuse(base64);

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

    if (unsubLinks.isEmpty) return;
    print(_sender);
    for (String link in unsubLinks) print(link);
  }

void getLink(MessagePart payload) {
  String link = "${payload.mimeType}";
  switch (payload.mimeType) {
    case "text/html":
      link = getHtmlLink(decoder.decode(payload.body!.data!));
      break;
    case "text/plain":
      link = getPlainLink(decoder.decode(payload.body!.data!));
      break;
    case "multipart/alternative" || "multipart/mixed" || "multipart/related":
      link = getMultipartLink(payload);
      break;
  }

  if (!unsubLinks.contains(link) && link != "No unsub link found") unsubLinks.add(link);
}

String getPlainLink(String plainText) {
  String link = "No unsub link found";
  List<String> lines = plainText.split('\n');

  for (String line in lines) {
    if (!line.toLowerCase().contains('unsubscribe')) continue;

    RegExp regex = RegExp(r'https?://\S+');
    Iterable<Match> matches = regex.allMatches(line);

    for (Match match in matches) {
      link = match.group(0) ?? "No unsub link found";
    }
  }

  return link;
}

String getHtmlLink(String htmlData) {
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

String getMultipartLink(MessagePart payload) {
  for (MessagePart part in payload.parts!) {
    if (part.mimeType == 'text/html') 
      return getHtmlLink(decoder.decode(part.body!.data!));

    else if (part.mimeType == 'text/plain')
      return getPlainLink(decoder.decode(part.body!.data!));

    else return getMultipartLink(part);
  }
  return "No unsub link found";
}

  SenderProfile(String sender, Message firstMessage) {
    _sender = sender;
    _messages = <Message>[firstMessage];
    _flagged = true;
  }
}