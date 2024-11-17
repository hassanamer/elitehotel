import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _changeLanguage() async {
    Locale newLocale = Localizations.localeOf(context).languageCode == 'en'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');
    MyApp.setLocale(newLocale); // Use the static method to change the locale
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );

        // Navigate to the main screen after successful login
        Navigator.of(context).pushReplacementNamed('/main');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {    final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDBB017),
              Colors.deepPurple,
              Colors.blueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(Icons.language),
              onPressed: () {
                setState(() {
                  _changeLanguage(); // Change the language first
                });
              },
            ),
          ],
        ),
      ),
    ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDBB017),
                  Colors.deepPurple,
                  Colors.blueAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animated Icons and Text Slogans
           (screenWidth > 600) ?

    Positioned(
            top: 140,
            left: 20,
            child: AnimatedOpacity(
              opacity: _animationController.value,
              duration: const Duration(seconds: 3),
              child: Text(
                S.current.welcomehosibility,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ):
           Positioned(
             top: 170,
             left: 20,
             child: AnimatedOpacity(
               opacity: _animationController.value,
               duration: const Duration(seconds: 3),
               child: Text(
                 S.current.welcomehosibility,
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ),
           ),
          Positioned(
            top: 60,
            right: 30,
            child: RotationTransition(
              turns: _animationController,
              child: Icon(
                Icons.family_restroom_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 120,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: RotationTransition(
              turns: _animationController,
              child: Icon(
                Icons.hotel_class_outlined,
                color: Colors.white.withOpacity(0.2),
                size: 120,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: (MediaQuery.of(context).size.width - 300) / 2,
            child: RotationTransition(
              turns: _animationController,
              child: Image.asset(
                'assets/elite.jpg',
                color: Colors.white.withOpacity(0.2),
                width: 300,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: RotationTransition(
              turns: _animationController,
              child: Icon(
                Icons.hotel_class_sharp,
                color: Colors.white.withOpacity(0.2),
                size: 120,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 30,
            child: RotationTransition(
              turns: _animationController,
              child: Icon(
                Icons.holiday_village_outlined,
                color: Colors.white.withOpacity(0.1),
                size: 120,
              ),
            ),
          ),
          // Login Form with Modern Text Fields
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                       Text(
                        S.current.logInToYourAccount,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                          S.current.email, Icons.email, (value) => _email = value),

                      const SizedBox(height: 20),

                      // Password Field with Eye Icon
                      _buildTextField(
                          S.current.password, Icons.lock, (value) => _password = value,
                          isPassword: true),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDBB017),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child:  Text(
                          S.current.logIn,
                          style: TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Link to Signup Screen
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/');
                        },
                        child: RichText(
                          text: TextSpan(
                            text: S.current.dontHaveAnAccount,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            children: [

                              TextSpan(
                                text: '  ',
                                style: const TextStyle(
                                  color: Color(0xFFDBB017),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: S.current.signUp,
                                style: const TextStyle(
                                  color: Color(0xFFDBB017),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to Build Modern Text Fields with Eye Icon for Password Field
  Widget _buildTextField(
      String label, IconData icon, ValueChanged<String> onChanged,
      {bool isPassword = false}) {
    return TextFormField(
      decoration: _inputDecoration(label).copyWith(
        prefixIcon: Icon(icon, color: Color(0xFFDBB017)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFFDBB017),
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        )
            : null,
      ),
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Color(0xFFDBB017)),
      onChanged: onChanged,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  // Custom Input Decoration for Text Fields
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}
