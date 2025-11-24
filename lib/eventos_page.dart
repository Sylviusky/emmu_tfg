import 'package:cloud_firestore/cloud_firestore.dart';
import 'cajon_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'carta_evento.dart';
import 'utils/geo_point_parser.dart';

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
    if (!mounted) return;
    setState(() {
      _userEmail = prefs.getString('userEmail')?.toLowerCase();
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
        //CARGA TODOS LOS EVENTOS Y FILTRAMOS EN EL CLIENTE PARA MANEJAR MAYUSCULAS/MINUSCULAS
        stream: eventos.snapshots(),
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
          // Mostrar todos los eventos EXCEPTO los del usuario logueado
          final List<QueryDocumentSnapshot> filteredDocs;
          if (_userEmail == null || _userEmail!.isEmpty) {
            // Si no hay usuario logueado, mostrar todos los eventos
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
              final evento = filteredDocs[index];
              final idUsuario = evento['IdUsuario'].toString().toLowerCase();

              // Asumiendo que tienes un campo userId en ClasPart

              // Verificar que idUsuario no sea nulo o vacío
              //REALMENTE NO ES NECESARIO PORQUE CADA EVENTO SOLO PUEDE CREARSE TRAS REGISTRARSE/INICIAR SESIÓN
              //POR LO QUE TENDRÍA SIEMPRE UN IDUSUARIO
              //if (idUsuario.isEmpty) {
              //  return ListTile();
              //}

              return FutureBuilder<QuerySnapshot>(
                // Cargar todos los usuarios y filtrar en el cliente para manejar mayúsculas/minúsculas
                future: FirebaseFirestore.instance
                    .collection('Usuario')
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    // Si hay error, mostrar evento con datos por defecto
                    return _buildEventItem(evento, null);
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
                  // Pero aún así mostraremos el evento con datos por defecto
                  return _buildEventItem(evento, userData);

                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventItem(QueryDocumentSnapshot evento, QueryDocumentSnapshot? userData) {
    final idUsuario = evento['IdUsuario'].toString().toLowerCase();
    
    return InkWell(
      onTap: () {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartaEvento(
              foto: userData?['Foto'] ?? '',
              nombre: userData?['Nombre'] ?? 'Usuario',
              apellido: userData?['Apellido'] ?? '',
              titulo: evento['Titulo'],
              descripcion: evento['Descripcion'],
              ubicacion: ubicacion,
              fecha: evento['Fecha'],
              tienePresupuesto: evento['TienePresupuesto'],
              presupuesto: evento['Presupuesto'],
              idUsuario: userData?['email'] ?? idUsuario,
              docId: evento['docId'].toString(),
              direccionTexto: evento['DireccionTexto'],
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
  }
}