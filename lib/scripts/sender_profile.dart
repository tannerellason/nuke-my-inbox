// ignore_for_file: avoid_print, prefer_final_fields, unnecessary_getters_setters, curly_braces_in_flow_control_structures

// This is how all information from the GMail API is stored.
// Each instance of this class represents a different Email address
// that the user has gotten an email from.

class SenderProfile {

  bool _flagged = false;
  bool _trash = false;
  bool _permaDelete = false;
  bool _handled = false;
  String _sender = 'UNKNOWN SENDER';
  String _email = 'UNKNOWN EMAIL';
  String _name = 'UNKNOWN NAME';
  List<String> _messageIds = [];
  List<String> _unsubLinks = [];
  late final DateTime _mostRecentMessageTime;
  late final String _snippet;

  bool get flagged => _flagged;
  bool get trash => _trash;
  bool get permaDelete => _permaDelete;
  bool get handled => _handled;
  String get sender => _sender;
  String get email => _email;
  String get name => _name;
  String get time => SenderProfileHelper.formatTime(_mostRecentMessageTime);
  String get snippet => _snippet;
  int get numberOfMessages => _messageIds.length;
  int get numberOfUnsubLinks => _unsubLinks.length;

  List<String> get unsubLinks => _unsubLinks;
  List<String> get messageIds => _messageIds;

  set handled (bool value) => _handled = value;
  
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

  void addMessageId(String messageId) { 
    _messageIds.add(messageId);
  }

  void addLink(String link) { 
    if (link != '') _unsubLinks.add(link);
  }

  SenderProfile(String sender, String name, String email, String messageId, String link, DateTime mostRecentMessageTime, String mostRecentSnippet) {
    _sender = sender;
    _name = name;
    _email = email;
    _mostRecentMessageTime = mostRecentMessageTime;
    _snippet = mostRecentSnippet;
    
    addMessageId(messageId);
    addLink(link);
  }
}

class SenderProfileHelper {
  static String getMonthFromInt(int month) {
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

  static String getWeekDayFromInt(int weekday) {
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

  static String ensureDoubleDigit(int input) {
    return input < 10
      ? '0$input'
      : '$input';
  }

  static String formatTime(DateTime input) {
    String minute = SenderProfileHelper.ensureDoubleDigit(input.minute);
    String hour   = input.hour.toString();

    String weekday  = SenderProfileHelper.getWeekDayFromInt(input.weekday);
    int day         = input.day;
    String month    = SenderProfileHelper.getMonthFromInt(input.month);
    int year        = input.year;

    String date = '$weekday, $month $day, $year';
    String time = '$hour:$minute';

    return '$date at $time';
  }
}