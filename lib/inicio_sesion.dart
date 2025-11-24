import 'package:emmu_tfg/eventos_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registro.dart';
import 'reset_password.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesion();
}

/// Ensures a user document exists in Firestore with the correct structure.
/// This function works for both new users (register) and existing users (login).
Future<void> _ensureUserDocumentExists(User user) async {
  try {
    print('_ensureUserDocumentExists: Starting for user ${user.uid}');
    final uid = user.uid;
    final normalizedEmail = user.email?.toLowerCase() ?? '';
    
    if (normalizedEmail.isEmpty) {
      print('Warning: User email is null, cannot create document');
      return;
    }

    print('_ensureUserDocumentExists: Checking document existence for UID: $uid');
    final userDocRef = FirebaseFirestore.instance
        .collection('Usuario')
        .doc(uid);

    final userDoc = await userDocRef.get();
    print('_ensureUserDocumentExists: Document exists: ${userDoc.exists}');

    // Get photo URL from user or use default
    final photoUrl = user.photoURL ?? 'assets/default_user.jpg';
    print('_ensureUserDocumentExists: Photo URL: $photoUrl');

    // If document doesn't exist, create it
    if (!userDoc.exists) {
      print('_ensureUserDocumentExists: Creating new document for user');
      // Parse name from displayName or email
      String nombre = '';
      String apellido = '';
      
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        print('_ensureUserDocumentExists: Using displayName: ${user.displayName}');
        final nameParts = user.displayName!.split(' ');
        nombre = nameParts.isNotEmpty ? nameParts[0] : '';
        apellido = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      } else {
        // Fallback: use email prefix as name
        print('_ensureUserDocumentExists: Using email prefix as name');
        nombre = normalizedEmail.split('@')[0];
      }

      Map<String, dynamic> userData = {
        'email': normalizedEmail,
        'Nombre': nombre,
        'Apellido': apellido,
        'Telefono': '',
        'Foto': photoUrl, // Always set Foto field, even if it's the default
      };

      print('_ensureUserDocumentExists: Creating document with data: $userData');
      await userDocRef.set(userData);
      print('_ensureUserDocumentExists: Successfully created user document for UID: $uid');
    } else {
      print('_ensureUserDocumentExists: Document already exists for UID: $uid');
      // Update Foto field if it's missing, empty, or is the default and user has a Google photo
      final existingData = userDoc.data() as Map<String, dynamic>?;
      final existingFoto = existingData?['Foto']?.toString();
      
      // If Foto is missing, empty, or default, and user has a Google photo, update it
      if (user.photoURL != null && user.photoURL!.isNotEmpty && 
          (existingFoto == null || existingFoto.isEmpty || existingFoto == 'assets/default_user.jpg')) {
        print('_ensureUserDocumentExists: Updating Foto field with Google photo');
        await userDocRef.update({'Foto': photoUrl});
      } else if ((existingFoto == null || existingFoto.isEmpty) && user.photoURL == null) {
        // Ensure Foto field always exists, even if it's the default
        print('_ensureUserDocumentExists: Setting Foto field to default');
        await userDocRef.update({'Foto': photoUrl});
      }
    }

    // Save email to SharedPreferences (normalized to lowercase)
    print('_ensureUserDocumentExists: Saving email to SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', normalizedEmail);
    print('_ensureUserDocumentExists: Successfully saved email to SharedPreferences');
  } catch (e, stackTrace) {
    print('Error ensuring user document exists:');
    print('  Error: $e');
    print('  Type: ${e.runtimeType}');
    print('  Stack trace: $stackTrace');
    // Don't throw - we don't want to block the sign-in process
    // But log it so we can debug
  }
}

