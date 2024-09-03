import 'package:flutter/material.dart';

import 'theme.dart';

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Finance Tracker')),
      ),
    );
  }
}
