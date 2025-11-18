import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'carta_usuario.dart';
import 'chat_indiv.dart';
import 'location_picker.dart';

import 'cajon_app_bar.dart';

class CartaEvento extends StatefulWidget {
  final String idUsuario;
  final String titulo;
  final String descripcion;
  final GeoPoint? ubicacion;
  final Timestamp fecha;
  final VoidCallback onChatPressed;
  final int presupuesto;
  final bool tienePresupuesto;
  final String nombre;
  final String apellido;
  final String foto;
  final String docId;
  final String? direccionTexto;
  const CartaEvento({
    super.key,
    required this.docId,
    required this.idUsuario,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.onChatPressed,
    required this.presupuesto,
    required this.tienePresupuesto,
    required this.nombre,
    required this.apellido,
    required this.foto,
    this.ubicacion,
    this.direccionTexto,
  });

  @override
  _CartaEventoState createState() => _CartaEventoState();
}

class _CartaEventoState extends State<CartaEvento> {
  String _userEmail = '';
  String _titulo = '';
  String _descripcion = '';
  GeoPoint? _ubicacion;
  Timestamp? _fecha;
  int _presupuesto = 0;
  bool _tienePresupuesto = false;
  String? _direccionTexto;
  String _addressText = '';
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    try {
      _titulo = widget.titulo;
      _descripcion = widget.descripcion;
      _ubicacion = widget.ubicacion;
      _fecha = widget.fecha;
      _presupuesto = widget.presupuesto;
      _tienePresupuesto = widget.tienePresupuesto;
      _direccionTexto = widget.direccionTexto;
      if (_direccionTexto?.trim().isNotEmpty == true) {
        _addressText = _direccionTexto!.trim();
      } else if (_ubicacion != null) {
        _addressText = _formatCoordinates(_ubicacion!);
      } else {
        _addressText = 'Ubicación no disponible';
      }
    } catch (e) {
      print('Error inicializando datos en CartaEvento: $e');
      // Establecer valores por defecto en caso de error
      _titulo = 'Error al cargar';
      _descripcion = 'Error al cargar los datos del evento';
      _addressText = 'Ubicación no disponible';
    }
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
      _userEmail = (prefs.getString('userEmail') ?? '').toLowerCase();
      _isEditable = _userEmail == widget.idUsuario.toLowerCase();
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

  Widget _buildProfileAvatar() {
    final foto = widget.foto.trim();
    if (foto.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.grey);
    }

