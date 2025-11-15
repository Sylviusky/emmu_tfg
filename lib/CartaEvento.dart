import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'CartaUsuario.dart';
import 'Chat_Indiv.dart';

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
  late String _titulo;
  late String _descripcion;
  late GeoPoint _ubicacion;
  late Timestamp _fecha;
  late int _presupuesto;
  late bool _tienePresupuesto;

  late Future<String> _addressFuture;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _titulo = widget.titulo;
    _descripcion = widget.descripcion;
    _ubicacion = widget.ubicacion;
    _fecha = widget.fecha;
    _presupuesto = widget.presupuesto;
    _tienePresupuesto = widget.tienePresupuesto;
    _loadUserEmail();
    _addressFuture = getAddressFromGeoPoint(_ubicacion);
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

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartaUsuario(
          idUsuario: widget.idUsuario,
          onContactPressed: _openChat,
        ),
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPersonal(
          otherUserName: '${widget.nombre} ${widget.apellido}',
        ),
      ),
    );
    widget.onChatPressed();
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartaEventoEdit(
          idUsuario: widget.idUsuario,
          foto: widget.foto,
          nombre: widget.nombre,
          apellido: widget.apellido,
          // Pasamos los datos actuales (de las variables de estado) a la pantalla de edición
          titulo: _titulo,
          descripcion: _descripcion,
          ubicacion: _ubicacion,
          fecha: _fecha,
          tienePresupuesto: _tienePresupuesto,
          presupuesto: _presupuesto,
          docId: widget.docId,
        ),
      ),
    );

    // Si la pantalla de edición devolvió 'true', recargamos los datos.
    if (result == true && mounted) {
      _reloadData();
    }
  }

  // --- CAMBIO 4: Nuevo método para recargar los datos desde Firestore ---
  Future<void> _reloadData() async {
    try {
      DocumentSnapshot updatedDoc = await FirebaseFirestore.instance
          .collection('Evento')
          .doc(widget.docId)
          .get();

      if (updatedDoc.exists) {
        final data = updatedDoc.data() as Map<String, dynamic>;

        // Actualizamos las variables de estado con los nuevos datos,
        // lo que redibujará la UI automáticamente.
        setState(() {
          _titulo = data['Titulo'];
          _descripcion = data['Descripcion'];
          _ubicacion = data['Ubicacion'];
          _fecha = data['Fecha'];
          _presupuesto = data['Presupuesto'];
          _tienePresupuesto = data['TienePresupuesto'];
          // Refrescamos la dirección si la ubicación cambió
          _addressFuture = getAddressFromGeoPoint(_ubicacion);
        });
      }
    } catch (e) {
      print("Error al recargar los datos del evento: $e");
    }
  }
  Uri generateGoogleMapsUri(GeoPoint geoPoint) {
    final latitude = geoPoint.latitude;
    final longitude = geoPoint.longitude;
    return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  }

  Future<String> getAddressFromGeoPoint(GeoPoint geoPoint) async {
    final callable = FirebaseFunctions.instance.httpsCallable('reverseGeocode');
    final response = await callable
        .call({'lat': geoPoint.latitude, 'lng': geoPoint.longitude});
    final data = response.data as Map;
    final results = data['results'] as List<dynamic>?
        ?? const <dynamic>[];
    if (results.isEmpty) return 'Dirección no disponible';
    return results.first['formatted_address'] as String? ?? 'Dirección no disponible';
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
          width: MediaQuery.of(context).size.width - 30,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
            children: [
            GestureDetector(
            onTap: _isEditable ? null : _navigateToUserProfile,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/default_user.jpg'),
                radius: 50,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titulo,
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    comprobarPresupuesto(_tienePresupuesto, _presupuesto),
                    style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
          GestureDetector(
            onTap: _isEditable ? null : _navigateToUserProfile, // Solo se activa si no es tu anuncio
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 13),
              child: Text(
                '${widget.nombre}, ${widget.apellido}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 10.0),
              child: Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha.toDate())}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 10.0),
              child: FutureBuilder<String>(
                future: _addressFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final address =
                        snapshot.data ?? 'Dirección no disponible';
                    final uri = generateGoogleMapsUri(_ubicacion);
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
                _descripcion,
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
    onPressed: _navigateToEdit, // --- CAMBIO 6: Llamar al nuevo método ---
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
    onPressed: _openChat,
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
  final String docId;
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
    // Format ubicacion as "latitude, longitude" for easier editing
    _ubicacionController = TextEditingController(
        text: '${widget.ubicacion.latitude}, ${widget.ubicacion.longitude}');
    _fechaController =
        TextEditingController(text: widget.fecha.toDate().toString());
    _presupuestoController =
        TextEditingController(text: widget.presupuesto.toString());
    _tienePresupuesto = widget.tienePresupuesto;
    _selectedDate = widget.fecha.toDate();
  }

  // Helper method to parse GeoPoint from string input
  GeoPoint? _parseGeoPointFromString(String input) {
    try {
      // Try to parse format like "GeoPoint(latitude, longitude)" or "lat, lng"
      final cleanInput = input.trim();

      // Check if it's already in GeoPoint string format
      if (cleanInput.startsWith('GeoPoint(')) {
        final content = cleanInput.substring(9, cleanInput.length - 1);
        final parts = content.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lng = double.parse(parts[1].trim());
          return GeoPoint(lat, lng);
        }
      } else {
        // Try to parse as "lat, lng" format
        final parts = cleanInput.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lng = double.parse(parts[1].trim());
          return GeoPoint(lat, lng);
        }
      }
    } catch (e) {
      print('Error parsing GeoPoint: $e');
    }
    return null;
  }

  Future<void> _updateEvento() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardando cambios...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Validate input
      if (_tituloController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El título no puede estar vacío'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_descripcionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La descripción no puede estar vacía'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Parse presupuesto
      int presupuesto = 0;
      if (_tienePresupuesto) {
        try {
          presupuesto = int.parse(_presupuestoController.text.trim());
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El presupuesto debe ser un número válido'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Parse ubicacion - try to parse from string, otherwise keep original
      GeoPoint ubicacion = widget.ubicacion;
      final parsedUbicacion = _parseGeoPointFromString(_ubicacionController.text.trim());
      if (parsedUbicacion != null) {
        ubicacion = parsedUbicacion;
      }

      // Convert selected date to Timestamp
      final fechaTimestamp = Timestamp.fromDate(_selectedDate);

      // Check if this is a new document (placeholder docId)
      final isNewDocument = widget.docId == 'docID' || widget.docId.isEmpty;

      if (isNewDocument) {
        // Use Firestore's auto-generated document ID (random and guaranteed unique)
        // This is the most efficient approach - no counter needed, no collisions possible
        final docRef = FirebaseFirestore.instance.collection('Evento').doc();
        final autoGeneratedId = docRef.id;

        // Create new document with auto-generated ID
        // Store the auto-generated ID as docId field for consistency with existing code
        await docRef.set({
          'docId': autoGeneratedId, // Store the auto-generated ID for reference
          'Titulo': _tituloController.text.trim(),
          'Descripcion': _descripcionController.text.trim(),
          'Ubicacion': ubicacion,
          'Fecha': fechaTimestamp,
          'TienePresupuesto': _tienePresupuesto,
          'Presupuesto': presupuesto,
          'IdUsuario': widget.idUsuario,
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento creado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back after creating
          Navigator.pop(context, true);
        }
      } else {
        // Existing document - update it
        // Query the collection to find the document with the matching docId
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Evento')
            .where('docId', isEqualTo: widget.docId)
            .get();

        // Check if the document exists
        if (querySnapshot.docs.isNotEmpty) {
          // Get the document reference
          DocumentReference docRef = querySnapshot.docs.first.reference;

          // Update the fields of the found document
          await docRef.update({
            'Titulo': _tituloController.text.trim(),
            'Descripcion': _descripcionController.text.trim(),
            'Ubicacion': ubicacion,
            'Fecha': fechaTimestamp,
            'TienePresupuesto': _tienePresupuesto,
            'Presupuesto': presupuesto,
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Evento actualizado exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate back after updating
            Navigator.pop(context, true);
          }
        } else {
          // Handle the case where the document is not found
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: No se encontró el documento con docId ${widget.docId}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el evento: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error updating evento: $e');
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.red,

        title: Text(
          'Editar Evento',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                    decoration: InputDecoration(
                      labelText: 'Ubicación (Latitud, Longitud)',
                      hintText: 'Ejemplo: 39.494909, -0.684287',
                      helperText: 'Formato: latitud, longitud',
                    ),
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