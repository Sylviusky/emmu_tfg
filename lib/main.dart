

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'Eventos_Page.dart';
import 'InicioSesion.dart';

import 'app_state.dart';
import 'auth_gate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
        clientId:
        '650790578068-cv2q1uh5dqghs0a7o00cvq1qgrnr3m9k.apps.googleusercontent.com'),
  ]);

  runApp(MyApp());

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => MyApp()),
  ));
}

Future<void> initializeDefault() async {
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Initialized default app $app');

  await FirebaseAppCheck.instance.activate(
    //androidProvider: AndroidProvider.debug,
    androidProvider: AndroidProvider.playIntegrity,
  );
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Emmu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.red,
        ),
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router,
      //routerDelegate: _router.routerDelegate,
      //routeInformationParser: _router.routeInformationParser,
      //routeInformationProvider: _router.routeInformationProvider,// new
      //home: const MyHomePage(title: 'Flutter Demo Prueba Page'),
      //home: const AuthGate(),
    );
  }

  //String CurrentUserID;

  //set SetCurrentUserID(String userEmailID) {
  //  CurrentUserID = userEmailID;
  //}

  final GoRouter _router = GoRouter(routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return Eventos();
        } else {
          return InicioSesion();
        }
      },
    ),
    GoRoute(
      path: '/inicioSesion',
      builder: (context, state) => InicioSesion(),
    ),
    //routes: [
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
              SignedIn user => state.user,
              UserCreated state => state.credential.user,
              _ => null
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
    //},
    //routes: [
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
    //],
    //),
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
