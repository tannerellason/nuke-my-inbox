//ignore_for_file: avoid_print 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 100)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Please wait for emails to be collected and processed"),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Provider.of<ApplicationState>(context).statusMessage,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Provider.of<ApplicationState>(context, listen: false).signOut(context);
                },
                child: const Text('Sign out'),
              )
            ]
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Provider.of<ApplicationState>(context, listen: false).doneProcessing) {
            context.go('/flagger');
          }
        },
        tooltip: 'Next page',
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}