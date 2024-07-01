// ignore_for_file: curly_braces_in_flow_control_structures, unused_local_variable

import 'dart:convert';
import 'package:googleapis/gmail/v1.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'dart:async';

class GmailHandler {

  // These are to ensure that we don't overload the API.
  // We are allowed 250 total 'quota units' per second.
  // List, Get, and Trash all cost 5.
  // BatchDelete costs 50.
  // 
  // I've had problems in testing when trash QUICKLY overwhelms
  // the API, and these are to prevent that, at the cost of performance.
  // 
  // List and get all have a delay of 0 because I haven't seen them
  // overwhelm the API yet. Any issues should be reported.
  static const Duration delayBetweenLists = Duration(milliseconds: 0);
  static const Duration delayBetweenGets = Duration(milliseconds: 0);
  static const Duration delayBetweenBatchDeletes = Duration(milliseconds: 200);
  static const Duration delayBetweenTrashes = Duration(milliseconds: 20);

  static Future<List<Message>> listMessages(GmailApi api, int messagesToList, String? pageToken) async {
    ListMessagesResponse? response;
    await Future.delayed(delayBetweenLists, () async {
      if (pageToken != null) 
          response =  await api.users.messages.list('me', maxResults: messagesToList, pageToken: pageToken);
      else 
          response =  await api.users.messages.list('me', maxResults: messagesToList);
    });
    return response!.messages!;
  }

  static Future<Message> getMessage(GmailApi api, String messageId) async {
    Message? message;
    await Future.delayed(delayBetweenGets, () async {
      message = await api.users.messages.get('me', messageId);
    });
    return message!;
  }

  static Future<void> permaDeleteMessages(GmailApi api, List<Message> messages) async {
    List<String> idsToDelete = [];

    for (Message message in messages) {
      idsToDelete.add(message.id!);
    }

    BatchDeleteMessagesRequest request = BatchDeleteMessagesRequest(ids: idsToDelete);

    await Future.delayed(delayBetweenBatchDeletes, () async {
      await api.users.messages.batchDelete(request, 'me');
    });
  }

  static Future<void> trashMessage(GmailApi api, String messageId) async {
    await Future.delayed(delayBetweenTrashes, () async {
      await api.users.messages.trash('me', messageId);
    });
  }
}

class Utils {
  static String getSenderFromMessage(Message message) {
    List<MessagePartHeader> headers = message.payload!.headers!;
    for (MessagePartHeader header in headers) {
      if (header.name == 'From') return header.value!;
    }

    return 'NO_SENDER_FOUND';
  }

  static String getNameFromSender(String sender) {
    List<String> senderSplit = sender.split('<');
    if (senderSplit.length <= 1 || senderSplit[0].length <= 1) return 'NO_NAME_FOUND';
    String name = senderSplit[0].substring(0, senderSplit[0].length - 1);

    if (name.startsWith('"') || name.startsWith("'")) name = name.substring(1);
    if (name.endsWith('"') || name.endsWith("'")) name = name.substring(0, name.length - 2);
    return name;
  }

  static String getEmailFromSender(String sender) {
    List<String> senderSplit = sender.split('<');
    if (senderSplit.length <= 1 || senderSplit[1].length <= 1) return 'NO_EMAIL_FOUND';
    String email = senderSplit[1].substring(0, senderSplit[1].length - 1);

    if (email.startsWith('"') || email.startsWith("'")) email = email.substring(1);
    if (email.endsWith('"') || email.endsWith("'")) email = email.substring(0, email.length - 2);
    return email;
  }

  static String getLinkFromPayload(MessagePart payload) {
    Codec<String, String> decoder = utf8.fuse(base64);
    switch (payload.mimeType) {
      case 'text/html':
        return getLinkFromHtml(decoder.decode(payload.body!.data!));
      case 'text/plain':
        return getLinkFromPlain(decoder.decode(payload.body!.data!));
      case 'multipart/alternative' || 'multipart/related' || 'multipart/signed' || 'multipart/mixed': 
        return getLinkFromMultipart(payload, decoder);
    }
    return '';
  }

  static String getLinkFromHtml(String decodedData) {
    String link = '';

    Document document = parse(decodedData);

    for (var node in document.nodes) {
      if (node.nodeType != Node.TEXT_NODE) continue;
      if (!node.text!.toLowerCase().contains('unsubscribe')) continue;

      if (node.parentNode != null && node.parentNode is Element) {
        Element parent = node.parentNode as Element;
        if (parent.localName == 'a') link = parent.attributes['href'] ?? '';
      }
    }
    return link;
  }

  static String getLinkFromPlain(String decodedData) {
    String link = '';
    List<String> lines = decodedData.split('\n');

    for (String line in lines) {
      if (!line.toLowerCase().contains('unsubscribe')) continue;

      RegExp regex = RegExp(r'https?://\S+');
      Iterable<Match> matches = regex.allMatches(line);

      for (Match match in matches) {
        link = match.group(0) ?? '';
      }
    }

    return link;
  }

  static String getLinkFromMultipart(MessagePart payload, Codec<String, String> decoder) {
    // Strategy for multipart is just to keep going deeper in the part tree until we find
    // a text/* part

    if (payload.parts == null) return '';
    
    for (MessagePart part in payload.parts!) {
      if (part.mimeType == 'text/html') 
        return getLinkFromHtml(decoder.decode(part.body!.data!));

      if (part.mimeType == 'text/plain')
        return getLinkFromPlain(decoder.decode(part.body!.data!));

      else return getLinkFromMultipart(part, decoder);
    }

    return '';
  }

  static String removeLinkParameters(String link) {
    return link.contains('?')
        ? link
        : link.substring(0, link.indexOf('?'));
  }

  static DateTime getDateTimeFromMessage(Message message) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(message.internalDate!));
  }
}