import 'package:flutter/material.dart';

Route guardedRoute({
  required Future<bool> Function() guard,
  required WidgetBuilder ifAllowed,
  required WidgetBuilder ifDenied,
}) {
  return MaterialPageRoute(
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