import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/firebase_options.dart';
import 'package:elitehotel/screens/dashboard_screen.dart';
import 'package:elitehotel/screens/front_desk_screen.dart';
import 'package:elitehotel/screens/guest_screen.dart';
import 'package:elitehotel/screens/hk_screen.dart';
import 'package:elitehotel/screens/login_screen.dart';
import 'package:elitehotel/screens/rates_screen.dart';
import 'package:elitehotel/screens/reservation_screen.dart';
import 'package:elitehotel/screens/rooms_screen.dart';
import 'package:elitehotel/screens/settings_screen.dart';
import 'package:elitehotel/screens/signup_screen.dart';
import 'package:elitehotel/widgets/dashboard_widgets/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/frontDesk': (context) => FrontDeskScreen(),
        '/housekeeping': (context) => HKScreen(),
        '/guests': (context) => GuestScreen(),
        '/rooms': (context) => RoomsScreen(),
        '/rates': (context) => RatesScreen(),
        '/reservations': (context) => ReservationScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  List<Widget> _pages = [];
  List<int> _visiblePages = [];
  String? userRole;

  @override
  void initState() {
    super.initState();
    _setupUserPages();
  }

  Future<void> _setupUserPages() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          userRole = userDoc.docs.first['accountType'];
          _pages = _getPagesForRole(userRole);
          _visiblePages = _getVisiblePagesForRole(userRole);
        });
      }
    }
  }

  List<Widget> _getPagesForRole(String? role) {
    switch (role) {
      case 'Admin':
      case 'Manager':
        return [
          DashboardScreen(),
          FrontDeskScreen(),
          HKScreen(),
          GuestScreen(),
          RoomsScreen(),
          RatesScreen(),
          ReservationScreen(),
          SettingsScreen(),
        ];
      case 'Front Desk':
        return [
          FrontDeskScreen(),
          HKScreen(),
          GuestScreen(),
          RoomsScreen(),
          RatesScreen(),
          ReservationScreen(),
          SettingsScreen(),
        ];
      case 'HK Staff':
        return [
          HKScreen(),
        ];
      default:
        return [];
    }
  }

  List<int> _getVisiblePagesForRole(String? role) {
    switch (role) {
      case 'Admin':
      case 'Manager':
        return [0, 1, 2, 3, 4, 5, 6, 7];
      case 'Front Desk':
        return [1, 2, 3, 4, 5, 6, 7];
      case 'HK Staff':
        return [2];
      default:
        return [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index; // Use the index directly from the visible pages
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.hotel, color: Color(0xFFDBB017)),
            SizedBox(width: 8),
            Text(
              'Elite Hotel',
              style: TextStyle(color: Color(0xFFDBB017)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: screenWidth > 600 // Adjust layout for larger screens
          ? Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            child: SideMenu(
              onItemTapped: _onItemTapped,
              visiblePages: _visiblePages,
            ),
          ),
          Expanded(
            child: _pages.isNotEmpty && selectedIndex < _pages.length
                ? _pages[selectedIndex]
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      )
          : Scaffold(
        drawer: Drawer(
          child: SideMenu(
            onItemTapped: _onItemTapped,
            visiblePages: _visiblePages,
          ),
        ),
        body: _pages.isNotEmpty && selectedIndex < _pages.length
            ? _pages[selectedIndex]
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}