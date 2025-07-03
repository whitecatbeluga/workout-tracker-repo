import 'package:flutter/material.dart';

Route guardedRoute({
  required RouteSettings settings, // Accept route settings
  required Future<bool> Function() guard,
  required WidgetBuilder ifAllowed,
  required WidgetBuilder ifDenied,
}) {
  return MaterialPageRoute(
    settings: settings, // Forward settings so arguments are preserved
    builder: (_) => FutureBuilder<bool>(
      future: guard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data == true ? ifAllowed(context) : ifDenied(context);
      },
    ),
  );
}
