import 'package:flutter/material.dart';
import 'package:nuke_my_inbox/scripts/state_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyStatement extends StatelessWidget {
  const PrivacyStatement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Statement'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Due to the nature of this app, it needs a lot of access to your user information.')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('This is secure - all of the source code is available publicly if you want to check for yourself.'),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 25),),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Absolutely everything this application does is client side. That is, a server never sees your data.')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('The only thing a server does in this app is send the data to your computer. All processing happens locally on your machine.')
            ]
          ),
          Padding(padding: EdgeInsets.only(top: 25),),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('If I was just some user looking to clean my inbox, I would be sketched out. I totally understand if you are.'),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('But if you choose to continue, rest easy knowing that your information is secure.'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('The privacy policy is available with a link at the bottom of your screen. But through all the legalese, just know I respect your privacy'),
            ]
          )
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Provider.of<StateProvider>(context, listen: false).signInWithGoogle(context),
        label: const Text('Sign In'),
        icon: const Icon(Icons.login),
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
    );
  }

}