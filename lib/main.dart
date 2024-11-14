import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elitehotel/firebase_options.dart';
import 'package:elitehotel/screens/accounts_screen.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Create an initial notification to start the service in the foreground
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'foreground_channel_id', 'Foreground Service',
      channelDescription: 'This notification keeps the background service running.',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false);
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  // Display the notification immediately to start the service in foreground
  await flutterLocalNotificationsPlugin.show(
      0,
      'Elite Hotel Service',
      'Background service running...',
      platformChannelSpecifics);

  // Initialize Firebase
  await Firebase.initializeApp();

  Timer.periodic(const Duration(minutes: 1), (_) async {
    try {
      await checkRoomAvailability();
    } catch (e) {
      print("Error checking room availability: $e");
    }
  });
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
  const MyApp({Key? key}) : super(key: key);  // Ensure the constructor accepts key

  @override
  _MyAppState createState() => _MyAppState();

  // Add a static method to access the setLocale
  static void setLocale(Locale locale) {
    myAppKey.currentState?._setLocale(locale);
  }


}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');  // Default locale is English

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,  // Set locale directly on MaterialApp
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: _locale.languageCode == 'ar' ? 'Amiri' : 'Helvetica',
          ),
          bodyMedium: TextStyle(
            fontFamily: _locale.languageCode == 'ar' ? 'Amiri' : 'Playfair',
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(onLocaleChange: _setLocale),
        '/dashboard': (context) => DashboardScreen(),
        '/frontDesk': (context) => FrontDeskScreen(),
        '/housekeeping': (context) => HKScreen(),
        '/guests': (context) => GuestScreen(),
        '/rooms': (context) => RoomsScreen(),
        '/rates': (context) => RatesScreen(),
        '/reservations': (context) => ReservationScreen(),
        '/settings': (context) => SettingsScreen(),
        '/accounts': (context) => AccountsScreen(),
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
      periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) async => await checkRoomAvailability());
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
          AccountsScreen(),
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