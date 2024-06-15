//ignore_for_file: avoid_print 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nuke_my_inbox/scripts/state_provider.dart';

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
        children: Provider.of<StateProvider>(context, listen: false).loadingWidgets
      ),
    );
  }
}