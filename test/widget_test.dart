import 'package:alarmclock/alarm/alarm_app.dart';
import 'package:alarmclock/auth/auth_providers.dart';
import 'package:alarmclock/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows the login screen when signed out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseInitializationProvider.overrideWith((ref) async {}),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('shows the alarm clock home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AlarmAppShell())),
    );
    await tester.pump();

    expect(find.text('RK Rise & Shine'), findsOneWidget);
    expect(find.text('Set Alarm'), findsOneWidget);
  });
}
