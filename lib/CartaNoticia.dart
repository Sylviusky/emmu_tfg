import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CajonAppBar.dart';

class CartaNoticia extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final Timestamp fecha;
  final String enlace;
  final String organizacion;
  final String pais;
  final String region;
  final int docId;

  const CartaNoticia({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.enlace,
    required this.organizacion,
    required this.pais,
    required this.region,
    required this.docId,
  });

  @override
  _CartaNoticiaState createState() => _CartaNoticiaState();
}

class _CartaNoticiaState extends State<CartaNoticia> {
  late String _userEmail;
  //bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? '';
      //_isEditable = _userEmail == widget.idUsuario;
    });
  }

  /*   Uri generateGoogleMapsUri(GeoPoint geoPoint) {
			final latitude = geoPoint.latitude;
			final longitude = geoPoint.longitude;
			return Uri.parse(
					'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
		} */

  /*   Future<String> getAddressFromGeoPoint(GeoPoint geoPoint) async {
			final apiKey = 'AIzaSyDTb2UY1JArfhzUKOGEefvDlc-u6Xocqhc';
			final url =
					'https://maps.googleapis.com/maps/api/geocode/json?latlng=${geoPoint.latitude},${geoPoint.longitude}&key=$apiKey';

			final response = await http.get(Uri.parse(url));

			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				if (data['status'] == 'OK') {
					return data['results'][0]['formatted_address'];
				} else {
					throw Exception('Error al obtener la dirección: ${data['status']}');
				}
			} else {
				throw Exception(
						'Error al conectar con la API de Google: ${response.statusCode}');
			}
		} */
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.parse(widget.enlace);
    return Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Noticias',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Cajon(),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width:
                MediaQuery.of(context).size.width - 30, // Ajusta el ancho aquí
            child: Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 8.0),
                      child: Text(
                        widget.titulo,
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        '${widget.fecha.toDate().day}/${widget.fecha.toDate().month}/${widget.fecha.toDate().year}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: InkWell(
                        onTap: () => _launchURL(widget.enlace.startsWith('http')
                            ? widget.enlace
                            : 'https://${widget.enlace}'),
                        child: Text(
                          'Enlace: ${widget.enlace}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        widget.organizacion,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        '${widget.pais} , ${widget.region}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 8.0),
                      child: Text(
                        widget.descripcion,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ]),
            ),
          ),
        ),

    );
  }
}
