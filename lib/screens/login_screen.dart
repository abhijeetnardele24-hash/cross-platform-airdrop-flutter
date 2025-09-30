import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        // Handle successful sign in
        print('Signed in with Google: ${account.displayName}');
        // Navigate to next screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (error) {
      print('Google sign in error: $error');
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // Handle successful sign in
        print('Signed in with Facebook');
        // Navigate to next screen
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print('Facebook sign in failed: ${result.message}');
      }
    } catch (error) {
      print('Facebook sign in error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to AirDrop Pro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signInWithFacebook,
              icon: const Icon(Icons.facebook),
              label: const Text('Sign in with Facebook'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to email sign up
              },
              child: const Text('Sign up with Email'),
            ),
          ],
        ),
      ),
    );
  }
}
