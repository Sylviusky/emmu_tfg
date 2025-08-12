import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: prefer_const_constructors

void main() {
  runApp(const BasicPrefsApp());
}

class BasicPrefsApp extends StatefulWidget {
  const BasicPrefsApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BasicPrefsAppState();
  }
}

class _BasicPrefsAppState extends State<BasicPrefsApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shared Preferences Basics'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Favorite food',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Text(
                'Favorite food goes here',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors

class _BasicPrefsAppState2 extends State<BasicPrefsApp> {
  SharedPreferences? _prefs;

  // These values can be set to null (e.g. 'int? numToppings;'), but this will
  // require additional null checks to prevent errors
  String _favoriteFood = '';
  List<String> _ingredients = [];
  bool _isDelicious = false;
  int _numToppings = 0;
  double _price = 0.00;

  final String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _setPrefs();
    //_getPrefs();
    //_removePrefs();
  }

  void _setPrefs() {
    _prefs?.setString('favoriteFood', 'Pizza');
    _prefs?.setStringList('ingredients', <String>['dough', 'sauce', 'cheese']);
    _prefs?.setBool('isDelicious', true);
    _prefs?.setInt('numToppings', 5);
    _prefs?.setDouble('price', 9.99);

    print('setPrefs method called');
  }

  void _getPrefs() {
    setState(() {
      _favoriteFood = _prefs?.getString('favoriteFood') ?? 'null';
      _ingredients = _prefs?.getStringList('ingredients') ??
          ['topping1', 'topping2', 'topping3'];
      _isDelicious = _prefs?.getBool('isDelicious') ?? false;
      _numToppings = _prefs?.getInt('numToppings') ?? 0;
      _price = _prefs?.getDouble('price') ?? 0;
    });
    print('getPrefs method called');
  }

  void _removePrefs() {
    _prefs?.remove('favoriteFood');
    _prefs?.remove('ingredients');
    _prefs?.remove('isDelicious');
    _prefs?.remove('numToppings');
    _prefs?.remove('price');
    print('removePrefs method called');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shared Preferences Basics'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Favorite food',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Text(
                _favoriteFood,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Text(
                'Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Text(
                _ingredients.join(', ').toString(),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Text(
                'Is Delicious?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Text(
                _isDelicious.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Text(
                'Num Toppings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Text(
                _numToppings.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Text(
                'Price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Text(
                _price.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
