import 'package:flutter/material.dart';

import 'home/pages/configure_page.dart';
import 'home/pages/home_page.dart';
import 'home/pages/success_page.dart';

class ExcelToWordApp extends StatelessWidget {
  const ExcelToWordApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Translator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/configure': (context) => const ConfigurePage(),
        '/success': (context) => const SuccessPage(),
      },
    );
  }
}