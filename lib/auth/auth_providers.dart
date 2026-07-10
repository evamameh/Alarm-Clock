import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../firebase_options.dart';

final firebaseInitializationProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) async* {
  await ref.watch(firebaseInitializationProvider.future);
  yield* ref.watch(firebaseAuthProvider).authStateChanges();
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider), GoogleSignIn.instance);
});

final sessionSettingsProvider =
    StateNotifierProvider<SessionSettingsController, SessionSettings>((ref) {
      return SessionSettingsController();
    });

class SessionSettings {
  const SessionSettings({this.rememberMe = true});

  final bool rememberMe;

  Duration get timeout {
    return rememberMe
        ? const Duration(minutes: 30)
        : const Duration(minutes: 5);
  }
}

class SessionSettingsController extends StateNotifier<SessionSettings> {
  SessionSettingsController() : super(const SessionSettings());

  void setRememberMe(bool rememberMe) {
    state = SessionSettings(rememberMe: rememberMe);
  }
}

class AuthController {
  AuthController(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  var _isGoogleSignInInitialized = false;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _auth.signOut();
  }

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    if (kIsWeb) {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    }
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle({bool rememberMe = true}) async {
    if (kIsWeb) {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
      await _auth.signInWithRedirect(GoogleAuthProvider());
      return;
    }

    await _ensureGoogleSignInInitialized();
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    if (_isGoogleSignInInitialized) {
      try {
        await _googleSignIn.signOut();
      } on GoogleSignInException {
        // The user may have signed in with email/password only.
      }
    }
    await _auth.signOut();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;

    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    await _googleSignIn.initialize(
      clientId: kIsWeb && webClientId.isNotEmpty ? webClientId : null,
    );
    _isGoogleSignInInitialized = true;
  }
}
