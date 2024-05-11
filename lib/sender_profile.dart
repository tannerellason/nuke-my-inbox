import "package:googleapis/gmail/v1.dart";

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

  int get numberOfMessages => _messages.length;

  void addMessage(Message messageToAdd) {
    _messages.add(messageToAdd);
  }

  SenderProfile(String sender, Message firstMessage) {
    _sender = sender;
    _messages = <Message>[firstMessage];
  }
}