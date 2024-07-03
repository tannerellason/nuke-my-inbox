import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nuke_my_inbox/scripts/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Collect all?'),
                  const Padding(padding: EdgeInsets.only(left: 10),),
                  Switch(
                    value: Provider.of<StateProvider>(context, listen: false).collectAll,
                    onChanged: (value) {
                      Provider.of<StateProvider>(context, listen: false).setCollectAll(value);
                    }
                  ),
                ]
              ),
              if (!Provider.of<StateProvider>(context, listen: false).collectAll) Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    child: Slider(
                      value: Provider.of<StateProvider>(context, listen: false).messagesToCollect.toDouble(),
                      max: Provider.of<StateProvider>(context, listen: false).maxMessages.toDouble(),
                      divisions: (Provider.of<StateProvider>(context, listen: false).maxMessages ~/ 10),
                      min: 1.0,
                      label: Provider.of<StateProvider>(context, listen: false).messagesToCollect.toString(),
                      onChanged: (double value) {
                        Provider.of<StateProvider>(context, listen: false).setMessagesToCollect(value.toInt());
                      }
                    ),
                  )
                ]
              ),
              if (!Provider.of<StateProvider>(context, listen: false).collectAll) Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 50,
                    child: Center(
                      child: Text(
                        'Min:\n1'
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      enabled: !Provider.of<StateProvider>(context, listen: false).collectAll,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          Provider.of<StateProvider>(context, listen: false).messagesToCollect.toString(),
                        )
                      ),
                      controller: Provider.of<StateProvider>(context, listen: false).textController,
                      onSubmitted: (String value) {
                        Provider.of<StateProvider>(context, listen: false).setMessagesToCollect(int.parse(value));
                      }
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Center(
                      child: Text(
                        'Max:\n${Provider.of<StateProvider>(context, listen: false).maxMessages.toString()}'
                      ),
                    ),
                  )
                ]
              )
            ]
          ),
        ),
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: () => Provider.of<StateProvider>(context, listen: false).signOut(context),
          child: const Text('Change user'),
        ),
        const VerticalDivider(),
        TextButton(
          onPressed: () => launchUrl(Uri.parse('https://www.flutter.dev')),
          child: const Text('Built with Flutter'),
        ),
        const VerticalDivider(),
        TextButton(
          onPressed: () => launchUrl(Uri.parse('https://github.com/tannerellason/nuke-my-inbox')),
          child: const Text('Source code'),
        ),
        const VerticalDivider(),
        TextButton(
          onPressed: () => launchUrl(Uri.parse('https://www.Ko-fi.com/tannerellason')),
          child: const Text('Ko-Fi'),
        ),
        const VerticalDivider(),
        TextButton(
          onPressed: () => launchUrl(Uri.parse('https://www.termsfeed.com/live/e7579a6d-4571-4c05-a937-dc5d959253b6')),
          child: const Text('Privacy Policy'),
        )
      ],

      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Next page'),
        icon: const Icon(Icons.navigate_next),
        onPressed: () {
          context.go('/privacy/settings/loading');
          Provider.of<StateProvider>(context, listen: false).collectEmails(context);
        }
      ),
    );
  }
  
}