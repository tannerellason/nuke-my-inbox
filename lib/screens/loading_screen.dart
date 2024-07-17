//ignore_for_file: avoid_print 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuke_my_inbox/scripts/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: Provider.of<StateProvider>(context, listen: false).statusWidgets
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
          onPressed: () => launchUrl(Uri.parse('https://www.tannerellason.com/nuke-my-inbox-privacy-policy')),
          child: const Text('Privacy Policy'),
        )
      ],

    );
  }
}