    if (foto.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          foto,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 50, color: Colors.grey);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator(color: Colors.red);
          },
        ),
      );
    }

    final assetPath = foto.contains('default_user')
        ? 'assets/default_user.jpg'
        : (foto.startsWith('assets/') ? foto : '');

    if (assetPath.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          assetPath,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Icon(Icons.person, size: 50, color: Colors.grey);
  }

  Future<void> _navigateToEdit() async {
    if (_ubicacion == null || _fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Datos del evento incompletos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
          ubicacion: _ubicacion!,
          fecha: _fecha!,
          tienePresupuesto: _tienePresupuesto,
          presupuesto: _presupuesto,
          docId: widget.docId,
          direccionTexto: _direccionTexto,
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
          _titulo = data['Titulo'] ?? '';
          _descripcion = data['Descripcion'] ?? '';
          _ubicacion = data['Ubicacion'] as GeoPoint?;
          _fecha = data['Fecha'] as Timestamp?;
          _presupuesto = data['Presupuesto'] ?? 0;
          _tienePresupuesto = data['TienePresupuesto'] ?? false;
          _direccionTexto = (data['DireccionTexto'] as String?)?.trim();
          if (_ubicacion != null) {
            _addressText = _direccionTexto?.isNotEmpty == true
                ? _direccionTexto!
                : _formatCoordinates(_ubicacion!);
          }
        });
      }
    } catch (e) {
      print("Error al recargar los datos del evento: $e");
    }
  }

  String _formatCoordinates(GeoPoint geoPoint) {
    return '${geoPoint.latitude.toStringAsFixed(6)}, ${geoPoint.longitude.toStringAsFixed(6)}';
  }
  Uri generateGoogleMapsUri(GeoPoint geoPoint) {
    final latitude = geoPoint.latitude;
    final longitude = geoPoint.longitude;
    return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  }

  String comprobarPresupuesto(bool tienePresupuesto, int presupuesto) {
    return tienePresupuesto ? '$presupuesto €' : ' - €';
  }

  @override
  Widget build(BuildContext context) {
    // Validar que los datos críticos estén disponibles
    if (_fecha == null) {
      return Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Evento',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const Cajon(),
        body: const Center(
          child: Text(
            'Error: Datos del evento incompletos',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Evento',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Cajon(),
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
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: _buildProfileAvatar(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titulo,
                            style: const TextStyle(
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            comprobarPresupuesto(_tienePresupuesto, _presupuesto),
                            style: const TextStyle(
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
                  onTap: _isEditable ? null : _navigateToUserProfile,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 13),
                    child: Text(
                      '${widget.nombre}, ${widget.apellido}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha!.toDate())}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: GestureDetector(
                    onTap: _ubicacion != null ? () async {
                      final uri = generateGoogleMapsUri(_ubicacion!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $uri';
                      }
                    } : null,
                    child: Text(
                      'Ubicación: $_addressText',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: _ubicacion != null ? Colors.blue : Colors.black,
                        decoration: _ubicacion != null 
                            ? TextDecoration.underline 
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Text(
                    _descripcion,
                    style: const TextStyle(fontSize: 16.0),
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
  final String? direccionTexto;

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
    this.direccionTexto,
  });

  @override
  _CartaEventoEditState createState() => _CartaEventoEditState();
}

class _CartaEventoEditState extends State<CartaEventoEdit> {
  late final bool _isNewDocument;
  late DateTime _selectedDate;
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _presupuestoController;
  bool _tienePresupuesto = false;
  SelectedLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _isNewDocument = widget.docId == 'docID' || widget.docId.isEmpty;
    _tituloController = TextEditingController(text: widget.titulo);
    _descripcionController = TextEditingController(text: widget.descripcion);
    _ubicacionController = TextEditingController(
      text: _isNewDocument
          ? ''
          : widget.direccionTexto ??
              '${widget.ubicacion.latitude}, ${widget.ubicacion.longitude}',
    );
    _presupuestoController =
        TextEditingController(text: widget.presupuesto.toString());
    _tienePresupuesto = widget.tienePresupuesto;
    _selectedDate = widget.fecha.toDate();
    if (_isNewDocument) {
      _selectedLocation = null;
    } else {
      _selectedLocation = SelectedLocation(
        latitude: widget.ubicacion.latitude,
        longitude: widget.ubicacion.longitude,
        description: widget.direccionTexto ??
            '${widget.ubicacion.latitude.toStringAsFixed(6)}, ${widget.ubicacion.longitude.toStringAsFixed(6)}',
      );
      _ubicacionController.text = _selectedLocation!.description;
    }
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

      GeoPoint? ubicacion;
      String? direccionTexto;

      if (_selectedLocation != null) {
        ubicacion = GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );
        direccionTexto = _selectedLocation!.description.trim();
      } else if (!_isNewDocument) {
        ubicacion = widget.ubicacion;
        direccionTexto = (widget.direccionTexto ?? '').trim().isNotEmpty
            ? widget.direccionTexto!.trim()
            : _ubicacionController.text.trim();
      }

      if (ubicacion == null || direccionTexto == null || direccionTexto.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona la ubicación del evento'),
            backgroundColor: Colors.red,
          ),
        );
        return;
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
          'IdUsuario': widget.idUsuario.toLowerCase(),
          'DireccionTexto': direccionTexto,
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
            'DireccionTexto': direccionTexto,
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
                  child: LocationAutocompleteField(
                    controller: _ubicacionController,
                    country: 'es',
                    helperText: _isNewDocument
                        ? 'Añade la ubicación del evento antes de guardar'
                        : 'Modifica la ubicación si ha cambiado',
                    onLocationSelected: (location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: TextField(
                    controller: _descripcionController,
                    style: const TextStyle(
                      fontSize: 17.0,
                    ),
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3,
                    maxLines: 6,
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