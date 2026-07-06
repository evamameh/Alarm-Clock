import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../theme.dart';
import 'auth_providers.dart';
import 'auth_screens.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  var _showRegister = false;
  String? _loginMessage;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) return widget.child;

        return _showRegister
            ? RegistrationScreen(
                onShowLogin: () => _showLogin(),
                onRegistered: () => _showLogin(
                  message: 'Account created. Please login to continue.',
                ),
              )
            : LoginScreen(
                message: _loginMessage,
                onShowRegister: () => _setRegister(true),
              );
      },
      error: (error, _) => _AuthMessage(
        icon: Icons.error_outline,
        title: 'Firebase setup needed',
        message: _friendlySetupError(error),
      ),
      loading: () => const _AuthMessage(
        icon: Icons.local_florist_outlined,
        title: 'Rise & Shine',
        message: 'Preparing your alarm clock...',
        loading: true,
      ),
    );
  }

  void _setRegister(bool value) {
    setState(() {
      _showRegister = value;
      if (value) _loginMessage = null;
    });
  }

  void _showLogin({String? message}) {
    setState(() {
      _showRegister = false;
      _loginMessage = message;
    });
  }
}

String _friendlySetupError(Object error) {
  if (error is FirebaseException) {
    return error.message ?? error.code;
  }

  return error.toString();
}

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.rose, size: 54),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.roseDark,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                if (loading) ...[
                  const SizedBox(height: 26),
                  const CircularProgressIndicator(color: AppColors.rose),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
