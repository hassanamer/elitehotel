import 'package:elitehotel/generated/l10n.dart';
import 'package:elitehotel/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> adminEmails = ['hassanamer281@gmail.com', 'behery_75@hotmail.com','hassanamer6543@gmail.com'];
  final List<String> managerEmails = ['hassanamer281@gmail.com', 'behery_75@hotmail.com','shepsishepsi66@gmail.com'];
  String _name = '';
  String _email = '';
  String _password = '';
  String _accountType = 'Front Desk';
  bool _isPasswordVisible = false;
  List<String> accountTypes = ['Admin', 'Front Desk', 'HK Staff', 'Manager'];

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
    MyApp.
    setLocale(newLocale); // Use the static method to change the locale
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch users with Admin and Manager roles
        QuerySnapshot adminSnapshot = await _firestore
            .collection('users')
            .where('accountType', isEqualTo: 'Admin')
            .get();
        QuerySnapshot managerSnapshot = await _firestore
            .collection('users')
            .where('accountType', isEqualTo: 'Manager')
            .get();

        // Check if the email is in the list of Admins or Managers
        bool isAdminEmail = adminSnapshot.docs.any((doc) => doc['email'] == _email);
        bool isManagerEmail = managerSnapshot.docs.any((doc) => doc['email'] == _email);

        if ((_accountType == 'Admin' && !isAdminEmail) ||
            (_accountType == 'Manager' && !isManagerEmail)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unauthorized email for $_accountType role')),
          );
          return; // Exit if unauthorized
        }

        // Check if the email already exists in the Firestore users collection
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: _email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Update the existing user document with new data
          String existingUserId = snapshot.docs.first.id;

          await _firestore.collection('users').doc(existingUserId).update({
            'name': _name,
            'accountType': _accountType,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account updated successfully!')),
          );
        } else {
          // Create a new user if email doesn't exist in the collection
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          // Store user data in Firestore
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'userID': userCredential.user!.uid,
            'name': _name,
            'email': _email,
            'accountType': _accountType,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
        }

        // Navigate to the main screen after successful signup or update
        Navigator.of(context).pushReplacementNamed('/main');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
          // Background Gradient with Primary Color
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

          // Background Icons and Animated Text Slogans
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
                'assets/elite.png',
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

          // Signup Form with Modern Text Fields
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                       Text(
                        S.current.createAccount,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      _buildTextField(
                          S.current.name, Icons.person, (value) => _name = value),

                      const SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                          S.current.email, Icons.email, (value) => _email = value),

                      const SizedBox(height: 20),

                      // Password Field with Eye Icon
                      _buildTextField(
                          S.current.password, Icons.lock, (value) => _password = value,
                          isPassword: true),

                      const SizedBox(height: 20),

                      // Account Type Dropdown
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(S.current.accountType),
                        dropdownColor: Colors.deepPurple,
                        iconEnabledColor: Color(0xFFDBB017),
                        style: const TextStyle(color: Color(0xFFDBB017)),
                        value: _accountType,
                        items: accountTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  _getAccountIcon(type),
                                  color: Color(0xFFDBB017),
                                ),
                                const SizedBox(width: 8),
                                Text(type,
                                    style:
                                    const TextStyle(color: Colors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _accountType = value!),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Button
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDBB017),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child:  Text(
                              S.current.signUp,
                              style:
                              TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                  '/login'); // Navigate to login screen
                            },
                            child: RichText(
                              text: TextSpan(
                                text: S.current.alreadyHaveAccount,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                children: [
                                  TextSpan(
                                    text: S.current.logIn,
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

  IconData _getAccountIcon(String accountType) {
    switch (accountType) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Front Desk':
        return Icons.front_hand;
      case 'HK Staff':
        return Icons.cleaning_services;
      case 'Manager':
        return Icons.manage_accounts;
      default:
        return Icons.account_circle;
    }
  }
}
