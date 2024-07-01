import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuke_my_inbox/scripts/state_provider.dart';
import 'package:nuke_my_inbox/scripts/sender_profile.dart';

class FlaggerScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const FlaggerScreen();

  List<Widget> _buildList(BuildContext context) {
    List<SenderProfile>? senderProfiles = Provider.of<StateProvider>(context).senderProfiles;
    List<Widget> widgetList = [];
    widgetList.add(const Padding(padding: EdgeInsets.only(top: 30)));
    if (!Provider.of<StateProvider>(context, listen: false).onFlagger) widgetList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Provider.of<StateProvider>(context, listen: false).statusWidgets
      )
    );
    widgetList.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Show senders with links found'),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Switch(
              value: Provider.of<StateProvider>(context, listen: false).showAll,
              onChanged: (value) {
                Provider.of<StateProvider>(context, listen: false).setShowAll(value);
              },
            ),
          ),

          const Text('Show all senders'),
        ],
      )
    );
    widgetList.add(const Padding(padding: EdgeInsets.only(top: 30)));
    
    for (SenderProfile senderProfile in senderProfiles) {
      if (senderProfile.numberOfUnsubLinks == 0 && !Provider.of<StateProvider>(context, listen: false).showAll) continue; // Toggling showing all or not
      if (senderProfile.handled) continue; // Don't show profiles that we have already performed an action on

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time of last message: ${senderProfile.time}'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Example snippet: ${senderProfile.snippet}')
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (senderProfile.numberOfUnsubLinks != 0) Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.small(
                tooltip: 'Show unsubscribe links',
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    scrollable: true,
                    title: Text('Unsubscribe links for ${senderProfile.name}'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: Provider.of<StateProvider>(context, listen: false).buildUnsubLinks(senderProfile),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      )
                    ]
                  )
                ),
                
                child: const Icon(Icons.remove_circle),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.small(
                tooltip: 'Send all messages to trash',
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Send messages to trash?'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Provider.of<StateProvider>(context, listen: false).trashMessages(senderProfile);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      )
                    ]
                  )
                ),
                child: const Icon(Icons.delete),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.small(
                tooltip: 'Delete all messages forever',
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Permanently Delete Messages?'),
                    content: const Text('THIS ACTION CANNOT BE UNDONE!'),
                    actions: [
                      TextButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('ARE YOU CERTAIN?'),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'THIS ACTION CANNOT BE UNDONE. THESE EMAILS WILL BE LOST FOREVER. THERE IS NO WAY TO RECOVER THEM. '
                                  '\nNEITHER GOOGLE NOR THE DEVELOPER OF NUKE MY INBOX WILL BE ABLE TO HELP YOU RECOVER THESE EMAILS '
                                  '\nDO YOU UNDERSTAND?'
                                ),
                                const Text(
                                  'Type the following word in the text box to continue: DELETE'
                                ),
                                TextField(
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (String value) {
                                    Provider.of<StateProvider>(context, listen: false).setConfirmation(value);
                                  }
                                )
                              ],
                            ),
                            actions: [
                              if (Provider.of<StateProvider>(context).validConfirmation) TextButton(
                                onPressed: () {
                                  Provider.of<StateProvider>(context, listen: false).permaDeleteMessages(senderProfile);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('YES, I UNDERSTAND'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              )
                            ]
                          )
                        ),
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      )
                    ]
                  )
                ),
                child: const Icon(Icons.delete_forever),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton.small(
                tooltip: 'Dissmiss sender',
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Dismiss sender?'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Provider.of<StateProvider>(context, listen: false).dismissSender(senderProfile);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      )
                    ]
                  )
                ),
                child: const Icon(Icons.close),
              )
            )
          ],
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
        title: const Text('Sender list'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: _buildList(context),
      ),
    );
  }
}