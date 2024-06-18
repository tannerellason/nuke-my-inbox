// ignore_for_file: avoid_print, prefer_final_fields, unnecessary_getters_setters, curly_braces_in_flow_control_structures

// This is how all information from the GMail API is stored.
// Each instance of this class represents a different Email address
// that the user has gotten an email from.

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
  late final DateTime _mostRecentMessageTime;

  bool get flagged => _flagged;
  bool get trash => _trash;
  bool get permaDelete => _permaDelete;
  String get sender => _sender;
  String get email => _email;
  String get name => _name;
  int get numberOfMessages => _messages.length;
  int get numberOfUnsubLinks => _unsubLinks.length;

  String get time {
    String minute = _mostRecentMessageTime.minute.toString();
    if (_mostRecentMessageTime.minute < 10) {
      print(minute);
      minute = '0$minute';
      print(minute);
    }
    String hour   = _mostRecentMessageTime.hour.toString();

    String time = '$hour:$minute';

    String weekday  = getWeekDay(_mostRecentMessageTime.weekday);
    int day         = _mostRecentMessageTime.day;
    String month    = getMonth(_mostRecentMessageTime.month);
    int year        = _mostRecentMessageTime.year;

    String date = '$weekday, $month $day, $year';

    return '$date at $time';
  }

  List<String> get unsubLinks => _unsubLinks;
  List<Message> get messages => _messages;
  
  void setFlagged(bool value) {
    if (value) _flagged = true;
    else {
      _flagged = false;
      _trash = false;
      _permaDelete = false;
    }
  }

  void setTrash(bool value) {
    if (value) {
      _flagged = true;
      _trash = true;
    } else {
      _trash = false;
      _permaDelete = false;
    }
  }

  void setPermaDelete(bool value) {
    if (value) {
      _flagged = true;
      _trash = true;
      _permaDelete = true;
    } else _permaDelete = false;
  }

  void addMessage(Message message) { 
    _messages.add(message);
  }

  void addLink(String link) { 
    if (link != '') _unsubLinks.add(link);
  }

  SenderProfile(String sender, String name, String email, Message message, String link, DateTime mostRecentMessageTime) {
    _sender = sender;
    _name = name;
    _email = email;
    _mostRecentMessageTime = mostRecentMessageTime;
    
    addMessage(message);
    addLink(link);
  }

  String getMonth(int month) {
    switch(month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  String getWeekDay(int weekday) {
    switch(weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}