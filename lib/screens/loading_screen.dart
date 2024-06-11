//ignore_for_file: avoid_print 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nuke_my_inbox/scripts/state_provider.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  List<Widget> _buildList(BuildContext context) {
    String statusMessage = Provider.of<StateProvider>(context, listen: false).statusMessage;
    List<String> lineSplit = statusMessage.split('\n');
    List<Widget> returnList = [];

    returnList.add(const Padding(padding: EdgeInsets.only(top: 100)));

    for (String line in lineSplit) {
      returnList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(line)
            )
          ]
        )
      );
    }

    returnList.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [TextButton(
        onPressed: () {
          Provider.of<StateProvider>(context, listen: false).cancel();
        },
        child: const Text('Cancel')
      )]
    ));

    if (lineSplit[0] == 'Done processing') {
      return [
        const Padding(padding: EdgeInsets.only(top: 100)),
        Center(
          child: ElevatedButton(
            onPressed: () => context.go('/flagger'),
            child: const Text('Next page'),
          ),
        )
      ];
    }

    if (lineSplit[0] == 'Done') {
      return [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Provider.of<StateProvider>(context, listen: false).cancel();
            },
            child: const Text('Exit')
          )
        )
      ];
    }

    return returnList;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildList(context)
      ),
    );
  }
}