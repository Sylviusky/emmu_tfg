import 'package:flutter/material.dart';
import 'CajonAppBar.dart';

class ChatPersonal extends StatelessWidget {
  final String imagenUsuario;
  final String titulo;
  final String descripcion;
  final VoidCallback onChatPressed;
  final int coste;
  final bool negociable;

  const ChatPersonal({
    super.key,
    required this.imagenUsuario,
    required this.titulo,
    required this.descripcion,
    required this.onChatPressed,
    required this.coste,
    required this.negociable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Clases particulares',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Cajon(),
      body: Card(
        margin: EdgeInsets.all(15.0),
        //color: Colors.redAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/default_user.jpg'),
                  radius: 50,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 23.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Presupuesto: $coste',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                descripcion,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: onChatPressed,
                child: Text('Chatear con el usuario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
