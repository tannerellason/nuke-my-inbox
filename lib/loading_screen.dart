//ignore_for_file: avoid_print 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'gmail_handler.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  
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
              Text('Please wait for emails to be collected and processed'),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Provider.of<Gmailhandler>(context).statusMessage,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Provider.of<Gmailhandler>(context, listen: false).signOut(context);
                },
                child: const Text('Sign out'),
              )
            ]
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Provider.of<Gmailhandler>(context, listen: false).statusMessage == 'Done processing') {
            context.go('/flagger');
          }
        },
        tooltip: 'Next page',
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}