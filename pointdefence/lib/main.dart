import 'package:flutter/material.dart';
import 'package:pointdefence/ui/page/startPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Welcome to Flutter',
      home: BasicBottomNavBar(),
    );
  }
}
