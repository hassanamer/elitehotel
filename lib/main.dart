import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/firebase_options.dart';
import 'package:elitehotel/screens/dashboard_screen.dart';
import 'package:elitehotel/screens/front_desk_screen.dart';
import 'package:elitehotel/screens/guest_screen.dart';
import 'package:elitehotel/screens/hk_screen.dart';
import 'package:elitehotel/screens/invoices_screen.dart';
import 'package:elitehotel/screens/login_screen.dart';
import 'package:elitehotel/screens/rates_screen.dart';
import 'package:elitehotel/screens/reservation_screen.dart';
import 'package:elitehotel/screens/rooms_screen.dart';
import 'package:elitehotel/screens/settings_screen.dart';
import 'package:elitehotel/screens/signup_screen.dart';
import 'package:elitehotel/widgets/dashboard_widgets/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';

final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(MyApp(key: myAppKey));}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      print("Firebase app already initialized.");
    } else {
      rethrow;
    }
  }
}

// Background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer.periodic(const Duration(hours: 10), (_) async => await checkRoomAvailability());
}

Future<void> checkRoomAvailability() async {
  final roomCollection = FirebaseFirestore.instance.collection('rooms');
  final reservationCollection = FirebaseFirestore.instance.collection('reservations');
  DateTime now = DateTime.now();

  final rooms = await roomCollection.get();
  if (rooms.docs.isEmpty) return;

  await Future.wait(rooms.docs.map((roomDoc) => updateRoomStatus(roomDoc.id, now, reservationCollection, roomCollection)));
}

Future<void> updateRoomStatus(String roomNumber, DateTime now, CollectionReference reservationCollection, CollectionReference roomCollection) async {
  final reservations = await reservationCollection.where('roomNumber', isEqualTo: roomNumber).get();
  bool roomOccupied = reservations.docs.any((doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final checkIn = (data?['checkInDate'] as Timestamp?)?.toDate();
    final checkOut = (data?['checkOutDate'] as Timestamp?)?.toDate();
    return checkIn != null && checkOut != null && now.isAfter(checkIn) && now.isBefore(checkOut);
  });

  await roomCollection.doc(roomNumber).update({'status': roomOccupied ? 'Occupied' : 'Available'});
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  // Add a static method to access the setLocale
  static void setLocale(Locale locale) {
    myAppKey.currentState?._setLocale(locale);
  }

}
class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.white),
      initialRoute: '/login',
      routes: {
        '/': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(onLocaleChange: _setLocale), // Pass the locale change function
        '/dashboard': (context) => DashboardScreen(),
        '/frontDesk': (context) => FrontDeskScreen(),
        '/housekeeping': (context) => HKScreen(),
        '/guests': (context) => GuestScreen(),
        '/rooms': (context) => RoomsScreen(),
        '/rates': (context) => RatesScreen(),
        '/reservations': (context) => ReservationScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange; // Accept the locale change function

  MainScreen({required this.onLocaleChange}); // Constructor

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  List<Widget> pages = [];
  List<int> visiblePages = [];
  String? userRole;
  Timer? periodicTimer;

  @override
  void initState() {
    super.initState();
    initializeService();
    _setupUserPages();
  }

  @override
  void dispose() {
    periodicTimer?.cancel();
    super.dispose();
  }

  Future<void> _changeLanguage() async {
    // Use the passed function to change the locale
    widget.onLocaleChange(
        Localizations.localeOf(context).languageCode == 'en'
            ? const Locale('ar', 'SA')
            : const Locale('en', 'US')

    );


  }

  Future<void> initializeService() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final service = FlutterBackgroundService();
      service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
        ),
        iosConfiguration: IosConfiguration(onForeground: onStart, onBackground: (_) => true),
      );
      service.startService();
    } else {
      periodicTimer = Timer.periodic(const Duration(hours: 10), (_) async => await checkRoomAvailability());
    }
  }

  Future<void> _setupUserPages() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).limit(1).get();
      if (userDoc.docs.isNotEmpty) {
        setState(() {
          userRole = userDoc.docs.first['accountType'];
          pages = _getPagesForRole(userRole);
          visiblePages = _getVisiblePagesForRole(userRole);
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
        return [HKScreen()];
      default:
        return [];
    }
  }

  List<int> _getVisiblePagesForRole(String? role) {
    switch (role) {
      case 'Admin':
      case 'Manager':
        return List.generate(9, (index) => index);
      case 'Front Desk':
        return List.generate(7, (index) => index + 1);
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
    final appBar = AppBar(
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          Icon(Icons.hotel, color: Color(0xFFDBB017)),
          SizedBox(width: 8),
          Text('Elite Hotel', style: TextStyle(color: Color(0xFFDBB017))),
        ],
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(Icons.language),
          onPressed: () {
            _changeLanguage();
          },
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: screenWidth > 600
          ? Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            child: SideMenu(onItemTapped: _onItemTapped, visiblePages: visiblePages),
          ),
          Expanded(
            child: pages.isNotEmpty && selectedIndex < pages.length
                ? pages[selectedIndex]
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      )
          : Scaffold(
        drawer: Drawer(
          child: SideMenu(onItemTapped: _onItemTapped, visiblePages: visiblePages),
        ),
        body: pages.isNotEmpty && selectedIndex < pages.length
            ? pages[selectedIndex]
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}