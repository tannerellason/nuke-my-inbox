import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'sender_profile.dart';


class FlaggerScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const FlaggerScreen();

  List<Container> _buildList(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<SenderProfile>? senderProfiles = Provider.of<ApplicationState>(context).senderProfiles;
    List<Container> containerList = [];
    
    for (SenderProfile senderProfile in senderProfiles!) {
      containerList.add(Container(
        width: width,
        child: Column(
          children: [
            Row(
              children: [
                Text("Sender: ${senderProfile.sender}"),
                const Text("Flag?"),
              ]
            )
          ],
        )
      ));
    }

    return containerList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildList(context),
    );
  }
}