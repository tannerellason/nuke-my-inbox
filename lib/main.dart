// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'flagger_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const MyApp()),
  ));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Consumer<ApplicationState>(
        builder: (context, appState, _) => LoginScreen(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'settings',
          builder: (context, state) => Consumer<ApplicationState>(
            builder: (context, appState, _) => SettingsScreen(),
          ),
        ),
        GoRoute(
          path: 'senderFlagger',
          builder: (context, state) => Consumer<ApplicationState>(
            builder: (context, appState, _) => FlaggerScreen(),
          )
        )
      ]
    ),
  ],
);
  
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
  
  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
    context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nuke My Inbox',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
}