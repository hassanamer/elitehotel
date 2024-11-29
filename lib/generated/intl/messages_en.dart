// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(time) => "Check In Time: ${time}";

  static String m1(time) => "Check Out Time: ${time}";

  static String m2(error) => "Error: ${error}";

  static String m3(error) => "Error fetching guest data: ${error}";

  static String m4(error) => "Failed to send reset email: ${error}";

  static String m5(field) => "Please enter ${field}";

  static String m6(name) => "Hello, ${name}! 👋";

  static String m7(hours, minutes) => "${hours}h ${minutes}m";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ac": MessageLookupByLibrary.simpleMessage("AC"),
        "accountCreated": MessageLookupByLibrary.simpleMessage(
            "Account created successfully!"),
        "accountRoleUpdated":
            MessageLookupByLibrary.simpleMessage("Account role updated to"),
        "accountType": MessageLookupByLibrary.simpleMessage("Account Type"),
        "accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "actions": MessageLookupByLibrary.simpleMessage("Actions"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addNewRate": MessageLookupByLibrary.simpleMessage("Add New Rate"),
        "addNewRoom": MessageLookupByLibrary.simpleMessage("Add New Room"),
        "addNewUser": MessageLookupByLibrary.simpleMessage("Add New User"),
        "addRate": MessageLookupByLibrary.simpleMessage("Add Rate"),
        "addRequest": MessageLookupByLibrary.simpleMessage("Add Request"),
        "addRoom": MessageLookupByLibrary.simpleMessage("Add Room"),
        "addUser": MessageLookupByLibrary.simpleMessage("Add User"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "allFloors": MessageLookupByLibrary.simpleMessage("All Floors"),
        "allTypes": MessageLookupByLibrary.simpleMessage("All Types"),
        "alreadyHaveAccount":
            MessageLookupByLibrary.simpleMessage("Already have an account? "),
        "amountPaid": MessageLookupByLibrary.simpleMessage("Amount Paid"),
        "amountPaidLabel": MessageLookupByLibrary.simpleMessage("Amount Paid"),
        "appBarTitle": MessageLookupByLibrary.simpleMessage("Elite Hotel"),
        "appLogo": MessageLookupByLibrary.simpleMessage("Elite Hotel"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Elite Hotel"),
        "apr": MessageLookupByLibrary.simpleMessage("Apr"),
        "assigned": MessageLookupByLibrary.simpleMessage("Assigned"),
        "assignedNotes":
            MessageLookupByLibrary.simpleMessage("Assigned Notes."),
        "assignedToHk": MessageLookupByLibrary.simpleMessage("Assign To HK"),
        "attendanceInfo":
            MessageLookupByLibrary.simpleMessage("Attendance Info"),
        "aug": MessageLookupByLibrary.simpleMessage("Aug"),
        "availability": MessageLookupByLibrary.simpleMessage("Availability"),
        "available": MessageLookupByLibrary.simpleMessage("Available"),
        "availableRooms":
            MessageLookupByLibrary.simpleMessage("Available Rooms"),
        "availableroom": MessageLookupByLibrary.simpleMessage("Available Room"),
        "bank": MessageLookupByLibrary.simpleMessage("Bank Transfer"),
        "bedType": MessageLookupByLibrary.simpleMessage("Bed Type"),
        "calendar": MessageLookupByLibrary.simpleMessage("Calendar & Rooms"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cash": MessageLookupByLibrary.simpleMessage("Cash"),
        "checkIn": MessageLookupByLibrary.simpleMessage("Check-In"),
        "checkInDate": MessageLookupByLibrary.simpleMessage("Check-In Date"),
        "checkInLabel": MessageLookupByLibrary.simpleMessage("Check-In Date"),
        "checkInOut": MessageLookupByLibrary.simpleMessage("Check-In/Out"),
        "checkInTime": m0,
        "checkOut": MessageLookupByLibrary.simpleMessage("Check-Out"),
        "checkOutDate": MessageLookupByLibrary.simpleMessage("Check-Out Date"),
        "checkOutLabel": MessageLookupByLibrary.simpleMessage("Check-Out Date"),
        "checkOutTime": m1,
        "checkedIn": MessageLookupByLibrary.simpleMessage("Checked In"),
        "checkedOut": MessageLookupByLibrary.simpleMessage("Checked Out"),
        "clean": MessageLookupByLibrary.simpleMessage("Clean"),
        "cleaningStatus":
            MessageLookupByLibrary.simpleMessage("Cleaning Status"),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "createAccount":
            MessageLookupByLibrary.simpleMessage("Create Your Account"),
        "createReservation":
            MessageLookupByLibrary.simpleMessage("Create Reservation"),
        "creationDate": MessageLookupByLibrary.simpleMessage("Creation Date"),
        "currentGuest": MessageLookupByLibrary.simpleMessage("Current Guest"),
        "daily": MessageLookupByLibrary.simpleMessage("Daily"),
        "dailyGuestRequests":
            MessageLookupByLibrary.simpleMessage("Daily Guest Requests"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "day": MessageLookupByLibrary.simpleMessage("day"),
        "days": MessageLookupByLibrary.simpleMessage("Days"),
        "dec": MessageLookupByLibrary.simpleMessage("Dec"),
        "dirty": MessageLookupByLibrary.simpleMessage("Dirty"),
        "dontHaveAnAccount":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account?"),
        "double": MessageLookupByLibrary.simpleMessage("Double"),
        "editRate": MessageLookupByLibrary.simpleMessage("Edit Rate"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("Enter your email"),
        "enterGuestName":
            MessageLookupByLibrary.simpleMessage("Please Enter Guest Name"),
        "enterNumOfAdults": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid number of adults"),
        "enterNumOfChildren": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid number of children"),
        "enterRequestDetails":
            MessageLookupByLibrary.simpleMessage("Enter Request Details"),
        "error": m2,
        "errorFetchingData": m3,
        "errorLoadingData":
            MessageLookupByLibrary.simpleMessage("Error loading data"),
        "errorLoadingPage":
            MessageLookupByLibrary.simpleMessage("Error loading page"),
        "errorMessage": MessageLookupByLibrary.simpleMessage(
            "An error occurred, please try again."),
        "facilities": MessageLookupByLibrary.simpleMessage("Facilities:"),
        "failedResetEmail": m4,
        "feb": MessageLookupByLibrary.simpleMessage("Feb"),
        "fieldRequired": m5,
        "filterByStatus":
            MessageLookupByLibrary.simpleMessage("Filter by Status"),
        "floor": MessageLookupByLibrary.simpleMessage("Floor"),
        "floorStatus": MessageLookupByLibrary.simpleMessage("Floor Status"),
        "frequency": MessageLookupByLibrary.simpleMessage("Frequency"),
        "fridge": MessageLookupByLibrary.simpleMessage("Fridge"),
        "frontDesk": MessageLookupByLibrary.simpleMessage("Front Desk"),
        "frontDeskRequests":
            MessageLookupByLibrary.simpleMessage("FrontDesk Requests"),
        "guestAddress": MessageLookupByLibrary.simpleMessage("Guest Address"),
        "guestManagement":
            MessageLookupByLibrary.simpleMessage("Guest Management"),
        "guestName": MessageLookupByLibrary.simpleMessage("Guest Name"),
        "guestNameLabel": MessageLookupByLibrary.simpleMessage("Guest Name"),
        "guestRequest": MessageLookupByLibrary.simpleMessage("Guest Request"),
        "guestRequests": MessageLookupByLibrary.simpleMessage("Guest Requests"),
        "guestdetails": MessageLookupByLibrary.simpleMessage("Guest Details"),
        "guests": MessageLookupByLibrary.simpleMessage("Guests"),
        "hKattendancehis":
            MessageLookupByLibrary.simpleMessage("HK Attendance His.."),
        "hello": m6,
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("Elite Hotel"),
        "hotelIcon": MessageLookupByLibrary.simpleMessage("Hotel Icon"),
        "housekeeping": MessageLookupByLibrary.simpleMessage("Housekeeping"),
        "inProgress": MessageLookupByLibrary.simpleMessage("In Progress"),
        "instapay": MessageLookupByLibrary.simpleMessage("Instapay"),
        "invoices": MessageLookupByLibrary.simpleMessage("Invoices"),
        "invoicesDetails":
            MessageLookupByLibrary.simpleMessage("Invoice Details"),
        "invoicesNumber":
            MessageLookupByLibrary.simpleMessage("Invoice Number"),
        "item": MessageLookupByLibrary.simpleMessage("Item"),
        "jan": MessageLookupByLibrary.simpleMessage("Jan"),
        "job": MessageLookupByLibrary.simpleMessage("Job"),
        "jul": MessageLookupByLibrary.simpleMessage("Jul"),
        "jun": MessageLookupByLibrary.simpleMessage("Jun"),
        "justOnce": MessageLookupByLibrary.simpleMessage("Just Once"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "location": MessageLookupByLibrary.simpleMessage("Location:"),
        "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
            "Location services are disabled."),
        "locationServicesNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Location services are not available on this platform."),
        "logIn": MessageLookupByLibrary.simpleMessage("Log in"),
        "logInToYourAccount":
            MessageLookupByLibrary.simpleMessage("Log In to Your Account"),
        "loggedInSuccessfully":
            MessageLookupByLibrary.simpleMessage("Logged in successfully!"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginPrompt":
            MessageLookupByLibrary.simpleMessage("Please login to continue"),
        "loginScreenTitle": MessageLookupByLibrary.simpleMessage("Login"),
        "logintoaccount":
            MessageLookupByLibrary.simpleMessage(" Log In to Your Account"),
        "logoutButton": MessageLookupByLibrary.simpleMessage("Logout"),
        "mainDashboard": MessageLookupByLibrary.simpleMessage("Main Dashboard"),
        "mar": MessageLookupByLibrary.simpleMessage("Mar"),
        "may": MessageLookupByLibrary.simpleMessage("May"),
        "menuTitle": MessageLookupByLibrary.simpleMessage("Menu"),
        "miniSuite": MessageLookupByLibrary.simpleMessage("Mini Suite"),
        "minibar": MessageLookupByLibrary.simpleMessage("Mini-bar"),
        "mobileNumber": MessageLookupByLibrary.simpleMessage("Mobile Number"),
        "monthlypaymentmethods":
            MessageLookupByLibrary.simpleMessage("Month\'s Payment Methods"),
        "monthreservations":
            MessageLookupByLibrary.simpleMessage("Month\'s Reservations:"),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nationalId": MessageLookupByLibrary.simpleMessage("National ID"),
        "nationality": MessageLookupByLibrary.simpleMessage("Nationality"),
        "newUser": MessageLookupByLibrary.simpleMessage("New User"),
        "nightPrice": MessageLookupByLibrary.simpleMessage("Night Price"),
        "nights": MessageLookupByLibrary.simpleMessage("Nights"),
        "noAccess": MessageLookupByLibrary.simpleMessage(
            "You do not have access to this page"),
        "noAvailablerooms": MessageLookupByLibrary.simpleMessage(
            "No available rooms of this type"),
        "noGuestsFound":
            MessageLookupByLibrary.simpleMessage("No guests found."),
        "noRatesAvailable":
            MessageLookupByLibrary.simpleMessage("No rates available."),
        "noRequestsForToday":
            MessageLookupByLibrary.simpleMessage("No requests for today"),
        "noRoomsNeedCleaning":
            MessageLookupByLibrary.simpleMessage("No rooms need cleaning!"),
        "noassignednotes":
            MessageLookupByLibrary.simpleMessage("No assigned notes."),
        "nofrontdeskrequests":
            MessageLookupByLibrary.simpleMessage("There is No RequestS"),
        "noteFrequency":
            MessageLookupByLibrary.simpleMessage("Select Note Frequency"),
        "notes": MessageLookupByLibrary.simpleMessage(
            "Notes (e.g., breakfast request)"),
        "notesBreakfast": MessageLookupByLibrary.simpleMessage(
            "Notes (e.g., breakfast request)"),
        "nov": MessageLookupByLibrary.simpleMessage("Nov"),
        "numberOfAdults":
            MessageLookupByLibrary.simpleMessage("Number of Adults"),
        "numberOfChildren":
            MessageLookupByLibrary.simpleMessage("Number of Children"),
        "occupancyStatistics":
            MessageLookupByLibrary.simpleMessage("Occupancy Statistics"),
        "occupied": MessageLookupByLibrary.simpleMessage("Occupied"),
        "occupiedRooms": MessageLookupByLibrary.simpleMessage("Occupied Rooms"),
        "oct": MessageLookupByLibrary.simpleMessage("Oct"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "overview": MessageLookupByLibrary.simpleMessage("Overview"),
        "package": MessageLookupByLibrary.simpleMessage("Package"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "paymenMethod": MessageLookupByLibrary.simpleMessage("Payment Method"),
        "paymentmethods":
            MessageLookupByLibrary.simpleMessage("Payment Methods"),
        "pending": MessageLookupByLibrary.simpleMessage("Pending"),
        "pleaseCheckinDate": MessageLookupByLibrary.simpleMessage(
            "Please select a check-in date."),
        "pleaseCheckoutDate": MessageLookupByLibrary.simpleMessage(
            "Please select a check-out date."),
        "pleaseCheckoutDateafter": MessageLookupByLibrary.simpleMessage(
            "Check-out date must be after check-in date."),
        "pleaseamountpaid": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid amount paid."),
        "printInvoice": MessageLookupByLibrary.simpleMessage("Print Invoice"),
        "punchIn": MessageLookupByLibrary.simpleMessage("Punch In"),
        "punchOut": MessageLookupByLibrary.simpleMessage("Punch Out"),
        "qty": MessageLookupByLibrary.simpleMessage("Quantity"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rates": MessageLookupByLibrary.simpleMessage("Rates"),
        "ratesManagement":
            MessageLookupByLibrary.simpleMessage("Rates Management"),
        "remainingBalance": MessageLookupByLibrary.simpleMessage("Remaining"),
        "remainingBalanceLabel":
            MessageLookupByLibrary.simpleMessage("Remaining Balance"),
        "requests": MessageLookupByLibrary.simpleMessage("Requests"),
        "reservationDeletedSuccess": MessageLookupByLibrary.simpleMessage(
            "Reservation deleted successfully!"),
        "reservationDetails":
            MessageLookupByLibrary.simpleMessage("Reservation Details"),
        "reservationId": MessageLookupByLibrary.simpleMessage("Reservation ID"),
        "reservationSuccess": MessageLookupByLibrary.simpleMessage(
            "Reservation created successfully!"),
        "reservations": MessageLookupByLibrary.simpleMessage("Reservations"),
        "reservationsamount":
            MessageLookupByLibrary.simpleMessage("Reservations Amount"),
        "reservationslist":
            MessageLookupByLibrary.simpleMessage("Reservations List"),
        "resetLinkSent": MessageLookupByLibrary.simpleMessage(
            "Password reset link sent to your email."),
        "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
        "room": MessageLookupByLibrary.simpleMessage("Room"),
        "roomFloor": MessageLookupByLibrary.simpleMessage("Room Floor"),
        "roomManagement":
            MessageLookupByLibrary.simpleMessage("Room Management"),
        "roomNumber": MessageLookupByLibrary.simpleMessage("Room Number"),
        "roomStatus": MessageLookupByLibrary.simpleMessage("Room Status"),
        "roomType": MessageLookupByLibrary.simpleMessage("Room Type"),
        "rooms": MessageLookupByLibrary.simpleMessage("Rooms"),
        "savechanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
        "searchBy":
            MessageLookupByLibrary.simpleMessage("Search by name, ID, or room"),
        "searchByPackage":
            MessageLookupByLibrary.simpleMessage("Search by Package"),
        "searchPlaceholder": MessageLookupByLibrary.simpleMessage(
            "Search by room number, bed type, or floor"),
        "selectNoteFrequency":
            MessageLookupByLibrary.simpleMessage("Select Note Frequency"),
        "selectPackage": MessageLookupByLibrary.simpleMessage("Select Package"),
        "selectRoomType":
            MessageLookupByLibrary.simpleMessage("Please Select Room Type"),
        "selectYear": MessageLookupByLibrary.simpleMessage("Select Year"),
        "sendResetLink":
            MessageLookupByLibrary.simpleMessage("Send Reset Link"),
        "sep": MessageLookupByLibrary.simpleMessage("Sep"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "sideMenuDashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "sideMenuFrontDesk": MessageLookupByLibrary.simpleMessage("Front Desk"),
        "sideMenuGuests": MessageLookupByLibrary.simpleMessage("Guests"),
        "sideMenuHousekeeping":
            MessageLookupByLibrary.simpleMessage("Housekeeping"),
        "sideMenuRates": MessageLookupByLibrary.simpleMessage("Rates"),
        "sideMenuReservations":
            MessageLookupByLibrary.simpleMessage("Reservations"),
        "sideMenuRooms": MessageLookupByLibrary.simpleMessage("Rooms"),
        "sideMenuSettings": MessageLookupByLibrary.simpleMessage("Settings"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "signupButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "signupPrompt":
            MessageLookupByLibrary.simpleMessage("Create a new account"),
        "signupScreenTitle": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "single": MessageLookupByLibrary.simpleMessage("Single"),
        "slugan1":
            MessageLookupByLibrary.simpleMessage("Thank you for choosing us!"),
        "slugan2": MessageLookupByLibrary.simpleMessage(
            "Experience luxury at Elite Hotel - Where every moment matters."),
        "status": MessageLookupByLibrary.simpleMessage("Status"),
        "statusAll": MessageLookupByLibrary.simpleMessage("All"),
        "statusAvailable": MessageLookupByLibrary.simpleMessage("Available"),
        "statusClean": MessageLookupByLibrary.simpleMessage("Clean"),
        "statusDirty": MessageLookupByLibrary.simpleMessage("Dirty"),
        "statusMaintenance":
            MessageLookupByLibrary.simpleMessage("Maintenance"),
        "statusOccupied": MessageLookupByLibrary.simpleMessage("Occupied"),
        "suite": MessageLookupByLibrary.simpleMessage("Suite"),
        "todayreservations":
            MessageLookupByLibrary.simpleMessage("Today\'s Reservations:"),
        "todaysCheckIns":
            MessageLookupByLibrary.simpleMessage("Today\'s\nCheck-ins"),
        "todaysCheckInsMobile":
            MessageLookupByLibrary.simpleMessage("Today\'s Check-ins"),
        "todaysCheckOuts":
            MessageLookupByLibrary.simpleMessage("Today\'s\nCheck-outs"),
        "todaysCheckOutsMobile":
            MessageLookupByLibrary.simpleMessage("Today\'s Check-outs"),
        "todayspaymentmethods":
            MessageLookupByLibrary.simpleMessage("Today\'s Payment Methods"),
        "totalAmount": MessageLookupByLibrary.simpleMessage("Total Amount"),
        "totalAvailableRooms":
            MessageLookupByLibrary.simpleMessage("Total\nAvailable Rooms"),
        "totalAvailableRoomsMobile":
            MessageLookupByLibrary.simpleMessage("Total Available Rooms"),
        "totalCost": MessageLookupByLibrary.simpleMessage("Total Cost"),
        "totalCostLabel": MessageLookupByLibrary.simpleMessage("Total Cost"),
        "totalInHotel": MessageLookupByLibrary.simpleMessage("Total In\nHotel"),
        "totalInHotelMobile":
            MessageLookupByLibrary.simpleMessage("Total In Hotel"),
        "totalOccupiedRooms":
            MessageLookupByLibrary.simpleMessage("Total\nOccupied Rooms"),
        "totalOccupiedRoomsMobile":
            MessageLookupByLibrary.simpleMessage("Total Occupied Rooms"),
        "totalnights": MessageLookupByLibrary.simpleMessage("Total Nights"),
        "tv": MessageLookupByLibrary.simpleMessage("TV"),
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "upcoming": MessageLookupByLibrary.simpleMessage("Upcoming"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "userAccounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "userAdded":
            MessageLookupByLibrary.simpleMessage("User Added Successfully"),
        "userRoleAdmin": MessageLookupByLibrary.simpleMessage("Admin"),
        "userRoleFrontDesk": MessageLookupByLibrary.simpleMessage("Front Desk"),
        "userRoleHKStaff":
            MessageLookupByLibrary.simpleMessage("Housekeeping Staff"),
        "userRoleManager": MessageLookupByLibrary.simpleMessage("Manager"),
        "useraccounts": MessageLookupByLibrary.simpleMessage("User Accounts"),
        "visa": MessageLookupByLibrary.simpleMessage("Visa"),
        "welcomeBack": MessageLookupByLibrary.simpleMessage(
            "Welcome Back to Elite Hospitality"),
        "welcomehosibility": MessageLookupByLibrary.simpleMessage(
            "Welcome to Elite Hospitality"),
        "wifi": MessageLookupByLibrary.simpleMessage("WiFi"),
        "workingHours": MessageLookupByLibrary.simpleMessage("Working Hours"),
        "workingHoursFormat": m7,
        "youHaveAlreadyCheckedIn": MessageLookupByLibrary.simpleMessage(
            "You have already checked in today."),
        "youMustCheckInBeforeCheckingOut": MessageLookupByLibrary.simpleMessage(
            "You must check in before checking out.")
      };
}
