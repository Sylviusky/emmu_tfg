import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Eventos_Page.dart';
import 'Clases_Page.dart';
import 'Config_Page.dart';
import 'MisAnuncios_Page.dart';
import 'Noticias_Page.dart';

class CartaEvento2 extends StatelessWidget {
  final CollectionReference eventos =
      FirebaseFirestore.instance.collection('Evento');

  final database = FirebaseDatabase.instance.ref();

  CartaEvento2({super.key});

  @override
  Widget build(BuildContext context) {
    //AuthController authController = Get.find();
    //EventosController moviesController = Get.put(EventosController());
    //moviesController.getMoviesFromFirebase();

    final dailySpecialRef = database.child('dailySpecial/');

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Eventos'),
        ),
        drawer: Drawer(
          backgroundColor: Colors.red,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                //decoration: BoxDecoration(color: Colors.red),
                child: Image(
                  image: AssetImage('assets/logobtr.png'),
                  alignment: Alignment.center,
                ),
              ),
              ListTile(
                  leading: const Icon(Icons.business_sharp),
                  iconColor: Colors.white,
                  title: const Text(
                    "Eventos",
                  ),
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Eventos()));
                  }),
              ListTile(
                  leading: const Icon(Icons.school),
                  iconColor: Colors.white,
                  title: const Text("Clases particulares"),
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ClasesPage()));
                  }),
              ListTile(
                  leading: const Icon(Icons.person),
                  iconColor: Colors.white,
                  title: const Text("Mis anuncios"),
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MisAnuncios()));
                  }),
              ListTile(
                  leading: const Icon(Icons.newspaper),
                  iconColor: Colors.white,
                  title: const Text("Noticias"),
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Noticias()));
                  }),
              ListTile(
                  leading: const Icon(Icons.settings),
                  iconColor: Colors.white,
                  title: const Text("Configuración"),
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Configuracion()));
                  }),
            ],
          ),
        ),
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
                return ListTile(
                  title: Text(data.docs[index]['Titulo']),
                  subtitle: Text(data.docs[index]['Descripcion']),
                  onTap: () {},
                );
              },
            );
          },
        ),

        /*ListView(
              children: <Widget>[
                ElevatedButton(onPressed: (){dailySpecialRef.set({
                  'description': 'cafe',
                  'price': 1
                }).then((_) => print("Se ha hecho"));},
                    child: const Text("Prueba")),
                ListTile(
                  title: const Text("Prueba"),
                  onTap: (){},
                ),
              ]
          )*/
      ),
    );
  }
}
