import 'package:cloud_firestore/cloud_firestore.dart';
import 'CajonAppBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CartaEvento.dart';

class Eventos extends StatefulWidget {
  const Eventos({super.key});

  @override
  _EventosState createState() => _EventosState();
}

class _EventosState extends State<Eventos> {
  final CollectionReference eventos =
  FirebaseFirestore.instance.collection('Evento');

  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Eventos',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Cajon(),
      body: _userEmail == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        //FILTRA LOS EVENTOS QUE *NO* HA CREADO EL USUARIO QUE INICIA SESION
        stream: eventos
            .where('IdUsuario', isNotEqualTo: _userEmail)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var evento = data.docs[index];
              var idUsuario = evento['IdUsuario'].toString();

              // Asumiendo que tienes un campo userId en ClasPart

              // Verificar que idUsuario no sea nulo o vacío
              //REALMENTE NO ES NECESARIO PORQUE CADA EVENTO SOLO PUEDE CREARSE TRAS REGISTRARSE/INICIAR SESIÓN
              //POR LO QUE TENDRÍA SIEMPRE UN IDUSUARIO
              //if (idUsuario.isEmpty) {
              //  return ListTile();
              //}

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Usuario')
                    .where('email', isEqualTo: idUsuario)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${userSnapshot.error}'));
                  }

                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var userData = userSnapshot.data?.docs.first;

                  if (userData == null) {
                    return Center(child: Text('Usuario no encontrado'));
                  }

                  return Column(
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(evento['Titulo']),
                            SizedBox(height: 8.0),
                            Text(evento['Descripcion']),
                          ],
                        ),
                        trailing: Container(
                          width: 200,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${evento['Presupuesto']} €',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartaEvento(
                                foto: userData['Foto'], // ?? '',
                                nombre: userData['Nombre'],
                                apellido: userData['Apellido'],
                                titulo: evento['Titulo'],
                                descripcion: evento['Descripcion'],
                                ubicacion: evento['Ubicacion'],
                                fecha: evento['Fecha'],
                                tienePresupuesto:
                                evento['TienePresupuesto'],
                                presupuesto: evento['Presupuesto'],
                                idUsuario: userData['email'],
                                docId: evento['docId'].toString(),
                                onChatPressed: () {
                                  // Aquí puedes agregar la lógica para navegar a la página de chat
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
