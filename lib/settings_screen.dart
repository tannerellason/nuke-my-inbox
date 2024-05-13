//ignore_for_file: avoid_print 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';

class SettingsScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Icon(Icons.location_pin),
              Padding(padding: EdgeInsets.all(8)),
              Text(
                'What should happen to flagged emails?',
              ),
              Padding(padding: EdgeInsets.all(16)),
            ]
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     const Padding(padding: EdgeInsets.only(left: 50)),
          //     SegmentedButton(
          //       segments: const [
          //         ButtonSegment(
          //           value: 1,
          //           label: Text('Trash'),
          //           icon: Icon(Icons.delete_outline),
          //         ),
          //         ButtonSegment(
          //           value: 2,
          //           label: Text('Delete'),
          //           icon: Icon(Icons.delete_forever_outlined),
          //         ),
          //         ButtonSegment(
          //           value: 3,
          //           label: Text('Starred'),
          //           icon: Icon(Icons.star_outline),
          //         ),
          //         ButtonSegment(
          //           value: 4,
          //           label: Text('Nothing'),
          //           icon: Icon(Icons.cancel_outlined),
          //         ),
          //       ],
          //       selected: Provider.of<ApplicationState>(context, listen: false).currentDestinationSet,
          //       onSelectionChanged: (newSelection) {
          //         print(newSelection);
          //         Provider.of<ApplicationState>(context, listen: false).currentDestinationSet = {newSelection.first};
          //         print(Provider.of<ApplicationState>(context, listen: false).currentDestinationSet);
          //       }
          //     )
          //   ]
          // ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Icon(Icons.send),
              Padding(padding: EdgeInsets.all(8)),
              Text(
                'What should happen?',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(left: 50)),
              Switch(
                value: Provider.of<ApplicationState>(context, listen: false).compileInTextFile,
                activeColor: Colors.deepPurple,
                onChanged: (bool value) {
                  print(value);
                  Provider.of<ApplicationState>(context, listen: false).compileInTextFile = value;
                  print(Provider.of<ApplicationState>(context, listen: false).compileInTextFile);
                }
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              const Text(
                'Compile them all in a .txt file',
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(left: 50)),
              Switch(
                value: Provider.of<ApplicationState>(context, listen: false).attemptUnsubscribes,
                activeColor: Colors.deepPurple,
                onChanged: (bool value) {
                  print(value);
                  Provider.of<ApplicationState>(context, listen: false).attemptUnsubscribes = value;
                  print(Provider.of<ApplicationState>(context, listen: false).attemptUnsubscribes);
                }
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              const Text('Attempt to unsubscribe'),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(left: 50)),
              Switch(
                value: Provider.of<ApplicationState>(context, listen: false).blockSenders,
                activeColor: Colors.deepPurple,
                onChanged: (bool value) {
                  print(value);
                  Provider.of<ApplicationState>(context, listen: false).blockSenders = value;
                  print(Provider.of<ApplicationState>(context, listen: false).blockSenders);
                }
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              const Text('Block all flagged senders'),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(left: 50)),
              TextButton(
                onPressed: () {
                  Provider.of<ApplicationState>(context, listen: false).signOut(context);
                },
                child: const Text('Sign out'),
              )
            ]
          ),
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
          )
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