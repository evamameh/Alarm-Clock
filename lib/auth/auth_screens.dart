import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../alarm/alarm_widgets.dart';
import '../theme.dart';
import 'auth_providers.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key, this.message, required this.onShowRegister});

  final String? message;
  final VoidCallback onShowRegister;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthForm(
      title: 'Welcome Back',
      subtitle: 'Sign in to manage your alarms.',
      actionLabel: 'Login',
      isLogin: true,
      message: message,
      footerLabel: 'Create an account',
      footerAction: onShowRegister,
      googleLabel: 'Continue with Google',
      onSubmit: (email, password) {
        return ref
            .read(authControllerProvider)
            .login(email: email, password: password);
      },
      onGoogleSubmit: () {
        return ref.read(authControllerProvider).signInWithGoogle();
      },
    );
  }
}

class RegistrationScreen extends HookConsumerWidget {
  const RegistrationScreen({
    super.key,
    required this.onShowLogin,
    required this.onRegistered,
  });

  final VoidCallback onShowLogin;
  final VoidCallback onRegistered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AuthForm(
      title: 'Create Account',
      subtitle: 'Register to keep your alarm clock private.',
      actionLabel: 'Register',
      isLogin: false,
      footerLabel: 'I already have an account',
      footerAction: onShowLogin,
      onSuccess: onRegistered,
      googleLabel: 'Register with Google',
      onSubmit: (email, password) {
        return ref
            .read(authControllerProvider)
            .register(email: email, password: password);
      },
      onGoogleSubmit: () {
        return ref.read(authControllerProvider).signInWithGoogle();
      },
    );
  }
}

class _AuthForm extends HookWidget {
  const _AuthForm({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.isLogin,
    this.message,
    required this.footerLabel,
    required this.footerAction,
    this.onSuccess,
    required this.googleLabel,
    required this.onSubmit,
    required this.onGoogleSubmit,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isLogin;
  final String? message;
  final String footerLabel;
  final VoidCallback footerAction;
  final VoidCallback? onSuccess;
  final String googleLabel;
  final Future<void> Function(String email, String password) onSubmit;
  final Future<void> Function() onGoogleSubmit;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isSubmitting = useState(false);
    final isGoogleSubmitting = useState(false);
    final errorText = useState<String?>(null);

    Future<void> submit() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      isSubmitting.value = true;
      errorText.value = null;

      try {
        await onSubmit(emailController.text, passwordController.text);
        onSuccess?.call();
      } on FirebaseAuthException catch (error) {
        errorText.value = _authErrorMessage(error, isLogin: isLogin);
      } catch (error) {
        errorText.value = error.toString();
      } finally {
        if (context.mounted) isSubmitting.value = false;
      }
    }

    Future<void> submitGoogle() async {
      FocusScope.of(context).unfocus();

      isGoogleSubmitting.value = true;
      errorText.value = null;

      try {
        await onGoogleSubmit();
      } on FirebaseAuthException catch (error) {
        errorText.value = _authErrorMessage(error, isLogin: isLogin);
      } catch (error) {
        errorText.value = error.toString();
      } finally {
        if (context.mounted) isGoogleSubmitting.value = false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 32),
          children: [
            const Icon(
              Icons.local_florist_outlined,
              color: AppColors.rose,
              size: 52,
            ),
            const SizedBox(height: 12),
            const Text(
              'RK Rise & Shine',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.rose,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: softPanel(radius: 30),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.roseDark,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 18),
                      _StatusMessage(
                        icon: Icons.check_circle_outline,
                        text: message!,
                        isError: false,
                      ),
                    ],
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your email.';
                        if (!_looksLikeEmail(email)) {
                          return 'Invalid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => submit(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return 'Enter your password.';
                        if (password.length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    if (errorText.value != null) ...[
                      const SizedBox(height: 18),
                      _StatusMessage(
                        icon: Icons.error_outline,
                        text: errorText.value!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.rose,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(62),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(34),
                        ),
                      ),
                      onPressed: isSubmitting.value ? null : submit,
                      icon: isSubmitting.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.6,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.roseDark,
                        minimumSize: const Size.fromHeight(58),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isGoogleSubmitting.value ? null : submitGoogle,
                      icon: isGoogleSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.rose,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const _GoogleMark(),
                      label: Text(
                        googleLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: footerAction,
                      child: Text(footerLabel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.text,
    required this.isError,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.blush.withValues(alpha: 0.55)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.roseDark, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.roseDark,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

bool _looksLikeEmail(String email) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
}

String _authErrorMessage(FirebaseAuthException error, {required bool isLogin}) {
  final details = ' (${error.code})';

  switch (error.code) {
    case 'email-already-in-use':
      return 'User already exists. Please login instead.$details';
    case 'invalid-email':
      return 'Invalid email address.$details';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Invalid email or password.$details';
    case 'weak-password':
      return 'Invalid password. Use at least 6 characters.$details';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled in Firebase.$details';
    case 'network-request-failed':
      return 'Network error. Check your internet connection.$details';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.$details';
    default:
      if (isLogin) return 'Invalid email or password.$details';
      return '${error.message ?? 'Registration failed. Check your Firebase setup.'}$details';
  }
}
