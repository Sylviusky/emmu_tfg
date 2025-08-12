import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'CajonAppBar.dart';

class CartaEvento extends StatefulWidget {
  final String idUsuario;
  final String titulo;
  final String descripcion;
  final GeoPoint ubicacion;
  final Timestamp fecha;
  final VoidCallback onChatPressed;
  final int presupuesto;
  final bool tienePresupuesto;
  final String nombre;
  final String apellido;
  final String foto;
  final String docId;

  const CartaEvento({
    super.key,
    required this.docId,
    required this.idUsuario,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha,
    required this.onChatPressed,
    required this.presupuesto,
    required this.tienePresupuesto,
    required this.nombre,
    required this.apellido,
    required this.foto,
  });

  @override
  _CartaEventoState createState() => _CartaEventoState();
}

class _CartaEventoState extends State<CartaEvento> {
  late String _userEmail;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  //¿Vale la pena eliminar esta comprobación? Ya se hace para cargar el listado de Eventos
  //tanto en Eventos_Page como en Mis anuncios.
  //¿Sustituir por un final bool editable que en Eventos_Page se pase como false y en
  //MisAnuncios_Page se pase como true? Los datos de usuario ya se le pasan al clicar...
  //↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? '';
      _isEditable = _userEmail == widget.idUsuario;
    });
  }

  Uri generateGoogleMapsUri(GeoPoint geoPoint) {
    final latitude = geoPoint.latitude;
    final longitude = geoPoint.longitude;
    return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  }

  Future<String> getAddressFromGeoPoint(GeoPoint geoPoint) async {
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
  }

  String comprobarPresupuesto(bool tienePresupuesto, int presupuesto) {
    return tienePresupuesto == 0 ? ' - €' : '$presupuesto€';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Evento',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Cajon(),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 30,
            width: MediaQuery.of(context).size.width - 30, // Ajusta el ancho aquí
            child: Card(
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
                            widget.titulo,
                            style: TextStyle(
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            comprobarPresupuesto(
                                widget.tienePresupuesto, widget.presupuesto),
                            style: TextStyle(
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 13),
                    child: Text(
                      '${widget.nombre}, ${widget.apellido}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: Text(
                      'Fecha: ${widget.fecha.toDate().day}/${widget.fecha.toDate().month}/${widget.fecha.toDate().year}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: FutureBuilder<String>(
                      future: getAddressFromGeoPoint(widget.ubicacion),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final address =
                              snapshot.data ?? 'Dirección no disponible';
                          final uri = generateGoogleMapsUri(widget.ubicacion);
                          return GestureDetector(
                            onTap: () async {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                throw 'Could not launch $uri';
                              }
                            },
                            child: Text(
                              'Ubicación: $address',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: Text(
                      widget.descripcion,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

      floatingActionButton: _isEditable
          ? Stack(
        children: [
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartaEventoEdit(
                      idUsuario: widget.idUsuario,
                      foto: widget.foto,
                      nombre: widget.nombre,
                      apellido: widget.apellido,
                      titulo: widget.titulo,
                      descripcion: widget.descripcion,
                      ubicacion: widget.ubicacion,
                      fecha: widget.fecha,
                      tienePresupuesto: widget.tienePresupuesto,
                      presupuesto: widget.presupuesto,
                      docId: widget.docId,
                    ),
                  ),
                );
              },
              label: Text('Editar...',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              icon: Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ],
      )
          : Stack(
        children: [
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: widget.onChatPressed,
              label: Text('Ponte en contacto',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              icon: Icon(
                Icons.question_answer,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

    );
  }
}

class CartaEventoEdit extends StatefulWidget {
  final String? docId;
  final String idUsuario;
  final String foto;
  final String nombre;
  final String apellido;
  final String titulo;
  final String descripcion;
  final GeoPoint ubicacion;
  final Timestamp fecha;
  final bool tienePresupuesto;
  final int presupuesto;

  const CartaEventoEdit({
    super.key,
    required this.docId,
    required this.idUsuario,
    required this.foto,
    required this.nombre,
    required this.apellido,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha,
    required this.tienePresupuesto,
    required this.presupuesto,
  });

  @override
  _CartaEventoEditState createState() => _CartaEventoEditState();
}

class _CartaEventoEditState extends State<CartaEventoEdit> {
  late DateTime _selectedDate;
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _fechaController;
  late TextEditingController _presupuestoController;
  bool _tienePresupuesto = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _descripcionController = TextEditingController(text: widget.descripcion);
    _ubicacionController =
        TextEditingController(text: widget.ubicacion.toString());
    _fechaController =
        TextEditingController(text: widget.fecha.toDate().toString());
    _presupuestoController =
        TextEditingController(text: widget.presupuesto.toString());
    _tienePresupuesto = widget.tienePresupuesto;
    _selectedDate = widget.fecha.toDate();
  }

  Future<void> _updateEvento() async {
    // Query the collection to find the document with the matching docId
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('docId', isEqualTo: widget.docId)
        .get();

    // Check if the document exists
    if (querySnapshot.docs.isNotEmpty) {
      // Get the document reference
      DocumentReference docRef = querySnapshot.docs.first.reference;

      // Update the fields of the found document
      await docRef.update({
        'Titulo': _tituloController.text,
        'Descripcion': _descripcionController.text,
        'Ubicacion': _ubicacionController.text,
        'Fecha': _fechaController.text,
        'TienePresupuesto': _tienePresupuesto,
        'Presupuesto': double.parse(_presupuestoController.text),
      });

      // Navigate back after updating
      Navigator.pop(context);
    } else {
      // Handle the case where the document is not found
      print('Document with docId ${widget.docId} not found');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:  _selectedDate, // Pre-selects the current _selectedDate
      firstDate: DateTime(2000), // Or a more relevant past date for your app
      lastDate: DateTime(2101),   // A reasonable future date
      //Optional: Theming if you want to customize colors
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked !=  _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update the state with the newly selected date
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,

      appBar: AppBar(
        backgroundColor: Colors.red,

        title: Text(
          'Editar Evento',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 30, // Ajusta el ancho aquí
          child: Card(
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
                    Expanded(
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _tituloController,
                            style: TextStyle(
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                                labelText: 'Título',
                                labelStyle: TextStyle(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${widget.nombre}, ${widget.apellido}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _tienePresupuesto,
                        onChanged: (bool? value) {
                          setState(() {
                            _tienePresupuesto = value ?? false;
                          });
                        },
                      ),
                      //const SizedBox(width: 8), // Space between checkbox and text
                      Flexible(child: const Text('Tiene Presupuesto')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextField(
                    controller: _presupuestoController,
                    decoration: InputDecoration(
                      labelText: 'Presupuesto (€)',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: _tienePresupuesto,
                  ),
                ),
              ),
            ],
          ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0), // Added more vertical padding
                  child: Column( // Use a column if you want a label above the date display
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fecha del Evento:",
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                      ),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () {
                          _selectDate(context); // Call the method to show the date picker
                        },
                        child: InputDecorator( // Provides a nice border similar to a TextField
                          decoration: InputDecoration(
                            // labelText: 'Fecha', // Alternative way to add a label
                            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes icon to the end
                            children: <Widget>[
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate), // Using intl package for formatting
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor, // Use your theme's primary color (e.g., Colors.red)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: TextField(
                    controller: _ubicacionController,
                    decoration: InputDecoration(labelText: 'Ubicación'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: TextField(
                    controller: _descripcionController,
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _updateEvento,
                    child: Text('Guardar', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
