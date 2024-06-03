import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import '../scripts/gmail_handler.dart';

class LoginScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in to Nuke My Inbox'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Collect all?'),
              const Padding(padding: EdgeInsets.only(right: 10)),
              Switch(
                value: Provider.of<Gmailhandler>(context, listen: false).collectAll,
                onChanged: (value) {
                  Provider.of<Gmailhandler>(context, listen: false).setCollectAll(value);
                }
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    enabled: !Provider.of<Gmailhandler>(context, listen: false).collectAll,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number of emails to process',
                    ),
                    onSubmitted: (String value) {
                      Provider.of<Gmailhandler>(context, listen: false).setNumberOfMessages(int.parse(value));
                    },
                  ),
                )
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignInButtonBuilder(
                text: 'Sign In With Google',
                icon: Icons.login,
                onPressed: () {
                  Provider.of<Gmailhandler>(context, listen: false).signInWithGoogle(context);
                },
                backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
              )
            ]
          )
        ]
      )
    );
  }
}