class _InicioSesion extends State<InicioSesion> {
  waitFor(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
    _emailController.clear();
    _passwordController.clear();
  }

  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final database = FirebaseDatabase.instance.ref();
  final GlobalKey<FormState> _formKeyIni = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _mostrarError = false;
  String _error = '';
  bool _isLoadingGoogle = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 40.0)),
                const Image(
                  image: AssetImage('assets/logortr.png'),
                  width: 280,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 40.0)),
                Form(
                  key: _formKeyIni,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 350.0,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red.shade100),
                            ),
                            hintText: 'Introduce tu email',
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                      SizedBox(
                        width: 350.0,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red.shade100),
                            ),
                            hintText: 'Introduce tu contraseña',
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obligatorio';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.red,
                            value: !_obscureText,
                            onChanged: (bool? value) {
                              setState(() {
                                _obscureText = !value!;
                              });
                            },
                          ),
                          const Text('Mostrar contraseña'),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                      SizedBox(
                        width: 350.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKeyIni.currentState!.validate()) {
                              String email = _emailController.text;
                              String password = _passwordController.text;

                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(email: email, password: password);

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('userEmail', email.toLowerCase());

                                if (!mounted) return;
                                setState(() {
                                  _mostrarError = false;
                                  _error = '';
                                });

                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Eventos()),
                                );

                                waitFor(2);
                              } on FirebaseAuthException catch (e) {
                                print('FirebaseAuthException code from Firebase: ${e.code}');
                                setState(() {
                                  _mostrarError = true; // Show the error container

                                  if (e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
                                    _error = 'El correo electrónico o la contraseña son incorrectos.';
                                  } else if (e.code == 'invalid-email') {
                                    _error = 'El formato del correo electrónico es incorrecto.';
                                  } else if (e.code == 'too-many-requests') {
                                    _error = 'Demasiados intentos fallidos. Inténtalo más tarde.';
                                  } else if (e.code == 'network-request-failed') {
                                    _error = 'Error de red. Verifica tu conexión a internet.';
                                  } else if (e.code == 'app-not-authorized') {
                                    _error =
                                        'Error de autenticación de la aplicación. Inténtalo más tarde.';
                                  } else if (e.code == 'app-check-token-error') {
                                    _error =
                                        'Error de verificación de la aplicación. Inténtalo más tarde.';
                                  }
                                  // Add any other specific codes you observe from the print statement above
                                  else {
                                    _error = 'Error al iniciar sesión. Inténtalo de nuevo más tarde.';
                                    print('Unhandled FirebaseAuthException: ${e.code} - ${e.message}'); // Log unhandled ones
                                  }
                                });
                              } catch (e) {
                                print(e);
                                setState(() {
                                  _error = 'Error inesperado. Inténtalo más tarde.';
                                  _mostrarError = true;
                                });
                              }
                            }
                          },
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ResetPassword()),
                          );
                        },
                        child: const Text(
                          '¿Has olvidado tu contraseña?',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      _mostrarError
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          width: 350,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                height: 56.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Registro()),
                                    );
                                  },
                                  child: const Text(
                                    'Regístrate',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                height: 56.0,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: const BorderSide(color: Colors.grey),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                  onPressed: _isLoadingGoogle ? null : () async {
                                    setState(() {
                                      _isLoadingGoogle = true;
                                      _mostrarError = false;
                                      _error = '';
                                    });

                                    try {
                                      print('Starting Google Sign-In...');
                                      // IMPORTANT: For Firebase Authentication, we need to specify serverClientId
                                      // This should be the Web OAuth client ID from google-services.json
                                      // Use the Web client (client_type: 3) from google-services.json > oauth_client array
                                      final GoogleSignIn googleSignIn = GoogleSignIn(
                                        scopes: ['email'],
                                        // Use the Web OAuth client ID from google-services.json
                                        // This is required to get the idToken needed for signInWithCredential
                                        // Client ID from google-services.json: client_type 3 (Web client)
                                        serverClientId: '122024969889-t7ih7im7p32q4e7oocljnkkefgdhoke2.apps.googleusercontent.com',
                                      );

                                      // Ensure the account chooser appears every time by clearing previous sessions
                                      try {
                                        await googleSignIn.signOut();
                                      } catch (e) {
                                        print('GoogleSignIn signOut warning: $e');
                                      }
                                      try {
                                        await googleSignIn.disconnect();
                                      } catch (e) {
                                        print('GoogleSignIn disconnect warning: $e');
                                      }

                                      // Trigger the authentication flow
                                      print('Requesting Google Sign-In...');
                                      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

                                      if (googleUser == null) {
                                        // User canceled the sign-in
                                        print('User canceled Google Sign-In');
                                        if (!mounted) return;
                                        setState(() {
                                          _isLoadingGoogle = false;
                                        });
                                        return;
                                      }

                                      print('Google user obtained: ${googleUser.email}');

                                      // Obtain the auth details from the request
                                      print('Getting authentication details...');
                                      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                                      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
                                        print('Error: accessToken or idToken is null');
                                        if (!mounted) return;
                                        setState(() {
                                          _isLoadingGoogle = false;
                                          _mostrarError = true;
                                          _error = 'Error al obtener credenciales de Google. Inténtalo de nuevo.';
                                        });
                                        return;
                                      }

                                      print('Creating Firebase credential...');
                                      // Create a new credential
                                      final credential = GoogleAuthProvider.credential(
                                        accessToken: googleAuth.accessToken,
                                        idToken: googleAuth.idToken,
                                      );

                                      // Sign in to Firebase with the Google credential
                                      // This will create the user automatically if they don't exist (login OR register)
                                      print('Signing in to Firebase...');
                                      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                                      if (userCredential.user != null) {
                                        final user = userCredential.user!;
                                        print('User authenticated: ${user.uid}, Email: ${user.email}');
                                        print('Is new user: ${userCredential.additionalUserInfo?.isNewUser ?? false}');
                                        
                                        // Ensure user document exists in Firestore
                                        // This will create the document if it doesn't exist (for new users)
                                        print('Ensuring user document exists...');
                                        try {
                                          await _ensureUserDocumentExists(user);
                                          print('User document ensured successfully');
                                        } catch (e) {
                                          print('Error ensuring user document exists: $e');
                                          print('Stack trace: ${StackTrace.current}');
                                          // Continue anyway - don't block the sign-in
                                        }

                                        if (!mounted) return;
                                        setState(() {
                                          _isLoadingGoogle = false;
                                        });

                                        if (!context.mounted) return;
                                        print('Navigation to Eventos page...');
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => Eventos()),
                                        );
                                      } else {
                                        print('Error: userCredential.user is null');
                                        if (!mounted) return;
                                        setState(() {
                                          _isLoadingGoogle = false;
                                          _mostrarError = true;
                                          _error = 'No se pudo autenticar con Google. Inténtalo de nuevo.';
                                        });
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      print('FirebaseAuthException during Google Sign-In:');
                                      print('  Code: ${e.code}');
                                      print('  Message: ${e.message}');
                                      print('  Email: ${e.email}');
                                      print('  Credential: ${e.credential}');
                                      if (!mounted) return;
                                      setState(() {
                                        _isLoadingGoogle = false;
                                        _mostrarError = true;
                                        if (e.code == 'account-exists-with-different-credential') {
                                          _error = 'Ya existe una cuenta con este email. Usa otro método de inicio de sesión.';
                                        } else if (e.code == 'invalid-credential') {
                                          _error = 'Credenciales inválidas. Inténtalo de nuevo.';
                                        } else if (e.code == 'operation-not-allowed') {
                                          _error = 'El inicio de sesión con Google no está permitido.';
                                        } else if (e.code == 'network-request-failed') {
                                          _error = 'Error de red. Verifica tu conexión a internet.';
                                        } else {
                                          _error = 'Error al iniciar sesión con Google: ${e.message ?? "Inténtalo de nuevo."}';
                                        }
                                      });
                                    } catch (e, stackTrace) {
                                      print('Error signing in with Google:');
                                      print('  Error: $e');
                                      print('  Type: ${e.runtimeType}');
                                      print('  Stack trace: $stackTrace');
                                      if (!mounted) return;
                                      setState(() {
                                        _isLoadingGoogle = false;
                                        _mostrarError = true;
                                        _error = 'Error al iniciar sesión con Google. Inténtalo de nuevo.';
                                      });
                                    }
                                  },
                                  child: _isLoadingGoogle
                                      ? const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.network(
                                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                                  width: 18,
                                                  height: 18,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.g_mobiledata, size: 18);
                                                  },
                                                ),
                                                const SizedBox(width: 6),
                                                const Flexible(
                                                  child: Text(
                                                    'Continuar con',
                                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Google',
                                              style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}