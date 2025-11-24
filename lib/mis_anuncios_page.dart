import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cajon_app_bar.dart';
import 'carta_evento.dart';
import 'carta_clas_part.dart';
import 'utils/geo_point_parser.dart';

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

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userEmail = prefs.getString('userEmail')?.toLowerCase();
      });
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Cajon(),
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
                        //CARGA TODOS LOS EVENTOS Y FILTRAMOS EN EL CLIENTE PARA MANEJAR MAYUSCULAS/MINUSCULAS
                        stream: eventos.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting || !snapshot.hasData) {
                            return Center(
                                child: CircularProgressIndicator());
                          }

                          final allData = snapshot.data!;
                          // Filtrar en el cliente normalizando emails para manejar mayúsculas/minúsculas
                          final filteredDocs = allData.docs.where((doc) {
                            final docIdUsuario = doc['IdUsuario']?.toString().toLowerCase() ?? '';
                            return docIdUsuario == _userEmail?.toLowerCase();
                          }).toList();
                          
                          final data = filteredDocs;

                          return ListView.separated(
                            itemCount: data.length + 1, // +1 for header
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
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
                                  onTap: () async {
                                    final userMap = userData.data() as Map<String, dynamic>;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CartaEventoEdit(
                                              foto: userMap['Foto'] ?? '',
                                              nombre: userMap['Nombre'],
                                              apellido: userMap['Apellido'],
                                              titulo: '',
                                              descripcion: 'Descripcion',
                                              ubicacion:
                                              GeoPoint(39.4699, -0.3763),
                                              fecha: Timestamp.now(),
                                              tienePresupuesto: true,
                                              presupuesto: 0,
                                              idUsuario: userMap['email'],
                                              docId: 'docID',
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }

                              // Other items are event documents
                              var evento = data[index - 1];
                              return InkWell(
                                onTap: () async {
                                  final ubicacion = parseDynamicToGeoPoint(evento['Ubicacion']);
                                  if (ubicacion == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Este evento no tiene una ubicación válida guardada.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  final userMap = userData.data() as Map<String, dynamic>;
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CartaEvento(
                                        foto: userMap['Foto'] ?? '',
                                        nombre: userMap['Nombre'],
                                        apellido: userMap['Apellido'],
                                        titulo: evento['Titulo'],
                                        descripcion: evento['Descripcion'],
                                        ubicacion: ubicacion,
                                        fecha: evento['Fecha'],
                                        tienePresupuesto: evento['TienePresupuesto'],
                                        presupuesto: evento['Presupuesto'],
                                        idUsuario: userMap['email'],
                                        docId: evento['docId'].toString(),
                                        direccionTexto: evento['DireccionTexto'],
                                        onChatPressed: () {},
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              evento['Titulo'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              evento['Descripcion'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 140,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          evento['TienePresupuesto'] == true 
                                              ? '${evento['Presupuesto']} €'
                                              : 'Sin presup.',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // CONTENIDO DE LA TAB DE CLASES

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
                        //CARGA TODAS LAS CLASES Y FILTRAMOS EN EL CLIENTE PARA MANEJAR MAYUSCULAS/MINUSCULAS
                        stream: clasPart.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting || !snapshot.hasData) {
                            return Center(
                                child: CircularProgressIndicator());
                          }

                          final allData = snapshot.data!;
                          // Filtrar en el cliente normalizando emails para manejar mayúsculas/minúsculas
                          final filteredDocs = allData.docs.where((doc) {
                            final docIdUsuario = doc['IdUsuario']?.toString().toLowerCase() ?? '';
                            return docIdUsuario == _userEmail?.toLowerCase();
                          }).toList();
                          
                          final data = filteredDocs;

                          return ListView.separated(
                            itemCount: data.length + 1, // +1 for header
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                            itemBuilder: (context, index) {
                              // First item is always the header
                              if (index == 0) {
                                final userMap = userData.data() as Map<String, dynamic>;
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
                                        builder: (context) => CartaClasPartEdit(
                                              foto: userMap['Foto'] ?? '',
                                              nombre: userMap['Nombre'],
                                              apellido: userMap['Apellido'],
                                              titulo: '',
                                              descripcion: 'Descripcion',
                                              horasDisp: 0,
                                              negociable: false,
                                              coste: 0,
                                              idUsuario: userMap['email'],
                                              id: 'id',
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }

                              // Other items are class documents
                              var clasPartDoc = data[index - 1];
                              final userMap = userData.data() as Map<String, dynamic>;
                              return InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CartaClasPart(
                                        foto: userMap['Foto'] ?? '',
                                        nombre: userMap['Nombre'],
                                        apellido: userMap['Apellido'],
                                        titulo: clasPartDoc['Titulo'],
                                        descripcion: clasPartDoc['Descripcion'],
                                        horasDisp: clasPartDoc['HorasDisp'],
                                        negociable: clasPartDoc['Negociable'],
                                        coste: clasPartDoc['Coste'],
                                        idUsuario: userMap['email'],
                                        id: clasPartDoc['id'].toString(),
                                        onChatPressed: () {},
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              clasPartDoc['Titulo'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              clasPartDoc['Descripcion'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 140,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${clasPartDoc['Coste']} €',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
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