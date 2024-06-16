// ignore_for_file: curly_braces_in_flow_control_structures, unused_local_variable

import 'dart:convert';
import 'package:googleapis/gmail/v1.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'dart:async';
import 'sender_profile.dart';

class GmailHandler {

  static Future<List<Message>> listMessages(GmailApi api, int messagesToList, String? pageToken) async {
    ListMessagesResponse? response;
    await Future.delayed(const Duration(milliseconds: 21), () async {
      if (pageToken != null) 
          response =  await api.users.messages.list('me', maxResults: messagesToList, pageToken: pageToken);
      else 
          response =  await api.users.messages.list('me', maxResults: messagesToList);
    });
    return response!.messages!;
  }

  static Future<Message> getMessage(GmailApi api, String messageId) async {
    Message? message;
    await Future.delayed(const Duration(milliseconds: 21), () async {
      message = await api.users.messages.get('me', messageId);
    });
    return message!;
  }

  static void permaDeleteMessages(GmailApi api, List<Message> messages) async {
    List<String> idsToDelete = [];

    for (Message message in messages) {
      idsToDelete.add(message.id!);
    }

    BatchDeleteMessagesRequest request = BatchDeleteMessagesRequest(ids: idsToDelete);

    await Future.delayed(const Duration(milliseconds: 201), () async {
      await api.users.messages.batchDelete(request, 'me');
    });
  }

  static void trashMessage(GmailApi api, String messageId) async {
    await Future.delayed(const Duration(milliseconds: 21), () async {
      await api.users.messages.trash('me', messageId);
    });
  }

  static Future<List<SenderProfile>> processMessages(List<Message> messages) async {
    List<SenderProfile> profiles = [];

    for (Message message in messages) {
      String sender = Utils.getSenderFromMessage(message);
      String name = Utils.getNameFromSender(sender);
      String email = Utils.getEmailFromSender(sender);
      String link = Utils.getLinkFromPayload(message.payload!);

      bool senderFound = false;
      for (SenderProfile profile in profiles) {
        if (profile.sender != sender) continue;

        profile.addMessage(message);
        profile.addLink(link);
        senderFound = true;
        
      }

      if (!senderFound) {
        SenderProfile profile = SenderProfile(sender, name, email, message, link);
        profiles.add(profile);
      }
    }

    profiles.sort((a, b) => b.numberOfMessages.compareTo(a.numberOfMessages));

    return profiles;
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
}