import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuke_my_inbox/scripts/state_provider.dart';

class LoginScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Nuke My Inbox'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The best way to clean your email inbox',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in to get started',
              ),
            ],
          ),
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