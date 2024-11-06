class RoomData {
  static final RoomData _instance = RoomData._internal();
  factory RoomData() => _instance;

  RoomData._internal();

  final List<Map<String, String>> rooms = [
    {'roomNumber': '#001', 'bedType': 'Double bed', 'roomFloor': 'Floor -1', 'roomFacility': 'AC, shower, Double bed, towel, bathtub, TV', 'status': 'Available'},
    {'roomNumber': '#002', 'bedType': 'Single bed', 'roomFloor': 'Floor -2', 'roomFacility': 'AC, shower, towel, bathtub, TV', 'status': 'Booked'},
    {'roomNumber': '#003', 'bedType': 'VIP', 'roomFloor': 'Floor -1', 'roomFacility': 'AC, shower, Double bed, towel, bathtub, TV', 'status': 'Booked'},
    {'roomNumber': '#004', 'bedType': 'VIP', 'roomFloor': 'Floor -1', 'roomFacility': 'AC, shower, Double bed, towel, bathtub, TV', 'status': 'Reserved'},
    {'roomNumber': '#005', 'bedType': 'Single bed', 'roomFloor': 'Floor -1', 'roomFacility': 'AC, shower, towel, bathtub, TV', 'status': 'Reserved'},
    {'roomNumber': '#006', 'bedType': 'Double bed', 'roomFloor': 'Floor -2', 'roomFacility': 'AC, shower, Double bed, towel, bathtub, TV', 'status': 'Waiting'},
    {'roomNumber': '#007', 'bedType': 'Double bed', 'roomFloor': 'Floor -3', 'roomFacility': 'AC, shower, towel, bathtub, TV', 'status': 'Available'},
    {'roomNumber': '#008', 'bedType': 'Single bed', 'roomFloor': 'Floor -5', 'roomFacility': 'AC, shower, towel, bathtub, TV', 'status': 'Booked'},
  ];
}
