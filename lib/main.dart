import 'package:course_project_code_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'services/service_locator.dart';

void main() {
  ServiceLocator.init(useMock: true); //добавлено для инициализации списка лабораторных работ

  runApp(
    MyApp()
  );
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}


