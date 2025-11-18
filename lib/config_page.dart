import 'inicio_sesion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'cajon_app_bar.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<StatefulWidget> createState() => _Configuracion();
}

class _Configuracion extends State<Configuracion> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  
  bool _soyMusico = false;
  List<InstrumentPair> _instrumentos = [InstrumentPair()];

  String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _userEmail;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profilePictureUrl;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidosController = TextEditingController();
    _telefonoController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioSesion()),
        );
        return;
      }

      _userId = user.uid;


      // Load user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Usuario')
          .doc(_userId)
          .get();

      if (!mounted) {
        return;
      }

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _nombreController.text = data['Nombre'].toString();
          _apellidosController.text = data['Apellido'].toString();
          _telefonoController.text = data['Telefono']?.toString() ?? '';
          _userEmail = data['email']?.toString() ?? FirebaseAuth.instance.currentUser?.email ?? 'No disponible';
          _soyMusico = data['SoyMusico'] ?? false;
          _profilePictureUrl = data['Foto']?.toString();
          
          // Load instruments if they exist
          if (data['Instrumentos'] != null && data['Instrumentos'] is List) {
            final instrumentsList = data['Instrumentos'] as List;
            _instrumentos = instrumentsList.map((item) {
              if (item is Map) {
                return InstrumentPair(
                  instrumento: item['instrumento']?.toString() ?? '',
                  nivel: item['nivel']?.toString() ?? 'beginner',
                );
              }
              return InstrumentPair();
            }).toList();
            
            // Ensure at least one pair exists
            if (_instrumentos.isEmpty) {
              _instrumentos = [InstrumentPair()];
            }
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate instruments if user is a musician
    if (_soyMusico) {
      // Remove empty instrument pairs
      _instrumentos.removeWhere((pair) => 
        pair.instrumento.trim().isEmpty && pair.nivel == 'beginner');
      
      // Check if at least one instrument is filled
      bool hasValidInstrument = _instrumentos.any((pair) => 
        pair.instrumento.trim().isNotEmpty);
      
      if (!hasValidInstrument) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, añade al menos un instrumento'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Ensure at least one pair exists
      if (_instrumentos.isEmpty) {
        _instrumentos = [InstrumentPair()];
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Upload profile picture if a new one was selected
      String? finalProfilePictureUrl = _profilePictureUrl;
      if (_pickedImage != null) {
        finalProfilePictureUrl = await _uploadImage();
      }

      // Prepare instruments data
      List<Map<String, String>> instrumentsData = [];
      if (_soyMusico) {
        instrumentsData = _instrumentos
            .where((pair) => pair.instrumento.trim().isNotEmpty)
            .map((pair) => {
              'instrumento': pair.instrumento.trim(),
              'nivel': pair.nivel,
            })
            .toList();
      }

      // Update Firestore
      final updateData = {
        'Nombre': _nombreController.text.trim(),
        'Apellido': _apellidosController.text.trim(),
        'Telefono': _telefonoController.text.trim(),
        'SoyMusico': _soyMusico,
        'Instrumentos': instrumentsData,
      };

      // Add profile picture URL if available
      if (finalProfilePictureUrl != null) {
        updateData['Foto'] = finalProfilePictureUrl;
      }

      await FirebaseFirestore.instance
          .collection('Usuario')
          .doc(_userId)
          .set(updateData, SetOptions(merge: true));

      // Update local state
      setState(() {
        _profilePictureUrl = finalProfilePictureUrl;
        _pickedImage = null; // Clear picked image after successful upload
      });

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos guardados exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addInstrumentPair() {
    if (_instrumentos.length < 20) {
      setState(() {
        _instrumentos.add(InstrumentPair());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 20 instrumentos permitidos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeInstrumentPair(int index) {
    if (_instrumentos.length > 1) {
      setState(() {
        _instrumentos.removeAt(index);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) {
      return _profilePictureUrl; // Return existing URL if no new image
    }

    if (_userId.isEmpty) {
      // Get user ID from current user if not set
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      _userId = user.uid;
    }

    try {


      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(_userId)
          .child('profile.jpg');

      await storageRef.putFile(_pickedImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Error al subir la imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Mi Cuenta',
              style: TextStyle(fontSize: 25, color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Cajon(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Mi Cuenta',
            style: TextStyle(fontSize: 25, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove('userEmail');
              await prefs.remove('userToken');
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const InicioSesion()),
              );
            },
            child: const Text(
              'Cerrar Sesion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      drawer: Cajon(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Profile picture section
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_profilePictureUrl != null &&
                                    _profilePictureUrl!.isNotEmpty)
                                ? NetworkImage(_profilePictureUrl!)
                                : const AssetImage('assets/default_user.jpg')
                                    as ImageProvider,
                        onBackgroundImageError: (exception, stackTrace) {
                          // Fallback to default image if network image fails
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                            onPressed: _pickImage,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Cambiar foto de perfil'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, color: Colors.red),
                const SizedBox(width: 8.0),
                Text(
                  _userEmail ?? FirebaseAuth.instance.currentUser?.email ?? 'Correo no disponible',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Nombre field
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Apellidos field
            TextFormField(
              controller: _apellidosController,
              decoration: const InputDecoration(
                labelText: 'Apellidos *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los apellidos son obligatorios';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Teléfono field
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: 'Ej: 612345678',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  // Check if it contains only numbers
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'El teléfono solo puede contener números';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24.0),

            // Soy músico checkbox
            CheckboxListTile(
              title: const Text(
                'Soy músico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              value: _soyMusico,
              onChanged: (bool? value) {
                setState(() {
                  _soyMusico = value ?? false;
                  // Reset instruments if unchecked
                  if (!_soyMusico) {
                    _instrumentos = [InstrumentPair()];
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16.0),

            // Instruments list (only shown if Soy músico is checked)
            if (_soyMusico) ...[
              const Text(
                'Instrumentos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ...List.generate(_instrumentos.length, (index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Instrumento ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (_instrumentos.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeInstrumentPair(index),
                                tooltip: 'Eliminar instrumento',
                              ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        // Instrument name field
                        TextFormField(
                          initialValue: _instrumentos[index].instrumento,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del instrumento',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.music_note),
                            hintText: 'Ej: Guitarra, Piano, Violín...',
                          ),
                          onChanged: (value) {
                            _instrumentos[index].instrumento = value;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        // Level dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _instrumentos[index].nivel,
                          decoration: const InputDecoration(
                            labelText: 'Nivel',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.star),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'beginner',
                              child: Text('Principiante'),
                            ),
                            DropdownMenuItem(
                              value: 'intermediate',
                              child: Text('Intermedio'),
                            ),
                            DropdownMenuItem(
                              value: 'advanced',
                              child: Text('Avanzado'),
                            ),
                            DropdownMenuItem(
                              value: 'self-taught',
                              child: Text('Autodidacta'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _instrumentos[index].nivel = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Add instrument button
              if (_instrumentos.length < 20)
                ElevatedButton.icon(
                  onPressed: _addInstrumentPair,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir instrumento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              const SizedBox(height: 24.0),
            ],

            // Save button at the bottom
            ElevatedButton(
              onPressed: _isSaving ? null : _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

// Helper class to manage instrument pairs
class InstrumentPair {
  String instrumento;
  String nivel;

  InstrumentPair({
    this.instrumento = '',
    this.nivel = 'beginner',
  });
}
