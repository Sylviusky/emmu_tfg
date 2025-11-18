import 'package:flutter/material.dart';
import 'chats_page.dart';
import 'clases_page.dart';
import 'config_page.dart';
import 'eventos_page.dart';
import 'mis_anuncios_page.dart';
import 'noticias_page.dart';

class Cajon extends StatefulWidget {
  const Cajon({super.key});

  @override
  _CajonState createState() => _CajonState();
}

class _CajonState extends State<Cajon> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              //leading: const Icon(Icons.business_sharp),
              leading: const Icon(Icons.music_note),
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
            leading: const Icon(Icons.message),
            iconColor: Colors.white,
            title: const Text("Mensajes"),
            textColor: Colors.white,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Chats()));
            },
          ),
          ListTile(
              leading: const Icon(Icons.vertical_split),
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
              leading: const Icon(Icons.account_circle),
              iconColor: Colors.white,
              title: const Text("Mi cuenta"),
              textColor: Colors.white,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Configuracion()));
              }),
        ],
      ),
    );
  }
}
