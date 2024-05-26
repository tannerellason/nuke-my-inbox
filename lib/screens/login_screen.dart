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
            children: [Switch(
              value: Provider.of<Gmailhandler>(context, listen: false).collectAll,
              onChanged: (value) {
                Provider.of<Gmailhandler>(context, listen: false).collectAll = value;
              }
            )]
          ),
          TextField(
            enabled: !Provider.of<Gmailhandler>(context, listen: false).collectAll,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Number of emails to process',
            )
          ),
        ]
      )
    );
  }
}



// Center(
//         child: SignInButtonBuilder(
//           text: 'Sign in with Google',
//           icon: Icons.login,
//           onPressed: () {
//             Provider.of<Gmailhandler>(context, listen: false).signInWithGoogle(context);
//           },
//           backgroundColor: ThemeData.dark(useMaterial3: true).scaffoldBackgroundColor,
//         )
//       ),