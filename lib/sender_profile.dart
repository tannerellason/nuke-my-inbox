// ignore_for_file: unnecessary_getters_setters

import "package:googleapis/gmail/v1.dart";
import "dart:convert";

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
    Codec<String, String> decoder = utf8.fuse(base64);
    print(sender);

    for (Message message in _messages) {
      print(message.payload!.filename);
      String? mimeType = message.payload!.mimeType;
      if (mimeType! == "text/html") {
        print(decoder.decode(message.payload!.body!.data!));
      }
      // MessagePart part = message.payload!.parts![0];
      // MessagePartBody body = part.body!;
      // String data = body.data!;
      // String decoded = decoder.decode(data);
      // print(decoded);
    }
  }

  SenderProfile(String sender, Message firstMessage) {
    _sender = sender;
    _messages = <Message>[firstMessage];
  }
}