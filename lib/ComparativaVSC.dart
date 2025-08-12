import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartaEvento extends StatefulWidget {
  final String idUsuario;
  final String foto;
  final String nombre;
  final String apellido;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String fecha;
  final bool tienePresupuesto;
  final double presupuesto;
  final VoidCallback onChatPressed;

  const CartaEvento({
    super.key,
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
    required this.onChatPressed,
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

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? '';
      _isEditable = _userEmail == widget.idUsuario;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Evento'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.titulo,
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              Text(widget.descripcion),
              Text('Ubicación: ${widget.ubicacion}'),
              Text('Fecha: ${widget.fecha}'),
              Text('Tiene Presupuesto: ${widget.tienePresupuesto}'),
              Text('Presupuesto: ${widget.presupuesto} €'),
              if (!_isEditable)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: widget.onChatPressed,
                    child: Text('Chatear con el usuario'),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: _isEditable
            ? FloatingActionButton(
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
                      ),
                    ),
                  );
                },
                child: Icon(Icons.edit),
              )
            : null,
      ),
    );
  }
}

class CartaEventoEdit extends StatelessWidget {
  final String idUsuario;
  final String foto;
  final String nombre;
  final String apellido;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String fecha;
  final bool tienePresupuesto;
  final double presupuesto;

  const CartaEventoEdit({
    super.key,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: titulo),
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: TextEditingController(text: descripcion),
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: TextEditingController(text: ubicacion),
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
            TextField(
              controller: TextEditingController(text: fecha),
              decoration: InputDecoration(labelText: 'Fecha'),
            ),
            CheckboxListTile(
              title: Text('Tiene Presupuesto'),
              value: tienePresupuesto,
              onChanged: (bool? value) {
                // Handle change
              },
            ),
            TextField(
              controller: TextEditingController(text: presupuesto.toString()),
              decoration: InputDecoration(labelText: 'Presupuesto'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                // Handle save
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
