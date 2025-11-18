import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'eventos_page.dart';
import 'inicio_sesion.dart';

import 'app_state.dart';
import 'auth_gate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_fonts/google_fonts.dart';

AndroidProvider _getAndroidProvider() {
  // Use Play Integrity for release builds, but allow the debug provider so that
  // emulators/dev devices show the App Check debug token in the logs.
  if (kReleaseMode) {
    return AndroidProvider.playIntegrity;
  }
  return AndroidProvider.debug;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: _getAndroidProvider(),
  );

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
        clientId:
        '650790578068-cv2q1uh5dqghs0a7o00cvq1qgrnr3m9k.apps.googleusercontent.com'),
  ]);

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Emmu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.red,
        ),
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return FirebaseAuth.instance.currentUser != null
            ? Eventos()
            : InicioSesion();
      },
    ),
    GoRoute(
      path: '/inicioSesion',
      builder: (context, state) => InicioSesion(),
    ),
    GoRoute(
      path: 'sign-in',
      builder: (context, state) => SignInScreen(
        actions: [
          ForgotPasswordAction((context, email) {
            final uri = Uri(
              path: '/sign-in/forgot-password',
              queryParameters: <String, String?>{
                'email': email,
              },
            );
            context.push(uri.toString());
          }),
          AuthStateChangeAction((context, state) {
            final user = switch (state) {
              SignedIn signedIn => signedIn.user,
              UserCreated created => created.credential.user,
              _ => null,
            };
            if (user == null) {
              return;
            }
            if (state is UserCreated) {
              user.updateDisplayName(user.email!.split('@')[0]);
            }
            if (!user.emailVerified) {
              user.sendEmailVerification();
              const snackBar = SnackBar(
                  content: Text(
                      'Please check your email to verify your email address'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            context.pushReplacement('/');
          }),
        ],
      ),
    ),
    GoRoute(
      path: 'forgot-password',
      builder: (context, state) {
        final arguments = state.uri.queryParameters;
        return ForgotPasswordScreen(
          email: arguments['email'],
          headerMaxExtent: 200,
        );
      },
    ),
    GoRoute(
      path: 'profile',
      builder: (context, state) => Consumer<ApplicationState>(
        builder: (context, appState, _) => ProfileScreen(
          key: ValueKey(appState.emailVerified),
          providers: const [],
          actions: [
            SignedOutAction(
              ((context) {
                context.pushReplacement('/');
              }),
            ),
          ],
          children: [
            Visibility(
                visible: !appState.emailVerified,
                child: OutlinedButton(
                  child: const Text('Recheck Verification State'),
                  onPressed: () {
                    appState.refreshLoggedInUser();
                  },
                ))
          ],
        ),
      ),
    ),
    GoRoute(
      path: 'login',
      builder: (context, state) => AuthGate(),
    ),
    GoRoute(path: 'Eventos', builder: (context, state) => Eventos()),
  ]);
}
