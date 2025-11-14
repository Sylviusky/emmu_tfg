import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CajonAppBar.dart';
import 'CartaEvento.dart';
import 'CartaClasPart.dart';

class MisAnuncios extends StatefulWidget {
  const MisAnuncios({super.key});

  @override
  State<MisAnuncios> createState() => _MisAnunciosState();
}

class _MisAnunciosState extends State<MisAnuncios> {
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

  final CollectionReference eventos =
  FirebaseFirestore.instance.collection('Evento');
  final CollectionReference clasPart =
  FirebaseFirestore.instance.collection('ClasPart');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Mis anuncios',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Cajon(),
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: const TabBar(
              labelColor: Colors.white, // Color del texto seleccionado
              unselectedLabelColor: Colors.white70, // Color del texto no seleccionado
              labelStyle: TextStyle(fontSize: 20), // Estilo del texto no seleccionado
              unselectedLabelStyle: TextStyle(fontSize: 16), // Estilo del texto no seleccionado
              indicatorColor: Colors.white, // Color del indicador de la pestaña seleccionada
              indicatorSize: TabBarIndicatorSize.label, // Tamaño del indicador de la pestaña seleccionada
              tabs: <Widget>[
                Tab(
                  text: "Eventos",

                ),
                Tab(
                  text: "Clases",
                ),
              ],
            ),
              automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              TabBarView(
                children: <Widget>[
                  //CONTENIDO DE LA TAB DE EVENTOS
                  _userEmail == null
                      ? Center(child: CircularProgressIndicator())
                      : FutureBuilder<QuerySnapshot>(
                          // Get user data first for the header
                          future: FirebaseFirestore.instance
                              .collection('Usuario')
                              .where('email', isEqualTo: _userEmail)
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (userSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${userSnapshot.error}'));
                            }

                            final userData = userSnapshot.data?.docs.first;
                            if (userData == null) {
                              return Center(
                                  child: Text('Usuario no encontrado'));
                            }

                            return StreamBuilder<QuerySnapshot>(
                              //FILTRA LOS EVENTOS QUE HA CREADO EL USUARIO QUE INICIA SESION
                              stream: eventos
                                  .where('IdUsuario', isEqualTo: _userEmail)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                final data = snapshot.requireData;

                                return ListView.builder(
                                  itemCount: data.size + 1, // +1 for header
                                  itemBuilder: (context, index) {
                                    // First item is always the header
                                    if (index == 0) {
                                      return ListTile(
                                        tileColor: Colors.redAccent,
                                        title: Text("Anuncia tu Evento",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CartaEventoEdit(
                                                foto: userData['Foto'] ?? '',
                                                nombre: userData['Nombre'],
                                                apellido: userData['Apellido'],
                                                titulo: '',
                                                descripcion: 'Descripcion',
                                                ubicacion:
                                                    GeoPoint(39.4699, -0.3763),
                                                fecha: Timestamp.now(),
                                                tienePresupuesto: true,
                                                presupuesto: 0,
                                                idUsuario: userData['email'],
                                                docId: 'docID',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }

                                    // Other items are event documents
                                    var evento = data.docs[index - 1];
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              foto: userData['Foto'] ?? '',
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
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                  _userEmail == null
                      ? Center(child: CircularProgressIndicator())
                      : FutureBuilder<QuerySnapshot>(
                          // Get user data first for the header
                          future: FirebaseFirestore.instance
                              .collection('Usuario')
                              .where('email', isEqualTo: _userEmail)
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (userSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${userSnapshot.error}'));
                            }

                            final userData = userSnapshot.data?.docs.first;
                            if (userData == null) {
                              return Center(
                                  child: Text('Usuario no encontrado'));
                            }

                            return StreamBuilder<QuerySnapshot>(
                              //FILTRA LAS CLASES QUE HA CREADO EL USUARIO QUE INICIA SESION
                              stream: clasPart
                                  .where('IdUsuario', isEqualTo: _userEmail)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                final data = snapshot.requireData;

                                return ListView.builder(
                                  itemCount: data.size + 1, // +1 for header
                                  itemBuilder: (context, index) {
                                    // First item is always the header
                                    if (index == 0) {
                                      return ListTile(
                                        tileColor: Colors.redAccent,
                                        title: Text("Anuncia tus Clases",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CartaClasPartEdit(
                                                foto: userData['Foto'] ?? '',
                                                nombre: userData['Nombre'],
                                                apellido: userData['Apellido'],
                                                titulo: 'Título',
                                                descripcion: 'Descripcion',
                                                horasDisp: 0,
                                                negociable: false,
                                                coste: 0,
                                                idUsuario: userData['email'],
                                                id: 'id',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }

                                    // Other items are class documents
                                    var clasPartDoc = data.docs[index - 1];
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(clasPartDoc['Titulo']),
                                          SizedBox(height: 8.0),
                                          Text(clasPartDoc['Descripcion']),
                                        ],
                                      ),
                                      trailing: Container(
                                        width: 200,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${clasPartDoc['Coste']} €',
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
                                            builder: (context) => CartaClasPart(
                                              foto: userData['Foto'] ?? '',
                                              nombre: userData['Nombre'],
                                              apellido: userData['Apellido'],
                                              titulo: clasPartDoc['Titulo'],
                                              descripcion:
                                                  clasPartDoc['Descripcion'],
                                              horasDisp: clasPartDoc['HorasDisp'],
                                              negociable:
                                                  clasPartDoc['Negociable'],
                                              coste: clasPartDoc['Coste'],
                                              idUsuario: userData['email'],
                                              id: clasPartDoc['id'].toString(),
                                              onChatPressed: () {
                                                // Aquí puedes agregar la lógica para navegar a la página de chat
                                              },
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}