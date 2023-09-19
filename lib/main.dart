import 'package:app_2/src/app.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:sqflite/sqflite.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REGISTRO',
      home: MyAppForm(),
    );
  }
}
