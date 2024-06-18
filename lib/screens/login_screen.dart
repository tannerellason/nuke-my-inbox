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

      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const Text('Collect all?'),
      //         const Padding(padding: EdgeInsets.only(right: 10)),
      //         Switch(
      //           value: Provider.of<StateProvider>(context, listen: false).collectAll,
      //           onChanged: (value) {
      //             Provider.of<StateProvider>(context, listen: false).setCollectAll(value);
      //           }
      //         ),
      //       ]
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Padding(
      //           padding: const EdgeInsets.all(20),
      //           child: SizedBox(
      //             width: 300,
      //             child: TextField(
      //               enabled: !Provider.of<StateProvider>(context, listen: false).collectAll,
      //               keyboardType: TextInputType.number,
      //               decoration: const InputDecoration(
      //                 border: OutlineInputBorder(),
      //                 labelText: 'Number of emails to process',
      //               ),
      //               onSubmitted: (String value) {
      //                 Provider.of<StateProvider>(context, listen: false).setMessagseToCollect(int.parse(value));
      //               },
      //             ),
      //           )
      //         ),
      //       ],
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         SignInButtonBuilder(
      //           text: 'Sign In With Google',
      //           icon: Icons.login,
      //           onPressed: () {
      //             Provider.of<StateProvider>(context, listen: false).signInWithGoogle(context);
      //             context.go('/loading');
      //           },
      //           backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
      //         )
      //       ]
      //     )
      //   ]
      // )