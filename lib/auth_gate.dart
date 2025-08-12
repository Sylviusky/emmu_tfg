import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider; // new
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

//import 'package:firebase_ui_auth/src/providers/auth_provider.dart';
//import 'package:firebase_auth_platform_interface/src/auth_provider.dart';
//import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges() as Stream<User?>?,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                  clientId:
                      '650790578068-cv2q1uh5dqghs0a7o00cvq1qgrnr3m9k.apps.googleusercontent.com'),
            ],

            /*providers: [
              EmailAuthProvider(),
            ],*/

            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(
                    image: AssetImage('assets/logortr.png'),
                    width: 280,
                  ),
                ),
              );
            },
            /*subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Bienvenido a Emmu!')
                    : const Text('Welcome to Flutterfire, please sign up!'),
              );
            },*/
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            /*sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('flutterfire_300x.png'),
                ),
              );
            },*/
          );
        }
        return const AuthGate();
      },
    );
  }
}
