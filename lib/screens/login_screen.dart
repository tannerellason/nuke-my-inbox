import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuke_my_inbox/scripts/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Nuke My Inbox'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The best way to clean your email inbox',
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in to get started',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('About this project'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('I started this project to teach myself APIs and Flutter. I hope you can find it useful.'),
                        TextButton(
                          onPressed: () => launchUrl(Uri.parse('https://flutter.dev/?gad_source=1&gclid=CjwKCAjwhIS0BhBqEiwADAUhc-s_FRL2YkeVdacFyksxepd43YjXFpZBRtU1Q9_uLbo3GYUh5XZmbRoCWkMQAvD_BwE&gclsrc=aw.ds')),
                          child: const Text('Built with Flutter v3.22.2'),
                        ),
                        TextButton(
                          onPressed: () => launchUrl(Uri.parse('https://github.com/tannerellason/nuke-my-inbox')),
                          child: const Text('Source code hosted by GitHub'),
                        ),
                        TextButton(
                          onPressed: () => launchUrl(Uri.parse('Ko-fi.com/tannerellason')),
                          child: const Text('Any donations towards my college fund are greatly appreciated!!'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      )
                    ]
                  )
                ),
                child: const Text('Or click here for info about this project'),
              )
            ]
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Sign in'),
        icon: const Icon(Icons.login),
        onPressed: () {
          Provider.of<StateProvider>(context, listen: false).signInWithGoogle(context);
        }
      ),

    );
  }
}