import 'package:flutter/material.dart';
import 'config/app_routes.dart';

void main() {
  runApp(NiveshakApp());
}

class NiveshakApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niveshak',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
