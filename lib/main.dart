import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/firebase_options.dart';
import 'package:elitehotel/generated/l10n.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/invoices_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyAe1Gj_RaiPtC2fcdcI3-P7v0EnGAWykuk", appId: "1:73510414994:web:e1ba59595f23d713ce544b", messagingSenderId: "73510414994", projectId: "elite-hotel-26752"), // Ensures correct platform-based configuration
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initial locale is English
  Locale _locale = Locale('en', 'US');

  // Method to change language
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        S.delegate,  // Your localization delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(changeLanguage: _changeLanguage),
        '/dashboard': (context) => DashboardScreen(),
        '/frontDesk': (context) => FrontDeskScreen(),
        '/housekeeping': (context) => HKScreen(),
        '/guests': (context) => GuestScreen(),
        '/rooms': (context) => RoomsScreen(),
        '/rates': (context) => RatesScreen(),
        '/reservations': (context) => ReservationScreen(),
        '/invoices': (context) => InvoicesScreen(),  // Add this line
      },
    );
  }
}
class MainScreen extends StatefulWidget {
  final Function(Locale) changeLanguage;

  MainScreen({required this.changeLanguage});

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
          InvoicesScreen(),  // Add Invoices screen here
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
        return [0, 1, 2, 3, 4, 5, 6, 7, 8];
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
      selectedIndex = index;
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
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              // Toggle between English and Arabic
              final currentLocale = Localizations.localeOf(context);
              if (currentLocale.languageCode == 'en') {
                widget.changeLanguage(Locale('ar', 'SA'));
              } else {
                widget.changeLanguage(Locale('en', 'US'));
              }
            },
          ),
        ],
      ),
      body: screenWidth > 600
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
