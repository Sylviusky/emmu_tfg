import 'package:emmu_tfg/Eventos_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Registro.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesion();
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
                      const Padding(padding: EdgeInsets.symmetric(vertical: 35.0)),
                      ElevatedButton(
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
                              UserCredential userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(email: email, password: password);

                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('userEmail', email);

                              setState(() {
                                _mostrarError = false;
                                _error = '';
                              });

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
                      const Padding(padding: EdgeInsets.symmetric(vertical: 35.0)),
                      const Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(fontSize: 15, color: Colors.redAccent),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Registro()),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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