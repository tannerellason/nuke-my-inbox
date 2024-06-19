// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'firebase_options.dart';

class AuthHandler {

  static Future<GmailApi> initGmailApi() async {
    String? name;
    if (kIsWeb) {}
    else if (Platform.isIOS) name = 'nukemyinbox';

    Firebase.initializeApp(
      name: name,
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await signInWithGoogle();
    final AuthClient? client = await _googleSignIn.authenticatedClient();
    final GmailApi gmailApi = GmailApi(client!);
    return gmailApi;
  }

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: DefaultFirebaseOptions.clientId,
    scopes: [GmailApi.mailGoogleComScope],
  );

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth 
      = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}