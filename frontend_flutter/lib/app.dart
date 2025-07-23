import 'package:flutter/material.dart';
import 'config/app_routes.dart';

class NiveshakApp extends StatelessWidget {
  const NiveshakApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niveshak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}