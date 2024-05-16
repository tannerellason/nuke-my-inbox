import 'package:flutter/material.dart';
import 'package:nuke_my_inbox/gmail_handler.dart';
import 'package:provider/provider.dart';
import 'sender_profile.dart';

class FlaggerScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const FlaggerScreen();

  List<Widget> _buildList(BuildContext context) {
    List<SenderProfile>? senderProfiles = Provider.of<Gmailhandler>(context).senderProfiles;
    List<Widget> widgetList = [];
    widgetList.add(const Padding(padding: EdgeInsets.only(top: 30)));
    
    for (SenderProfile senderProfile in senderProfiles) {
      if (senderProfile.numberOfUnsubLinks == 0) continue;
      

      widgetList.addAll([
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(senderProfile.name),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(senderProfile.email),
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${senderProfile.numberOfMessages} messages, ' 
                  '${senderProfile.numberOfUnsubLinks} unsubscribe links found')
          ]
        ),
        const Divider(),
      ]);

      if (senderProfile.name == 'NO NAME FOUND' || senderProfile.email == 'NO EMAIL FOUND') {
        widgetList[widgetList.length - 3] = const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('')]);
        widgetList[widgetList.length - 4] = Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(senderProfile.sender)]);
      }
    }
    widgetList.removeLast(); // No divider at the very end, looks tacky

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sender list')
      ),
      body: ListView(
        children: _buildList(context),
      )
    );
  }
}