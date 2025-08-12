import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CajonAppBar.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final CollectionReference eventos =
      FirebaseFirestore.instance.collection('Evento');

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
        body: StreamBuilder<QuerySnapshot>(
          stream: eventos.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                var idUsuario = evento['IdUsuario']
                    .toString(); // Asumiendo que tienes un campo userId en ClasPart
                //No tengo userID ni en clases ni eventos. Hace falta??? PREGUNTAR

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Usuario')
                      .doc(idUsuario)
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

                    var userData = userSnapshot.data;

                    if (userData == null) {
                      return Center(child: Text('Usuario no encontrado'));
                    }

                    return ListTile(
                        title: Text('PÁGINA DE LOS MENSAJES',
                            style: TextStyle(color: Colors.green, fontSize: 30))
                        /*title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.docs[index]['Titulo']),
                          SizedBox(height: 8.0),
                          Text(data.docs[index]['Descripcion']),
                        ],
                      ),
                      trailing: Container(
                        width: 200,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${data.docs[index]['Presupuesto']} €',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ),
                      onTap: () {
                        */ /*Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPersonal(
                              foto: userData['Foto'] ?? '',
                              nombre: userData['Nombre'],
                              apellido: userData['Apellido'],
                              titulo: evento['Titulo'],
                              descripcion: evento['Descripcion'],
                              ubicacion: evento['Ubicacion'],
                              fecha: evento['Fecha'],
                              tienePresupuesto: evento['TienePresupuesto'],
                              presupuesto: evento['Presupuesto'],
                              onChatPressed: () {
                                // Aquí puedes agregar la lógica para navegar a la página de chat
                              },
                            ),
                          ),
                        );*/ /*
                      },*/
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
