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
        title: const Text('Welcome to Nuke My Inbox v0.2'),
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
          const Padding(padding: EdgeInsets.only(top: 100),),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('I started this project to teach myself APIs and Flutter. I hope you find it useful :)'),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Please report all problems to either the GitHub repo or to tannerellasondev@gmail.com'),
            ]
          ),
          const Padding(padding: EdgeInsets.only(top: 100),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse('https://flutter.dev/?gad_source=1&gclid=CjwKCAjwhIS0BhBqEiwADAUhc-s_FRL2YkeVdacFyksxepd43YjXFpZBRtU1Q9_uLbo3GYUh5XZmbRoCWkMQAvD_BwE&gclsrc=aw.ds')),
                child: const Text('Built with flutter v3.22.2'),
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse('https://github.com/tannerellason/nuke-my-inbox')),
                child: const Text('Source code'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse('https://Ko-fi.com/tannerellason')),
                child: const Text('Any donations towards my college fund are greatly appreciated!!'),
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse('https://www.termsfeed.com/live/e7579a6d-4571-4c05-a937-dc5d959253b6')),
                child: const Text('Privacy Policy'),
              )
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Long story short: everything is client side. We do not store anything other than analytics.')
            ],
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