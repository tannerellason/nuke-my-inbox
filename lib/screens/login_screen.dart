import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Nuke My Inbox v1.0'),
        centerTitle: true,
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'I started this project to teach myself about APIs, as well as building apps with flutter.'
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 25)
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'This app will collect the number of emails you specify. It will then find all'
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('unsubscribe links within those emails and place them on a single page.')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You can also trash / delete all messages from a sender.'),
            ]
          ),
          Padding(
            padding: EdgeInsets.only(top: 25)
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Absolutely zero information is stored, aside from debug information collected by Google.'
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'All emails are processed client side. NO DATA IS COLLECTED FROM THE PROCESSED MESSAGES.'
              )
            ]
          ),
        ],
      ),
      persistentFooterButtons: [
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
        label: const Text('Privacy statement'),
        icon: const Icon(Icons.privacy_tip),
        onPressed: () {
          context.go('/privacy');
        }
      ),

    );
  }
}