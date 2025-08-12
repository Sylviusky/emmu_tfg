import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmu_tfg/CartaNoticia.dart';
import 'CajonAppBar.dart';
import 'package:flutter/material.dart';

class Noticias extends StatefulWidget {
  const Noticias({super.key});

  @override
  _NoticiasState createState() => _NoticiasState();
}

class _NoticiasState extends State<Noticias> {
  final CollectionReference noticias =
      FirebaseFirestore.instance.collection('Noticia');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Noticias',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Cajon(),
        body: StreamBuilder<QuerySnapshot>(
          //FILTRA LOS EVENTOS QUE *NO* HA CREADO EL USUARIO QUE INICIA SESION
          stream: noticias.snapshots(),
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
                var noticia = data.docs[index];

                return FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance.collection('Usuario').get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${userSnapshot.error}'));
                    }

                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(noticia['Titulo']),
                          SizedBox(height: 8.0),
                          Text(noticia['Descripcion']),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartaNoticia(
                              titulo: noticia['Titulo'],
                              descripcion: noticia['Descripcion'],
                              fecha: noticia['Fecha'],
                              docId: noticia['id'],
                              enlace: noticia['Enlace'],
                              organizacion: noticia['Organizacion'],
                              pais: noticia['Pais'],
                              region: noticia['Region'],
                              //onChatPressed: () {
                              // Aquí puedes agregar la lógica para navegar a la página de chat
                              //},
                            ),
                          ),
                        );
                      },
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
