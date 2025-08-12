import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'CajonAppBar.dart';
import 'CartaClasPart.dart';

class ClasesPage extends StatefulWidget {
  const ClasesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClasesPageState();
}

class _ClasesPageState extends State<ClasesPage> {
  final CollectionReference clasPart =
      FirebaseFirestore.instance.collection('ClasPart');

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
            'Clases particulares',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Cajon(),
        body: _userEmail == null
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder<QuerySnapshot>(
                stream: clasPart
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
                      var clasPart = data.docs[index];
                      var idUsuario = clasPart['IdUsuario']
                          .toString(); // Asumiendo que tienes un campo userId en ClasPart
                      //No tengo userID ni en clases ni eventos. Hace falta??? PREGUNTAR

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

                          return ListTile(
                            title: Column(
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
                                '${data.docs[index]['Coste']} €',
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
                                    titulo: clasPart['Titulo'],
                                    descripcion: clasPart['Descripcion'],
                                    coste: clasPart['Coste'],
                                    negociable: clasPart['Negociable'],
                                    nombre: userData['Nombre'],
                                    apellido: userData['Apellido'],
                                    horasDisp: clasPart['HorasDisp'],
                                    idUsuario: clasPart['IdUsuario'],
                                    id: clasPart['id'].toString(),
                                    //editable: false,
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
    );
  }
}
