import 'package:emmu_tfg/InicioSesion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CajonAppBar.dart';



class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<StatefulWidget> createState()  => _Configuracion();
}

class _Configuracion extends State<Configuracion>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: const Text('Configuración',
                style: TextStyle(fontSize: 25, color: Colors.white),
          ),
        iconTheme: IconThemeData(color: Colors.white),
          ),
          drawer: Cajon(),
          body: ListView(
              children: <Widget>[
                ListTile(
                  title: const Text("Cerrar sesion"),
                  onTap: () async {
                    // Cerrar sesión en Firebase Authentication
                    await FirebaseAuth.instance.signOut();

                    // Eliminar datos de SharedPreferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('userEmail');
                    await prefs.remove('userToken');

                    // Navegar a la pantalla de inicio de sesión
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const InicioSesion())
                    );
                    },
                ),
              ]
          )

    );
  }


}