import 'carta_usuario.dart';
import 'chat_indiv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cajon_app_bar.dart';

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
    required this.idUsuario,
    required this.titulo,
    required this.descripcion,
    required this.onChatPressed,
    required this.coste,
    required this.negociable,
    required this.nombre,
    required this.apellido,
    required this.horasDisp,
    //required this.editable,
    required this.id,

  });

  @override
  _CartaClasPartState createState() => _CartaClasPartState();
}

class _CartaClasPartState extends State<CartaClasPart> {
  late String _userEmail;
  late String _titulo;
  late String _descripcion;
  late int _horasDisp;
  late bool _negociable;
  late int _coste;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _titulo = widget.titulo;
    _descripcion = widget.descripcion;
    _horasDisp = widget.horasDisp;
    _negociable = widget.negociable;
    _coste = widget.coste;
    _loadUserEmail();
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

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = (prefs.getString('userEmail') ?? '').toLowerCase();
      _isEditable = _userEmail == widget.idUsuario.toLowerCase();
    });
  }

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

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartaClasPartEdit(
          // Pasamos los datos actuales a la pantalla de edición
          id: widget.id,
          idUsuario: widget.idUsuario,
          titulo: _titulo,
          descripcion: _descripcion,
          horasDisp: _horasDisp,
          negociable: _negociable,
          coste: _coste,
          nombre: widget.nombre,
          apellido: widget.apellido,
          foto: widget.foto,
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
          .collection('ClasPart')
          .doc(widget.id)
          .get();

      if (updatedDoc.exists) {
        final data = updatedDoc.data() as Map<String, dynamic>;

        // Actualizamos las variables de estado, lo que redibujará la UI.
        setState(() {
          _titulo = data['Titulo'];
          _descripcion = data['Descripcion'];
          _horasDisp = data['HorasDisp'];
          _negociable = data['Negociable'];
          _coste = data['Coste'];
        });
      }
    } catch (e) {
      print("Error al recargar los datos de la clase: $e");
    }
  }

  String comprobarCoste(int coste) {
    return '$coste €/h';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 30,
          width: MediaQuery.of(context).size.width - 30,
          child: Card(
            //margin: EdgeInsets.all(15.0),
            //color: Colors.redAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _isEditable ? null : _navigateToUserProfile, // Solo se activa si no es tu anuncio
                      child: CircleAvatar(
                        backgroundImage: _avatarImage(widget.foto),
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
                            'Presupuesto: ${widget.coste}',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),),
                  ],
                ),
                GestureDetector(
                  onTap: _isEditable ? null : _navigateToUserProfile, // Solo se activa si no es tu anuncio
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 13),
                    child: Text(
                      '${widget.nombre}, ${widget.apellido}',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Text(
                    'Disponibilidad: $_horasDisp',
                    style: TextStyle(fontSize: 16.0),
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
              label: Text('Editar...', style: TextStyle(color: Colors.white, fontSize: 20)),
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

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _horasDispController;
  late TextEditingController _costeController;
  late bool _negociable;
  late final bool _isNewDocument;

  @override
  void initState() {
    super.initState();
    _isNewDocument = widget.id == 'id' || widget.id.isEmpty;
    _tituloController = TextEditingController(text: widget.titulo);
    _descripcionController = TextEditingController(text: widget.descripcion);
    _horasDispController =
        TextEditingController(text: widget.horasDisp.toString());
    _costeController =
        TextEditingController(text: widget.coste.toString());
    _negociable = widget.negociable;
  }

  Future<void> _showDeleteConfirmation() async {
    if (!mounted) return;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar clase'),
          content: const Text('¿Estás seguro de que quieres eliminar esta clase? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Eliminar anuncio',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      await _deleteClase();
    }
  }

  Future<void> _deleteClase() async {
    if (_isNewDocument) {
      // Si es un documento nuevo, simplemente volver atrás
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    try {
      // Buscar el documento por id
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ClasPart')
          .where('id', isEqualTo: widget.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Eliminar el documento
        await querySnapshot.docs.first.reference.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clase eliminada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Volver atrás y notificar que se eliminó
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No se encontró la clase a eliminar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la clase: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error deleting clase: $e');
    }
  }

  Future<void> _updateClasPart() async {
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
          'IdUsuario': widget.idUsuario.toLowerCase(),
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
            Navigator.pop(context, true);
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Clases particulares',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (!_isNewDocument)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Eliminar clase',
            ),
        ],
      ),
      //drawer: Cajon(),
      body: SingleChildScrollView(
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
                      backgroundImage: _avatarImage(widget.foto),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 13),
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
                          children: [
                            Checkbox(
                              value: _negociable,
                              onChanged: (bool? value) {
                                setState(() {
                                  _negociable = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Negociable',
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
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
                    onPressed: _updateClasPart,
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