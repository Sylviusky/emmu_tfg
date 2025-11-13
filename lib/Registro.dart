//import 'dart:html';
//import 'dart:io';

//import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Eventos_Page.dart';
import 'auth_gate.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:go_router/go_router.dart'; // new
import 'package:provider/provider.dart'; // new
import 'app_state.dart'; // new

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

Future<UserCredential?> registroUsuario(String email, String password, String nombre,
    String apellido, String telf) async {
  try {
    // Create user in Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the user UID
    String uid = userCredential.user!.uid;

    // Create user document in Firestore with UID as document ID
    await FirebaseFirestore.instance
        .collection('Usuario')
        .doc(uid)
        .set({
      'email': email,
      'Nombre': nombre,
      'Apellido': apellido,
      'Telefono': telf.isEmpty ? '' : telf,
      // Note: Password is NOT stored in Firestore for security reasons
    });

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      throw Exception('Ya existe un usuario con este email.');
    } else if (e.code == 'weak-password') {
      throw Exception('La contraseña es demasiado débil.');
    } else if (e.code == 'invalid-email') {
      throw Exception('El email no es válido.');
    } else {
      throw Exception('Error al crear el usuario: ${e.message}');
    }
  } catch (e) {
    throw Exception('Error inesperado: ${e.toString()}');
  }
}

class _RegistroState extends State<Registro> {
  final database = FirebaseDatabase.instance.ref();

  //final GlobalKey<FormState> _formKeyIni = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyReg = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String email = '';
  String password = '';
  String nombre = '';
  String apellido = '';
  String telf = '';

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final database = FirebaseDatabase.instance.ref();

    //final GlobalKey<FormState> _formKeyReg = GlobalKey<FormState>();

    return
      //WillPopScope(
      //onWillPop: () async => false,
      //child:
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width, // added
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                ),
                const Image(
                  image: AssetImage('assets/logortr.png'),
                  width: 200,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKeyReg,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 350,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nombreController,
                                    decoration: InputDecoration(
                                      labelText: 'Nombre *',
                                      labelStyle: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 18),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red.shade100),
                                      ),
                                      hintText: 'Introduce tu nombre',
                                    ),
                                    onChanged: (value) {
                                      nombre = value;
                                    },
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Por favor, introduce tu nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  TextFormField(
                                    controller: _apellidosController,
                                    decoration: InputDecoration(
                                      labelText: 'Apellidos *',
                                      labelStyle: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 18),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red.shade100),
                                      ),
                                      hintText: 'Introduce tus apellidos',
                                    ),
                                    onChanged: (value) {
                                      apellido = value;
                                    },
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Por favor, introduce tus apellidos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email *',
                                      labelStyle: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 18),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red.shade100),
                                      ),
                                      hintText: 'Introduce tu email',
                                    ),
                                    onChanged: (value) {
                                      email = value;
                                    },
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Por favor, introduce tu email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  TextFormField(
                                    controller: _telfController,
                                    decoration: InputDecoration(
                                      labelText: 'Teléfono',
                                      labelStyle: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 18),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red.shade100),
                                      ),
                                      hintText: 'Introduce tu teléfono',
                                    ),
                                    onChanged: (value) {
                                      telf = value;
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña *',
                                      labelStyle: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 18),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red.shade100),
                                      ),
                                      hintText: 'Introduce tu contraseña',
                                    ),
                                    onChanged: (value) {
                                      password = value;
                                    },
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Por favor, introduce tu contraseña';
                                      } else if (!RegExp(
                                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                                          .hasMatch(value)) {
                                        return 'La contraseña debe contener al menos una mayúscula, una minúscula y un número';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Verificar contraseña *',
                                      labelStyle: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 18),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red.shade100),
                                      ),
                                      hintText: 'Introduce tu contraseña nuevamente',
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, verifica tu contraseña';
                                      } else if (_passwordController.text.isEmpty) {
                                        return 'Por favor, introduce primero tu contraseña';
                                      } else if (value != _passwordController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () async {
                                // Validate will return true if the form is valid, or false if
                                // the form is invalid.
                                if (_formKeyReg.currentState!.validate()) {
                                  // Show loading indicator
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Procesando datos...')));

                                  try {
                                    // Register user in Firebase Auth and Firestore
                                    UserCredential? userCredential = await registroUsuario(
                                        email, password, nombre, apellido, telf);

                                    if (userCredential != null) {
                                      // Save email to SharedPreferences
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString('userEmail', email);

                                      // Clear form fields
                                      _nombreController.clear();
                                      _apellidosController.clear();
                                      _emailController.clear();
                                      _telfController.clear();
                                      _passwordController.clear();
                                      _confirmPasswordController.clear();

                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Usuario creado exitosamente'),
                                              backgroundColor: Colors.green));

                                      // Navigate to Eventos page
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const Eventos()),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                                            backgroundColor: Colors.red));
                                  }
                                }
                              },
                              child: const Text(
                                'Crear usuario',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      //),
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
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
            );
          },
          routes: [
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
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return Consumer<ApplicationState>(
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
            );
          },
        ),
      ],
    ),
  ],
);
