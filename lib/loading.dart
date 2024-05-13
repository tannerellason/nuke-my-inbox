import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class LoadingScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoadingScreen();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text("Please wait for emails to be collected and processed")
          ),
          Center(
            child: Text(
              Provider.of<ApplicationState>(context).statusMessage
            ),
          ),
        ]
      ),
    );
  }
}