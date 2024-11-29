import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountsScreen extends StatefulWidget {
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAdmin = false;

  String getLocalizedStatus(String status) {
    if (Intl.getCurrentLocale() == 'ar') {
      switch (status) {
        case 'Admin':
          return 'أدمن';
        case 'Manager':
          return 'مدير';
        case 'Front Desk':
          return 'موظف استقبال';
        case 'HK Staff':
          return 'خدمة الغرف';
        default:
          return status; // Return the original status if no translation is available
      }
    }
    return status; // Return the original status for non-Arabic locales
  }

  String convertToArabic(String text) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String arabicText = text.replaceAllMapped(RegExp(r'\d'), (match) {
      return arabicDigits[int.parse(match.group(0)!)];
    });
    const textDictionary = {
      'Admin': 'أدمن',
      'Manager': 'مدير',
      'Front Desk': 'موظف استقبال',
      'HK Staff': 'خدمة الغرف',
    };
    textDictionary.forEach((key, value) {
      arabicText = arabicText.replaceAll(key, value);
    });
    return arabicText;
  }

  String getLocalizedText(String text) {
    if (Intl.getCurrentLocale() == 'ar') {
      return convertToArabic(text);
    }
    return text;
  }


  // Controllers for new user inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedAccountType = 'Front Desk';
  final List<String> roleOptions = ['Admin', 'Front Desk', 'HK Staff', 'Manager'];
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      bool adminStatus = snapshot.data()?['accountType'] == 'Admin';
      setState(() {
        isAdmin = adminStatus;
      });
      print('isAdmin: $isAdmin');  // Debugging
    }
  }
  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }

  Future<void> _updateAccountType(String userId, String newRole) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'accountType': newRole,
    });
    setState(() {}); // Refresh UI after updating the role
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account role updated to $newRole')),
    );
  }

  Future<void> _addUser() async {
    try {
      // Create a new user with Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final String userId = userCredential.user!.uid;
      final String userName = _nameController.text.isEmpty ? 'New User' : _nameController.text;

      // Add the new user's information to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userId': userId,
        'name': userName,
        'email': _emailController.text,
        'accountType': _selectedAccountType,
      });

      // Clear input fields after adding user
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _selectedAccountType = 'Front Desk';
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $e')),
      );
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(width: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(width: 8),
              DropdownButtonFormField<String>(
                value: _selectedAccountType,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: roleOptions.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(getLocalizedStatus(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAccountType = value;
                    }
                    );
                  }
                },
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',style: TextStyle(color:  Color(0xFFDBB017)),),
            ),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add User',style: TextStyle(color:  Color(0xFFDBB017)),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'User Accounts',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFDBB017),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No accounts found'));
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final userId = doc.id;
                  String currentRole = (data['accountType'] ?? 'Front Desk').toLowerCase();

                  // Ensure currentRole matches one of the dropdown items
                  if (roleOptions.map((role) => role.toLowerCase()).contains(currentRole)) {
                    currentRole = roleOptions.firstWhere((role) => role.toLowerCase() == currentRole);
                  } else {
                    currentRole = 'Front Desk'; // Fallback to default role if mismatch
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        data['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['email'] ?? 'No Email',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Row(
                                children: [
                                  DropdownButton<String>(
                                    value: currentRole,
                                    items: roleOptions.map((role) {
                                      return DropdownMenuItem(
                                        value: role,
                                        child: Text(role),
                                      );
                                    }).toList(),
                                    onChanged: isAdmin
                                        ? (newRole) {
                                      if (newRole != null && newRole != currentRole) {
                                        _updateAccountType(userId, newRole);
                                      }
                                    }
                                        : null,
                                    disabledHint: Text(
                                      currentRole,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: isAdmin
                                        ? () => _deleteUser(userId)
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          )

      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFFDBB017),
        child: const Icon(Icons.add),
      )
          : null,
    );}else{
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:  Text(
            S.current.userAccounts,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,                fontFamily: 'Amiri',
            ),
          ),
          backgroundColor: const Color(0xFFDBB017),
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No accounts found'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final userId = doc.id;
                    String currentRole = (data['accountType'] ?? 'Front Desk').toLowerCase();

                    // Ensure currentRole matches one of the dropdown items
                    if (roleOptions.map((role) => role.toLowerCase()).contains(currentRole)) {
                      currentRole = roleOptions.firstWhere((role) => role.toLowerCase() == currentRole);
                    } else {
                      currentRole = 'Front Desk'; // Fallback to default role if mismatch
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          data['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          children: [
                            SizedBox(height: 5,),

                            Column(
crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  data['email'] ?? 'No Email',
                                  style: TextStyle(color: Colors.grey[700],fontSize: 16),
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    DropdownButton<String>(
                                      value: currentRole,
                                      items: roleOptions.map((role) {
                                        return DropdownMenuItem(
                                          value: role,
                                          child: Text(getLocalizedStatus(role)),
                                        );
                                      }).toList(),
                                      onChanged: isAdmin
                                          ? (newRole) {
                                        if (newRole != null && newRole != currentRole) {
                                          _updateAccountType(userId, newRole);
                                        }
                                      }
                                          : null,
                                      disabledHint: Text(
                                        currentRole,
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: isAdmin
                                          ? () => _deleteUser(userId)
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )

        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
          onPressed: _showAddUserDialog,
          backgroundColor: const Color(0xFFDBB017),
          child: const Icon(Icons.add),
        )
            : null,
      );

    }
  }
}
