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
      final email = prefs.getString('userEmail');
      _userEmail = email != null ? email.toLowerCase() : null;
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
                //CARGA TODAS LAS CLASES Y FILTRAMOS EN EL CLIENTE PARA MANEJAR MAYUSCULAS/MINUSCULAS
                stream: clasPart.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final allData = snapshot.requireData;
                  // Filtrar en el cliente normalizando emails para manejar mayúsculas/minúsculas
                  // Mostrar todas las clases EXCEPTO las del usuario logueado
                  final List<QueryDocumentSnapshot> filteredDocs;
                  if (_userEmail == null || _userEmail!.isEmpty) {
                    // Si no hay usuario logueado, mostrar todas las clases
                    filteredDocs = allData.docs.toList();
                  } else {
                    final userEmailLower = _userEmail!.toLowerCase();
                    filteredDocs = allData.docs.where((doc) {
                      final docIdUsuario = doc['IdUsuario']?.toString().toLowerCase() ?? '';
                      // Si no hay IdUsuario o está vacío, no mostrar (documento inválido)
                      if (docIdUsuario.isEmpty) return false;
                      // Si es el usuario logueado, no mostrar (excluir del listado)
                      if (docIdUsuario == userEmailLower) return false;
                      // Mostrar todos los demás
                      return true;
                    }).toList();
                  }

                  return ListView.separated(
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                    itemBuilder: (context, index) {
                      final clasPart = filteredDocs[index];
                      final idUsuario = clasPart['IdUsuario'].toString().toLowerCase();

                      return FutureBuilder<QuerySnapshot>(
                        // Cargar todos los usuarios y filtrar en el cliente para manejar mayúsculas/minúsculas
                        future: FirebaseFirestore.instance
                            .collection('Usuario')
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasError) {
                            // Si hay error, mostrar clase con datos por defecto
                            return _buildClaseItem(clasPart, null);
                          }

                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          // Buscar usuario normalizando emails
                          QueryDocumentSnapshot? userData;
                          if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
                            final allUsers = userSnapshot.data!.docs;
                            try {
                              userData = allUsers.firstWhere(
                                (user) {
                                  final userEmail = user['email']?.toString().toLowerCase() ?? '';
                                  return userEmail == idUsuario;
                                },
                              );
                            } catch (e) {
                              // Usuario no encontrado, userData quedará null
                              userData = null;
                            }
                          }
                          
                          // Si no encontramos usuario, userData será null
                          // Pero aún así mostraremos la clase con datos por defecto
                          return _buildClaseItem(clasPart, userData);
                        },
                      );
                    },
                  );
                },
              ),
    );
  }

  Widget _buildClaseItem(QueryDocumentSnapshot clasPart, QueryDocumentSnapshot? userData) {
    final idUsuario = clasPart['IdUsuario'].toString().toLowerCase();
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartaClasPart(
              foto: userData?['Foto'] ?? 'assets/default_user.jpg',
              titulo: clasPart['Titulo'],
              descripcion: clasPart['Descripcion'],
              coste: clasPart['Coste'],
              negociable: clasPart['Negociable'],
              nombre: userData?['Nombre'] ?? 'Usuario',
              apellido: userData?['Apellido'] ?? '',
              horasDisp: clasPart['HorasDisp'],
              idUsuario: userData?['email'] ?? idUsuario,
              id: clasPart['id'].toString(),
              onChatPressed: () {},
            ),
          ),
        );
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
                    clasPart['Titulo'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    clasPart['Descripcion'],
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
                '${clasPart['Coste']} €',
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
  }
}
