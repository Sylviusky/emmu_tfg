import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartaUsuario extends StatefulWidget {
  final String idUsuario;
  final VoidCallback? onContactPressed;

  const CartaUsuario({
    super.key,
    required this.idUsuario,
    this.onContactPressed,
  });

  @override
  State<CartaUsuario> createState() => _CartaUsuarioState();
}

class _CartaUsuarioState extends State<CartaUsuario> {
  // Usamos un Future para buscar al usuario en Firestore solo una vez.
  late Future<DocumentSnapshot?> _userFuture;

  ImageProvider _avatarImage(String foto) {
    final value = foto.trim();
    if (value.isEmpty) {
      return const AssetImage('assets/default_user.jpg');
    }
    if (value.startsWith('http')) {
      return NetworkImage(value);
    }
    if (value.startsWith('assets/')) {
      return AssetImage(value);
    }
    return const AssetImage('assets/default_user.jpg');
  }

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<DocumentSnapshot?> _fetchUser() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Usuario')
        .where('email', isEqualTo: widget.idUsuario)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null; // Devuelve null si no se encuentra el usuario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Perfil de Usuario', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar el perfil: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo encontrar al usuario.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final nombre = userData['Nombre']?.toString() ?? 'Nombre no disponible';
          final apellido = userData['Apellido']?.toString() ?? 'Apellido no disponible';
          final fotoUrl = userData['Foto']?.toString() ?? '';
          final telefono = userData['Telefono']?.toString() ?? 'No proporcionado';
          final soyMusico = userData['SoyMusico'] == true;
          final instrumentosData = <Map<String, String>>[];

          if (userData['Instrumentos'] is List) {
            final List instrumentos = userData['Instrumentos'];
            for (final item in instrumentos) {
              if (item is Map<String, dynamic>) {
                instrumentosData.add({
                  'instrumento': item['instrumento']?.toString() ?? '',
                  'nivel': item['nivel']?.toString() ?? 'beginner',
                });
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _avatarImage(fotoUrl),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      '$nombre $apellido',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
              _buildInfoRow(label: 'Nombre', value: nombre, icon: Icons.person),
              const SizedBox(height: 16.0),
              _buildInfoRow(
                  label: 'Apellidos',
                  value: apellido,
                  icon: Icons.person_outline),
              const SizedBox(height: 16.0),
              _buildInfoRow(
                  label: 'Teléfono', value: telefono, icon: Icons.phone),
              const SizedBox(height: 24.0),
              if (soyMusico && instrumentosData.isNotEmpty)
                ...List.generate(instrumentosData.length, (index) {
                  final instrumento = instrumentosData[index]['instrumento'] ?? '';
                  final nivel = instrumentosData[index]['nivel'] ?? 'beginner';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instrumento ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          _buildInfoRow(
                            label: 'Nombre del instrumento',
                            value: instrumento.isEmpty
                                ? 'No especificado'
                                : instrumento,
                            icon: Icons.music_note,
                          ),
                          const SizedBox(height: 12.0),
                          _buildInfoRow(
                            label: 'Nivel',
                            value: _mapNivelToText(nivel),
                            icon: Icons.star,
                          ),
                        ],
                      ),
                    ),
                  );
                })
              else if (soyMusico)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      soyMusico
                          ? 'Este usuario no ha añadido instrumentos.'
                          : 'Este usuario no es músico.',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              if (widget.onContactPressed != null) ...[
                const SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: widget.onContactPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  icon: const Icon(Icons.question_answer),
                  label: const Text(
                    'Ponte en contacto',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _mapNivelToText(String nivel) {
    switch (nivel) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      case 'self-taught':
        return 'Autodidacta';
      default:
        return nivel;
    }
  }
}