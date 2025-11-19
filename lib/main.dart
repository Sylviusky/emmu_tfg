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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

AndroidProvider _getAndroidProvider() {
  // Use Play Integrity for release builds, but allow the debug provider so that
  // emulators/dev devices show the App Check debug token in the logs.
  if (kReleaseMode) {
    return AndroidProvider.playIntegrity;
  }
  return AndroidProvider.debug;
}

/// Ensures a user document exists in Firestore with the correct structure.
/// This is called when a user signs in (with email or Google).
Future<void> _ensureUserDocumentExists(User user) async {
  try {
    final uid = user.uid;
    final normalizedEmail = user.email?.toLowerCase() ?? '';
    
    if (normalizedEmail.isEmpty) {
      print('Warning: User email is null, cannot create document');
      return;
    }

    final userDocRef = FirebaseFirestore.instance
        .collection('Usuario')
        .doc(uid);

    final userDoc = await userDocRef.get();

    // Get photo URL from user or use default
    final photoUrl = user.photoURL ?? 'assets/default_user.jpg';

    // If document doesn't exist, create it
    if (!userDoc.exists) {
      // Parse name from displayName or email
      String nombre = '';
      String apellido = '';
      
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final nameParts = user.displayName!.split(' ');
        nombre = nameParts.isNotEmpty ? nameParts[0] : '';
        apellido = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      } else {
        // Fallback: use email prefix as name
        nombre = normalizedEmail.split('@')[0];
      }

      Map<String, dynamic> userData = {
        'email': normalizedEmail,
        'Nombre': nombre,
        'Apellido': apellido,
        'Telefono': '',
        'Foto': photoUrl, // Always set Foto field, even if it's the default
      };

      await userDocRef.set(userData);
      print('Created user document for Google Sign-In user: $uid');
    } else {
      // Update Foto field if it's missing, empty, or is the default and user has a Google photo
      final existingData = userDoc.data() as Map<String, dynamic>?;
      final existingFoto = existingData?['Foto']?.toString();
      
      // If Foto is missing, empty, or default, and user has a Google photo, update it
      if (user.photoURL != null && user.photoURL!.isNotEmpty && 
          (existingFoto == null || existingFoto.isEmpty || existingFoto == 'assets/default_user.jpg')) {
        print('Updating Foto field with Google photo');
        await userDocRef.update({'Foto': photoUrl});
      } else if ((existingFoto == null || existingFoto.isEmpty) && user.photoURL == null) {
        // Ensure Foto field always exists, even if it's the default
        print('Setting Foto field to default');
        await userDocRef.update({'Foto': photoUrl});
      }
    }

    // Save email to SharedPreferences (normalized to lowercase)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', normalizedEmail);
  } catch (e) {
    print('Error ensuring user document exists: $e');
    // Don't throw - we don't want to block the sign-in process
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: _getAndroidProvider(),
    );
    print('FirebaseAppCheck activated successfully');
  } catch (e) {
    print('Error activating FirebaseAppCheck: $e');
    // Continue anyway - don't block the app
  }

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
        clientId:
        '122024969889-t7ih7im7p32q4e7oocljnkkefgdhoke2.apps.googleusercontent.com'),
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
        // Use StreamBuilder to handle auth state changes properly
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show loading while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // If user is authenticated, show Eventos
            if (snapshot.hasData && snapshot.data != null) {
              return const Eventos();
            }

            // If no user, show login screen
            return const InicioSesion();
          },
        );
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
          AuthStateChangeAction((context, state) async {
            final user = switch (state) {
              SignedIn signedIn => signedIn.user,
              UserCreated created => created.credential.user,
              _ => null,
            };
            if (user == null) {
              return;
            }

            // Ensure user document exists in Firestore (for both email and Google sign-in)
            await _ensureUserDocumentExists(user);

            if (state is UserCreated) {
              user.updateDisplayName(user.email!.split('@')[0]);
            }
            
            // Only send email verification for email/password sign-ups (not Google)
            // Google accounts are automatically verified
            if (!user.emailVerified && !user.providerData.any((info) => info.providerId == 'google.com')) {
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
