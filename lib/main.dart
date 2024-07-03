// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/flagger_screen.dart';
import 'screens/privacy_statement.dart';
import 'scripts/state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => StateProvider(),
    builder: ((context, child) => const MyApp()),
  ));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Consumer<StateProvider>(
        builder: (context, appState, _) => LoginScreen(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'privacy',
          builder: (context, state) => Consumer<StateProvider>(
            builder: (context, appState, _) => PrivacyStatement(),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'settings',
              builder: (context, state) => Consumer<StateProvider>(
                builder: (context, appState, _) => SettingsScreen(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'loading',
                  builder: (context, state) => Consumer<StateProvider>(
                    builder: (context, appState, _) => LoadingScreen(),
                  ),
                  routes: <RouteBase> [
                    GoRoute(
                      path: 'flagger',
                      builder: (context, state) => Consumer<StateProvider>(
                        builder: (context, appState, _) => FlaggerScreen(),
                      )
                    )
                  ]
                ),
              ]
            ),
          ]
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