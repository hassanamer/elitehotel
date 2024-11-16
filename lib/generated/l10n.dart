// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Elite Hotel`
  String get appTitle {
    return Intl.message(
      'Elite Hotel',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Elite Hotel`
  String get homeTitle {
    return Intl.message(
      'Elite Hotel',
      name: 'homeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Front Desk`
  String get frontDesk {
    return Intl.message(
      'Front Desk',
      name: 'frontDesk',
      desc: '',
      args: [],
    );
  }

  /// `Housekeeping`
  String get housekeeping {
    return Intl.message(
      'Housekeeping',
      name: 'housekeeping',
      desc: '',
      args: [],
    );
  }

  /// `Guests`
  String get guests {
    return Intl.message(
      'Guests',
      name: 'guests',
      desc: '',
      args: [],
    );
  }

  /// `Rooms`
  String get rooms {
    return Intl.message(
      'Rooms',
      name: 'rooms',
      desc: '',
      args: [],
    );
  }

  /// `Rates`
  String get rates {
    return Intl.message(
      'Rates',
      name: 'rates',
      desc: '',
      args: [],
    );
  }

  /// `Reservations`
  String get reservations {
    return Intl.message(
      'Reservations',
      name: 'reservations',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get sideMenuDashboard {
    return Intl.message(
      'Dashboard',
      name: 'sideMenuDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Front Desk`
  String get sideMenuFrontDesk {
    return Intl.message(
      'Front Desk',
      name: 'sideMenuFrontDesk',
      desc: '',
      args: [],
    );
  }

  /// `Housekeeping`
  String get sideMenuHousekeeping {
    return Intl.message(
      'Housekeeping',
      name: 'sideMenuHousekeeping',
      desc: '',
      args: [],
    );
  }

  /// `Guests`
  String get sideMenuGuests {
    return Intl.message(
      'Guests',
      name: 'sideMenuGuests',
      desc: '',
      args: [],
    );
  }

  /// `Rooms`
  String get sideMenuRooms {
    return Intl.message(
      'Rooms',
      name: 'sideMenuRooms',
      desc: '',
      args: [],
    );
  }

  /// `Rates`
  String get sideMenuRates {
    return Intl.message(
      'Rates',
      name: 'sideMenuRates',
      desc: '',
      args: [],
    );
  }

  /// `Reservations`
  String get sideMenuReservations {
    return Intl.message(
      'Reservations',
      name: 'sideMenuReservations',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get sideMenuSettings {
    return Intl.message(
      'Settings',
      name: 'sideMenuSettings',
      desc: '',
      args: [],
    );
  }

  /// `Elite Hotel`
  String get appBarTitle {
    return Intl.message(
      'Elite Hotel',
      name: 'appBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Error loading page`
  String get errorLoadingPage {
    return Intl.message(
      'Error loading page',
      name: 'errorLoadingPage',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `You do not have access to this page`
  String get noAccess {
    return Intl.message(
      'You do not have access to this page',
      name: 'noAccess',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginScreenTitle {
    return Intl.message(
      'Login',
      name: 'loginScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signupScreenTitle {
    return Intl.message(
      'Sign Up',
      name: 'signupScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signupButton {
    return Intl.message(
      'Sign Up',
      name: 'signupButton',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logoutButton {
    return Intl.message(
      'Logout',
      name: 'logoutButton',
      desc: '',
      args: [],
    );
  }

  /// `Please login to continue`
  String get loginPrompt {
    return Intl.message(
      'Please login to continue',
      name: 'loginPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Please select a check-in date.`
  String get pleaseCheckinDate {
    return Intl.message(
      'Please select a check-in date.',
      name: 'pleaseCheckinDate',
      desc: '',
      args: [],
    );
  }

  /// `Please select a check-out date.`
  String get pleaseCheckoutDate {
    return Intl.message(
      'Please select a check-out date.',
      name: 'pleaseCheckoutDate',
      desc: '',
      args: [],
    );
  }

  /// `Check-out date must be after check-in date.`
  String get pleaseCheckoutDateafter {
    return Intl.message(
      'Check-out date must be after check-in date.',
      name: 'pleaseCheckoutDateafter',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid amount paid.`
  String get pleaseamountpaid {
    return Intl.message(
      'Please enter a valid amount paid.',
      name: 'pleaseamountpaid',
      desc: '',
      args: [],
    );
  }

  /// `Create a new account`
  String get signupPrompt {
    return Intl.message(
      'Create a new account',
      name: 'signupPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get userRoleAdmin {
    return Intl.message(
      'Admin',
      name: 'userRoleAdmin',
      desc: '',
      args: [],
    );
  }

  /// `Manager`
  String get userRoleManager {
    return Intl.message(
      'Manager',
      name: 'userRoleManager',
      desc: '',
      args: [],
    );
  }

  /// `Front Desk`
  String get userRoleFrontDesk {
    return Intl.message(
      'Front Desk',
      name: 'userRoleFrontDesk',
      desc: '',
      args: [],
    );
  }

  /// `Housekeeping Staff`
  String get userRoleHKStaff {
    return Intl.message(
      'Housekeeping Staff',
      name: 'userRoleHKStaff',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menuTitle {
    return Intl.message(
      'Menu',
      name: 'menuTitle',
      desc: '',
      args: [],
    );
  }

  /// `Elite Hotel`
  String get appLogo {
    return Intl.message(
      'Elite Hotel',
      name: 'appLogo',
      desc: '',
      args: [],
    );
  }

  /// `Hotel Icon`
  String get hotelIcon {
    return Intl.message(
      'Hotel Icon',
      name: 'hotelIcon',
      desc: '',
      args: [],
    );
  }

  /// `Error loading data`
  String get errorLoadingData {
    return Intl.message(
      'Error loading data',
      name: 'errorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `Floor`
  String get floor {
    return Intl.message(
      'Floor',
      name: 'floor',
      desc: '',
      args: [],
    );
  }

  /// `Occupied`
  String get occupied {
    return Intl.message(
      'Occupied',
      name: 'occupied',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message(
      'Available',
      name: 'available',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message(
      'Overview',
      name: 'overview',
      desc: '',
      args: [],
    );
  }

  /// `Today's\nCheck-ins`
  String get todaysCheckIns {
    return Intl.message(
      'Today\'s\nCheck-ins',
      name: 'todaysCheckIns',
      desc: '',
      args: [],
    );
  }

  /// `Today's Check-ins`
  String get todaysCheckInsMobile {
    return Intl.message(
      'Today\'s Check-ins',
      name: 'todaysCheckInsMobile',
      desc: '',
      args: [],
    );
  }

  /// `Today's\nCheck-outs`
  String get todaysCheckOuts {
    return Intl.message(
      'Today\'s\nCheck-outs',
      name: 'todaysCheckOuts',
      desc: '',
      args: [],
    );
  }

  /// `Today's Check-outs`
  String get todaysCheckOutsMobile {
    return Intl.message(
      'Today\'s Check-outs',
      name: 'todaysCheckOutsMobile',
      desc: '',
      args: [],
    );
  }

  /// `Total In\nHotel`
  String get totalInHotel {
    return Intl.message(
      'Total In\nHotel',
      name: 'totalInHotel',
      desc: '',
      args: [],
    );
  }

  /// `Total In Hotel`
  String get totalInHotelMobile {
    return Intl.message(
      'Total In Hotel',
      name: 'totalInHotelMobile',
      desc: '',
      args: [],
    );
  }

  /// `Total\nAvailable Rooms`
  String get totalAvailableRooms {
    return Intl.message(
      'Total\nAvailable Rooms',
      name: 'totalAvailableRooms',
      desc: '',
      args: [],
    );
  }

  /// `Total Available Rooms`
  String get totalAvailableRoomsMobile {
    return Intl.message(
      'Total Available Rooms',
      name: 'totalAvailableRoomsMobile',
      desc: '',
      args: [],
    );
  }

  /// `Total\nOccupied Rooms`
  String get totalOccupiedRooms {
    return Intl.message(
      'Total\nOccupied Rooms',
      name: 'totalOccupiedRooms',
      desc: '',
      args: [],
    );
  }

  /// `Total Occupied Rooms`
  String get totalOccupiedRoomsMobile {
    return Intl.message(
      'Total Occupied Rooms',
      name: 'totalOccupiedRoomsMobile',
      desc: '',
      args: [],
    );
  }

  /// `Occupancy Statistics`
  String get occupancyStatistics {
    return Intl.message(
      'Occupancy Statistics',
      name: 'occupancyStatistics',
      desc: '',
      args: [],
    );
  }

  /// `Today's Reservations:`
  String get todayreservations {
    return Intl.message(
      'Today\'s Reservations:',
      name: 'todayreservations',
      desc: '',
      args: [],
    );
  }

  /// `Month's Reservations:`
  String get monthreservations {
    return Intl.message(
      'Month\'s Reservations:',
      name: 'monthreservations',
      desc: '',
      args: [],
    );
  }

  /// `Reservations Amount'`
  String get reservationsamount {
    return Intl.message(
      'Reservations Amount\'',
      name: 'reservationsamount',
      desc: '',
      args: [],
    );
  }

  /// `Select Year`
  String get selectYear {
    return Intl.message(
      'Select Year',
      name: 'selectYear',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get day {
    return Intl.message(
      'day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Jan`
  String get jan {
    return Intl.message(
      'Jan',
      name: 'jan',
      desc: '',
      args: [],
    );
  }

  /// `Feb`
  String get feb {
    return Intl.message(
      'Feb',
      name: 'feb',
      desc: '',
      args: [],
    );
  }

  /// `Mar`
  String get mar {
    return Intl.message(
      'Mar',
      name: 'mar',
      desc: '',
      args: [],
    );
  }

  /// `Apr`
  String get apr {
    return Intl.message(
      'Apr',
      name: 'apr',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message(
      'May',
      name: 'may',
      desc: '',
      args: [],
    );
  }

  /// `Jun`
  String get jun {
    return Intl.message(
      'Jun',
      name: 'jun',
      desc: '',
      args: [],
    );
  }

  /// `Jul`
  String get jul {
    return Intl.message(
      'Jul',
      name: 'jul',
      desc: '',
      args: [],
    );
  }

  /// `Aug`
  String get aug {
    return Intl.message(
      'Aug',
      name: 'aug',
      desc: '',
      args: [],
    );
  }

  /// `Sep`
  String get sep {
    return Intl.message(
      'Sep',
      name: 'sep',
      desc: '',
      args: [],
    );
  }

  /// `Oct`
  String get oct {
    return Intl.message(
      'Oct',
      name: 'oct',
      desc: '',
      args: [],
    );
  }

  /// `Nov`
  String get nov {
    return Intl.message(
      'Nov',
      name: 'nov',
      desc: '',
      args: [],
    );
  }

  /// `Dec`
  String get dec {
    return Intl.message(
      'Dec',
      name: 'dec',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Days`
  String get days {
    return Intl.message(
      'Days',
      name: 'days',
      desc: '',
      args: [],
    );
  }

  /// `Room Status`
  String get roomStatus {
    return Intl.message(
      'Room Status',
      name: 'roomStatus',
      desc: '',
      args: [],
    );
  }

  /// `Occupied Rooms`
  String get occupiedRooms {
    return Intl.message(
      'Occupied Rooms',
      name: 'occupiedRooms',
      desc: '',
      args: [],
    );
  }

  /// `Available Rooms`
  String get availableRooms {
    return Intl.message(
      'Available Rooms',
      name: 'availableRooms',
      desc: '',
      args: [],
    );
  }

  /// `Clean`
  String get clean {
    return Intl.message(
      'Clean',
      name: 'clean',
      desc: '',
      args: [],
    );
  }

  /// `Dirty`
  String get dirty {
    return Intl.message(
      'Dirty',
      name: 'dirty',
      desc: '',
      args: [],
    );
  }

  /// `Floor Status`
  String get floorStatus {
    return Intl.message(
      'Floor Status',
      name: 'floorStatus',
      desc: '',
      args: [],
    );
  }

  /// `Create Your Account`
  String get createAccount {
    return Intl.message(
      'Create Your Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Account Type`
  String get accountType {
    return Intl.message(
      'Account Type',
      name: 'accountType',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get logIn {
    return Intl.message(
      'Log in',
      name: 'logIn',
      desc: '',
      args: [],
    );
  }

  /// `Account created successfully!`
  String get accountCreated {
    return Intl.message(
      'Account created successfully!',
      name: 'accountCreated',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String error(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'error',
      desc: '',
      args: [error],
    );
  }

  /// `Please enter {field}`
  String fieldRequired(Object field) {
    return Intl.message(
      'Please enter $field',
      name: 'fieldRequired',
      desc: '',
      args: [field],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get enterEmail {
    return Intl.message(
      'Enter your email',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get sendResetLink {
    return Intl.message(
      'Send Reset Link',
      name: 'sendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `Password reset link sent to your email.`
  String get resetLinkSent {
    return Intl.message(
      'Password reset link sent to your email.',
      name: 'resetLinkSent',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send reset email: {error}`
  String failedResetEmail(Object error) {
    return Intl.message(
      'Failed to send reset email: $error',
      name: 'failedResetEmail',
      desc: '',
      args: [error],
    );
  }

  /// `Room Management`
  String get roomManagement {
    return Intl.message(
      'Room Management',
      name: 'roomManagement',
      desc: '',
      args: [],
    );
  }

  /// `Search by room number, bed type, or floor`
  String get searchPlaceholder {
    return Intl.message(
      'Search by room number, bed type, or floor',
      name: 'searchPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get statusAll {
    return Intl.message(
      'All',
      name: 'statusAll',
      desc: '',
      args: [],
    );
  }

  /// `All Floors`
  String get allFloors {
    return Intl.message(
      'All Floors',
      name: 'allFloors',
      desc: '',
      args: [],
    );
  }

  /// `Assigned`
  String get assigned {
    return Intl.message(
      'Assigned',
      name: 'assigned',
      desc: '',
      args: [],
    );
  }

  /// `Assign To HK`
  String get assignedToHk {
    return Intl.message(
      'Assign To HK',
      name: 'assignedToHk',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `All Types`
  String get allTypes {
    return Intl.message(
      'All Types',
      name: 'allTypes',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get statusAvailable {
    return Intl.message(
      'Available',
      name: 'statusAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Occupied`
  String get statusOccupied {
    return Intl.message(
      'Occupied',
      name: 'statusOccupied',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance`
  String get statusMaintenance {
    return Intl.message(
      'Maintenance',
      name: 'statusMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `Dirty`
  String get statusDirty {
    return Intl.message(
      'Dirty',
      name: 'statusDirty',
      desc: '',
      args: [],
    );
  }

  /// `Clean`
  String get statusClean {
    return Intl.message(
      'Clean',
      name: 'statusClean',
      desc: '',
      args: [],
    );
  }

  /// `Current Guest`
  String get currentGuest {
    return Intl.message(
      'Current Guest',
      name: 'currentGuest',
      desc: '',
      args: [],
    );
  }

  /// `Add Room`
  String get addRoom {
    return Intl.message(
      'Add Room',
      name: 'addRoom',
      desc: '',
      args: [],
    );
  }

  /// `Reservation created successfully!`
  String get reservationSuccess {
    return Intl.message(
      'Reservation created successfully!',
      name: 'reservationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Reservation deleted successfully!`
  String get reservationDeletedSuccess {
    return Intl.message(
      'Reservation deleted successfully!',
      name: 'reservationDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Room Floor`
  String get roomFloor {
    return Intl.message(
      'Room Floor',
      name: 'roomFloor',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, please try again.`
  String get errorMessage {
    return Intl.message(
      'An error occurred, please try again.',
      name: 'errorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Guest Name`
  String get guestNameLabel {
    return Intl.message(
      'Guest Name',
      name: 'guestNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Check-In Date`
  String get checkInLabel {
    return Intl.message(
      'Check-In Date',
      name: 'checkInLabel',
      desc: '',
      args: [],
    );
  }

  /// `Check-Out Date`
  String get checkOutLabel {
    return Intl.message(
      'Check-Out Date',
      name: 'checkOutLabel',
      desc: '',
      args: [],
    );
  }

  /// `Total Cost`
  String get totalCostLabel {
    return Intl.message(
      'Total Cost',
      name: 'totalCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Amount Paid`
  String get amountPaidLabel {
    return Intl.message(
      'Amount Paid',
      name: 'amountPaidLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remaining Balance`
  String get remainingBalanceLabel {
    return Intl.message(
      'Remaining Balance',
      name: 'remainingBalanceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Guest Name`
  String get guestName {
    return Intl.message(
      'Guest Name',
      name: 'guestName',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Guest Name`
  String get enterGuestName {
    return Intl.message(
      'Please Enter Guest Name',
      name: 'enterGuestName',
      desc: '',
      args: [],
    );
  }

  /// `Room Type`
  String get roomType {
    return Intl.message(
      'Room Type',
      name: 'roomType',
      desc: '',
      args: [],
    );
  }

  /// `Number of Adults`
  String get numberOfAdults {
    return Intl.message(
      'Number of Adults',
      name: 'numberOfAdults',
      desc: '',
      args: [],
    );
  }

  /// `Number of Children`
  String get numberOfChildren {
    return Intl.message(
      'Number of Children',
      name: 'numberOfChildren',
      desc: '',
      args: [],
    );
  }

  /// `Check-In Date`
  String get checkInDate {
    return Intl.message(
      'Check-In Date',
      name: 'checkInDate',
      desc: '',
      args: [],
    );
  }

  /// `Check-Out Date`
  String get checkOutDate {
    return Intl.message(
      'Check-Out Date',
      name: 'checkOutDate',
      desc: '',
      args: [],
    );
  }

  /// `Amount Paid`
  String get amountPaid {
    return Intl.message(
      'Amount Paid',
      name: 'amountPaid',
      desc: '',
      args: [],
    );
  }

  /// `Notes (e.g., breakfast request)`
  String get notes {
    return Intl.message(
      'Notes (e.g., breakfast request)',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Select Note Frequency`
  String get noteFrequency {
    return Intl.message(
      'Select Note Frequency',
      name: 'noteFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Room Type`
  String get selectRoomType {
    return Intl.message(
      'Please Select Room Type',
      name: 'selectRoomType',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid number of adults`
  String get enterNumOfAdults {
    return Intl.message(
      'Please enter a valid number of adults',
      name: 'enterNumOfAdults',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid number of children`
  String get enterNumOfChildren {
    return Intl.message(
      'Please enter a valid number of children',
      name: 'enterNumOfChildren',
      desc: '',
      args: [],
    );
  }

  /// `Total Cost`
  String get totalCost {
    return Intl.message(
      'Total Cost',
      name: 'totalCost',
      desc: '',
      args: [],
    );
  }

  /// `Remaining`
  String get remainingBalance {
    return Intl.message(
      'Remaining',
      name: 'remainingBalance',
      desc: '',
      args: [],
    );
  }

  /// `Create Reservation`
  String get createReservation {
    return Intl.message(
      'Create Reservation',
      name: 'createReservation',
      desc: '',
      args: [],
    );
  }

  /// `Reservation ID`
  String get reservationId {
    return Intl.message(
      'Reservation ID',
      name: 'reservationId',
      desc: '',
      args: [],
    );
  }

  /// `Room Number`
  String get roomNumber {
    return Intl.message(
      'Room Number',
      name: 'roomNumber',
      desc: '',
      args: [],
    );
  }

  /// `Check-In`
  String get checkIn {
    return Intl.message(
      'Check-In',
      name: 'checkIn',
      desc: '',
      args: [],
    );
  }

  /// `Check-Out`
  String get checkOut {
    return Intl.message(
      'Check-Out',
      name: 'checkOut',
      desc: '',
      args: [],
    );
  }

  /// `Notes (e.g., breakfast request)`
  String get notesBreakfast {
    return Intl.message(
      'Notes (e.g., breakfast request)',
      name: 'notesBreakfast',
      desc: '',
      args: [],
    );
  }

  /// `Select Note Frequency`
  String get selectNoteFrequency {
    return Intl.message(
      'Select Note Frequency',
      name: 'selectNoteFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Just Once`
  String get justOnce {
    return Intl.message(
      'Just Once',
      name: 'justOnce',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Rates Management`
  String get ratesManagement {
    return Intl.message(
      'Rates Management',
      name: 'ratesManagement',
      desc: '',
      args: [],
    );
  }

  /// `Add Rate`
  String get addRate {
    return Intl.message(
      'Add Rate',
      name: 'addRate',
      desc: '',
      args: [],
    );
  }

  /// `Search by Package`
  String get searchByPackage {
    return Intl.message(
      'Search by Package',
      name: 'searchByPackage',
      desc: '',
      args: [],
    );
  }

  /// `Package`
  String get package {
    return Intl.message(
      'Package',
      name: 'package',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get rate {
    return Intl.message(
      'Rate',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  /// `Actions`
  String get actions {
    return Intl.message(
      'Actions',
      name: 'actions',
      desc: '',
      args: [],
    );
  }

  /// `Add New Rate`
  String get addNewRate {
    return Intl.message(
      'Add New Rate',
      name: 'addNewRate',
      desc: '',
      args: [],
    );
  }

  /// `Edit Rate`
  String get editRate {
    return Intl.message(
      'Edit Rate',
      name: 'editRate',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Invoices`
  String get invoices {
    return Intl.message(
      'Invoices',
      name: 'invoices',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message(
      'Item',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Elite Hospitality`
  String get welcomehosibility {
    return Intl.message(
      'Welcome to Elite Hospitality',
      name: 'welcomehosibility',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get qty {
    return Intl.message(
      'Quantity',
      name: 'qty',
      desc: '',
      args: [],
    );
  }

  /// `Night Price`
  String get nightPrice {
    return Intl.message(
      'Night Price',
      name: 'nightPrice',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for choosing us!`
  String get slugan1 {
    return Intl.message(
      'Thank you for choosing us!',
      name: 'slugan1',
      desc: '',
      args: [],
    );
  }

  /// `Experience luxury at Elite Hotel - Where every moment matters.`
  String get slugan2 {
    return Intl.message(
      'Experience luxury at Elite Hotel - Where every moment matters.',
      name: 'slugan2',
      desc: '',
      args: [],
    );
  }

  /// `Invoice Details`
  String get invoicesDetails {
    return Intl.message(
      'Invoice Details',
      name: 'invoicesDetails',
      desc: '',
      args: [],
    );
  }

  /// `Print Invoice`
  String get printInvoice {
    return Intl.message(
      'Print Invoice',
      name: 'printInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Creation Date`
  String get creationDate {
    return Intl.message(
      'Creation Date',
      name: 'creationDate',
      desc: '',
      args: [],
    );
  }

  /// `Invoice Number`
  String get invoicesNumber {
    return Intl.message(
      'Invoice Number',
      name: 'invoicesNumber',
      desc: '',
      args: [],
    );
  }

  /// `Select Package`
  String get selectPackage {
    return Intl.message(
      'Select Package',
      name: 'selectPackage',
      desc: '',
      args: [],
    );
  }

  /// `No rates available.`
  String get noRatesAvailable {
    return Intl.message(
      'No rates available.',
      name: 'noRatesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No available rooms of this type`
  String get noAvailablerooms {
    return Intl.message(
      'No available rooms of this type',
      name: 'noAvailablerooms',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back to Elite Hospitality`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back to Elite Hospitality',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Log In to Your Account`
  String get logInToYourAccount {
    return Intl.message(
      'Log In to Your Account',
      name: 'logInToYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAnAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// ` Log In to Your Account`
  String get logintoaccount {
    return Intl.message(
      ' Log In to Your Account',
      name: 'logintoaccount',
      desc: '',
      args: [],
    );
  }

  /// `Logged in successfully!`
  String get loggedInSuccessfully {
    return Intl.message(
      'Logged in successfully!',
      name: 'loggedInSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Availability`
  String get availability {
    return Intl.message(
      'Availability',
      name: 'availability',
      desc: '',
      args: [],
    );
  }

  /// `Hello, {name}! 👋`
  String hello(Object name) {
    return Intl.message(
      'Hello, $name! 👋',
      name: 'hello',
      desc: '',
      args: [name],
    );
  }

  /// `Working Hours`
  String get workingHours {
    return Intl.message(
      'Working Hours',
      name: 'workingHours',
      desc: '',
      args: [],
    );
  }

  /// `Location:`
  String get location {
    return Intl.message(
      'Location:',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Punch In`
  String get punchIn {
    return Intl.message(
      'Punch In',
      name: 'punchIn',
      desc: '',
      args: [],
    );
  }

  /// `Punch Out`
  String get punchOut {
    return Intl.message(
      'Punch Out',
      name: 'punchOut',
      desc: '',
      args: [],
    );
  }

  /// `No rooms need cleaning!`
  String get noRoomsNeedCleaning {
    return Intl.message(
      'No rooms need cleaning!',
      name: 'noRoomsNeedCleaning',
      desc: '',
      args: [],
    );
  }

  /// `Add Request`
  String get addRequest {
    return Intl.message(
      'Add Request',
      name: 'addRequest',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Payment Method`
  String get paymenMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymenMethod',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message(
      'Cash',
      name: 'cash',
      desc: '',
      args: [],
    );
  }

  /// `Visa`
  String get visa {
    return Intl.message(
      'Visa',
      name: 'visa',
      desc: '',
      args: [],
    );
  }

  /// `New User`
  String get newUser {
    return Intl.message(
      'New User',
      name: 'newUser',
      desc: '',
      args: [],
    );
  }

  /// `Add User`
  String get addUser {
    return Intl.message(
      'Add User',
      name: 'addUser',
      desc: '',
      args: [],
    );
  }

  /// `Add New User`
  String get addNewUser {
    return Intl.message(
      'Add New User',
      name: 'addNewUser',
      desc: '',
      args: [],
    );
  }

  /// `User Added Successfully`
  String get userAdded {
    return Intl.message(
      'User Added Successfully',
      name: 'userAdded',
      desc: '',
      args: [],
    );
  }

  /// `Bank Transfer`
  String get bank {
    return Intl.message(
      'Bank Transfer',
      name: 'bank',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get accounts {
    return Intl.message(
      'Accounts',
      name: 'accounts',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get userAccounts {
    return Intl.message(
      'Accounts',
      name: 'userAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Enter Request Details`
  String get enterRequestDetails {
    return Intl.message(
      'Enter Request Details',
      name: 'enterRequestDetails',
      desc: '',
      args: [],
    );
  }

  /// `There is No RequestS`
  String get nofrontdeskrequests {
    return Intl.message(
      'There is No RequestS',
      name: 'nofrontdeskrequests',
      desc: '',
      args: [],
    );
  }

  /// `Account role updated to`
  String get accountRoleUpdated {
    return Intl.message(
      'Account role updated to',
      name: 'accountRoleUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Instapay`
  String get instapay {
    return Intl.message(
      'Instapay',
      name: 'instapay',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message(
      'In Progress',
      name: 'inProgress',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `You have already checked in today.`
  String get youHaveAlreadyCheckedIn {
    return Intl.message(
      'You have already checked in today.',
      name: 'youHaveAlreadyCheckedIn',
      desc: '',
      args: [],
    );
  }

  /// `No assigned notes.`
  String get noassignednotes {
    return Intl.message(
      'No assigned notes.',
      name: 'noassignednotes',
      desc: '',
      args: [],
    );
  }

  /// `Assigned Notes.`
  String get assignedNotes {
    return Intl.message(
      'Assigned Notes.',
      name: 'assignedNotes',
      desc: '',
      args: [],
    );
  }

  /// `You must check in before checking out.`
  String get youMustCheckInBeforeCheckingOut {
    return Intl.message(
      'You must check in before checking out.',
      name: 'youMustCheckInBeforeCheckingOut',
      desc: '',
      args: [],
    );
  }

  /// `Location services are disabled.`
  String get locationServicesDisabled {
    return Intl.message(
      'Location services are disabled.',
      name: 'locationServicesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Location services are not available on this platform.`
  String get locationServicesNotAvailable {
    return Intl.message(
      'Location services are not available on this platform.',
      name: 'locationServicesNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Check In Time: {time}`
  String checkInTime(Object time) {
    return Intl.message(
      'Check In Time: $time',
      name: 'checkInTime',
      desc: '',
      args: [time],
    );
  }

  /// `Check Out Time: {time}`
  String checkOutTime(Object time) {
    return Intl.message(
      'Check Out Time: $time',
      name: 'checkOutTime',
      desc: '',
      args: [time],
    );
  }

  /// `{hours}h {minutes}m`
  String workingHoursFormat(Object hours, Object minutes) {
    return Intl.message(
      '${hours}h ${minutes}m',
      name: 'workingHoursFormat',
      desc: '',
      args: [hours, minutes],
    );
  }

  /// `Attendance Info`
  String get attendanceInfo {
    return Intl.message(
      'Attendance Info',
      name: 'attendanceInfo',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message(
      'Requests',
      name: 'requests',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Guest Management`
  String get guestManagement {
    return Intl.message(
      'Guest Management',
      name: 'guestManagement',
      desc: '',
      args: [],
    );
  }

  /// `Search by name, ID, or room`
  String get searchBy {
    return Intl.message(
      'Search by name, ID, or room',
      name: 'searchBy',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Status`
  String get filterByStatus {
    return Intl.message(
      'Filter by Status',
      name: 'filterByStatus',
      desc: '',
      args: [],
    );
  }

  /// `Checked In`
  String get checkedIn {
    return Intl.message(
      'Checked In',
      name: 'checkedIn',
      desc: '',
      args: [],
    );
  }

  /// `Checked Out`
  String get checkedOut {
    return Intl.message(
      'Checked Out',
      name: 'checkedOut',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming`
  String get upcoming {
    return Intl.message(
      'Upcoming',
      name: 'upcoming',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Check-In/Out`
  String get checkInOut {
    return Intl.message(
      'Check-In/Out',
      name: 'checkInOut',
      desc: '',
      args: [],
    );
  }

  /// `No guests found.`
  String get noGuestsFound {
    return Intl.message(
      'No guests found.',
      name: 'noGuestsFound',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching guest data: {error}`
  String errorFetchingData(Object error) {
    return Intl.message(
      'Error fetching guest data: $error',
      name: 'errorFetchingData',
      desc: '',
      args: [error],
    );
  }

  /// `Daily Guest Requests`
  String get dailyGuestRequests {
    return Intl.message(
      'Daily Guest Requests',
      name: 'dailyGuestRequests',
      desc: '',
      args: [],
    );
  }

  /// `No requests for today`
  String get noRequestsForToday {
    return Intl.message(
      'No requests for today',
      name: 'noRequestsForToday',
      desc: '',
      args: [],
    );
  }

  /// `Room`
  String get room {
    return Intl.message(
      'Room',
      name: 'room',
      desc: '',
      args: [],
    );
  }

  /// `Guest Request`
  String get guestRequest {
    return Intl.message(
      'Guest Request',
      name: 'guestRequest',
      desc: '',
      args: [],
    );
  }

  /// `Frequency`
  String get frequency {
    return Intl.message(
      'Frequency',
      name: 'frequency',
      desc: '',
      args: [],
    );
  }

  /// `Calendar & Rooms`
  String get calendar {
    return Intl.message(
      'Calendar & Rooms',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Guest Requests`
  String get guestRequests {
    return Intl.message(
      'Guest Requests',
      name: 'guestRequests',
      desc: '',
      args: [],
    );
  }

  /// `Main Dashboard`
  String get mainDashboard {
    return Intl.message(
      'Main Dashboard',
      name: 'mainDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Add New Room`
  String get addNewRoom {
    return Intl.message(
      'Add New Room',
      name: 'addNewRoom',
      desc: '',
      args: [],
    );
  }

  /// `Bed Type`
  String get bedType {
    return Intl.message(
      'Bed Type',
      name: 'bedType',
      desc: '',
      args: [],
    );
  }

  /// `Facilities:`
  String get facilities {
    return Intl.message(
      'Facilities:',
      name: 'facilities',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning Status`
  String get cleaningStatus {
    return Intl.message(
      'Cleaning Status',
      name: 'cleaningStatus',
      desc: '',
      args: [],
    );
  }

  /// `Single`
  String get single {
    return Intl.message(
      'Single',
      name: 'single',
      desc: '',
      args: [],
    );
  }

  /// `Double`
  String get double {
    return Intl.message(
      'Double',
      name: 'double',
      desc: '',
      args: [],
    );
  }

  /// `Suite`
  String get suite {
    return Intl.message(
      'Suite',
      name: 'suite',
      desc: '',
      args: [],
    );
  }

  /// `Available Room`
  String get availableroom {
    return Intl.message(
      'Available Room',
      name: 'availableroom',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: '',
      args: [],
    );
  }

  /// `Job`
  String get job {
    return Intl.message(
      'Job',
      name: 'job',
      desc: '',
      args: [],
    );
  }

  /// `National ID`
  String get nationalId {
    return Intl.message(
      'National ID',
      name: 'nationalId',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get mobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Guest Address`
  String get guestAddress {
    return Intl.message(
      'Guest Address',
      name: 'guestAddress',
      desc: '',
      args: [],
    );
  }

  /// `Mini Suite`
  String get miniSuite {
    return Intl.message(
      'Mini Suite',
      name: 'miniSuite',
      desc: '',
      args: [],
    );
  }

  /// `WiFi`
  String get wifi {
    return Intl.message(
      'WiFi',
      name: 'wifi',
      desc: '',
      args: [],
    );
  }

  /// `TV`
  String get tv {
    return Intl.message(
      'TV',
      name: 'tv',
      desc: '',
      args: [],
    );
  }

  /// `Fridge`
  String get fridge {
    return Intl.message(
      'Fridge',
      name: 'fridge',
      desc: '',
      args: [],
    );
  }

  /// `AC`
  String get ac {
    return Intl.message(
      'AC',
      name: 'ac',
      desc: '',
      args: [],
    );
  }

  /// `Mini-bar`
  String get minibar {
    return Intl.message(
      'Mini-bar',
      name: 'minibar',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
