import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'alarm/alarm_app.dart';
import 'auth/auth_gate.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rise & Shine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(child: AlarmAppShell()),
    );
  }
}
