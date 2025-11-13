import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CajonAppBar.dart';

class CartaClasPart extends StatefulWidget {
  final String idUsuario;
  final String titulo;
  final String descripcion;
  final VoidCallback onChatPressed;
  final int coste;
  final bool negociable;
  final String nombre;
  final String apellido;
  final int horasDisp;

  final String foto;
  final String id;

  const CartaClasPart({
    super.key,
    required this.foto,
    required this.titulo,
    required this.descripcion,
    required this.onChatPressed,
    required this.coste,
    required this.negociable,
    required this.nombre,
    required this.apellido,
    required this.horasDisp,
    required this.idUsuario,
    //required this.editable,
    required this.id,

  });

  @override
  _CartaClasPartState createState() => _CartaClasPartState();
}

class _CartaClasPartState extends State<CartaClasPart> {
  late String _userEmail;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? '';
      _isEditable = _userEmail == widget.idUsuario;
    });
  }
  String comprobarNegociable(bool negociable) {
    return negociable != true ?/*??*/ 'Precio negociable': '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Clases particulares',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Cajon(),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 30, // Ajusta el ancho aquí
            child: Card(
              //margin: EdgeInsets.all(15.0),
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
                            widget.titulo,
                            style: TextStyle(
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Presupuesto: ${widget.coste}',
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
                      '${widget.nombre}, ${widget.apellido}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: Text(
                      'Disponibilidad: ${widget.horasDisp}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 8.0, vertical: 10.0),
                  //   child: FutureBuilder<String>(
                  //     future: getAddressFromGeoPoint(widget.ubicacion),
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState ==
                  //           ConnectionState.waiting) {
                  //         return CircularProgressIndicator();
                  //       } else if (snapshot.hasError) {
                  //         return Text('Error: ${snapshot.error}');
                  //       } else {
                  //         final address =
                  //             snapshot.data ?? 'Dirección no disponible';
                  //         final uri = generateGoogleMapsUri(widget.ubicacion);
                  //         return GestureDetector(
                  //           onTap: () async {
                  //             if (await canLaunchUrl(uri)) {
                  //               await launchUrl(uri);
                  //             } else {
                  //               throw 'Could not launch $uri';
                  //             }
                  //           },
                  //           child: Text(
                  //             'Ubicación: $address',
                  //             style: TextStyle(
                  //               fontSize: 16.0,
                  //               color: Colors.blue,
                  //               decoration: TextDecoration.underline,
                  //             ),
                  //           ),
                  //         );
                  //       }
                  //     },
                  //   ),
                  // ),
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
                      builder: (context) => CartaClasPartEdit(
                        idUsuario: widget.idUsuario,
                        foto: widget.foto,
                        nombre: widget.nombre,
                        apellido: widget.apellido,
                        titulo: widget.titulo,
                        descripcion: widget.descripcion,
                        coste: widget.coste,
                        negociable: widget.negociable,
                        horasDisp: widget.horasDisp,

                        id: widget.id,
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


class CartaClasPartEdit extends StatefulWidget {
  final String idUsuario;
  final String titulo;
  final String descripcion;
  final int coste;
  final bool negociable;
  final String nombre;
  final String apellido;
  final int horasDisp;

  final String foto;
  final String id;




  const CartaClasPartEdit({
    super.key,
    required this.foto,
    required this.titulo,
    required this.descripcion,
    required this.coste,
    required this.negociable,
    required this.nombre,
    required this.apellido,
    required this.horasDisp,
    required this.idUsuario,
    required this.id,

  });

  @override
  _CartaClasPartEditState createState() => _CartaClasPartEditState();
}

class _CartaClasPartEditState extends State<CartaClasPartEdit> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _horasDispController;
  late TextEditingController _costeController;
  bool _negociable = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _descripcionController = TextEditingController(text: widget.descripcion);
    _horasDispController =
        TextEditingController(text: widget.horasDisp.toString());
    _costeController =
        TextEditingController(text: widget.coste.toString());
    _negociable = widget.negociable;
  }

  Future<void> _updateClase() async {
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

      // Parse horas disponibles
      int horasDisp;
      try {
        horasDisp = int.parse(_horasDispController.text.trim());
        if (horasDisp < 0) {
          throw Exception('Las horas disponibles no pueden ser negativas');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Las horas disponibles deben ser un número válido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Parse coste
      int coste;
      try {
        coste = int.parse(_costeController.text.trim());
        if (coste < 0) {
          throw Exception('El coste no puede ser negativo');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El coste debe ser un número válido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if this is a new document (placeholder id)
      final isNewDocument = widget.id == 'id' || widget.id.isEmpty;
      
      if (isNewDocument) {
        // Use Firestore's auto-generated document ID (random and guaranteed unique)
        // This is the most efficient approach - no counter needed, no collisions possible
        final docRef = FirebaseFirestore.instance.collection('ClasPart').doc();
        final autoGeneratedId = docRef.id;
        
        // Create new document with auto-generated ID
        // Store the auto-generated ID as id field for consistency with existing code
        await docRef.set({
          'id': autoGeneratedId, // Store the auto-generated ID for reference
          'Titulo': _tituloController.text.trim(),
          'Descripcion': _descripcionController.text.trim(),
          'HorasDisp': horasDisp,
          'Negociable': _negociable,
          'Coste': coste,
          'IdUsuario': widget.idUsuario,
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clase creada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate back after creating
          Navigator.pop(context);
        }
      } else {
        // Existing document - update it
        // Query the collection to find the document with the matching id
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('ClasPart')
            .where('id', isEqualTo: widget.id)
            .get();

        // Check if the document exists
        if (querySnapshot.docs.isNotEmpty) {
          // Get the document reference
          DocumentReference docRef = querySnapshot.docs.first.reference;

          // Update the fields of the found document
          await docRef.update({
            'Titulo': _tituloController.text.trim(),
            'Descripcion': _descripcionController.text.trim(),
            'HorasDisp': horasDisp,
            'Negociable': _negociable,
            'Coste': coste,
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clase actualizada exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate back after updating
            Navigator.pop(context);
          }
        } else {
          // Handle the case where the document is not found
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: No se encontró el documento con id ${widget.id}'),
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
            content: Text('Error al actualizar la clase: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error updating clase: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Clases particulares',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        //drawer: Cajon(),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 30, // Ajusta el ancho aquí
            child: Card(
              //margin: EdgeInsets.all(15.0),
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
                      Expanded(
                        child:
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
                            TextField(
                              controller: _tituloController,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(labelText: 'Título'),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: TextField(
                      controller: _horasDispController,
                      decoration: InputDecoration(labelText: 'Horas disponibles'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _negociable,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _negociable = value ?? false;
                                  });
                                },
                              ),
                              Flexible(child: const Text('Negociable')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          child: TextField(
                            controller: _costeController,
                            decoration: InputDecoration(
                              labelText: 'Coste (€)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
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
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _updateClase,
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