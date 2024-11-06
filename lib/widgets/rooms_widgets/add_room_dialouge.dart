import 'package:flutter/material.dart';


class AddRoomDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onRoomAdded;

  AddRoomDialog({required this.onRoomAdded});

  @override
  _AddRoomDialogState createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final TextEditingController _roomNumberController = TextEditingController();
  String _bedType = 'Single';
  String _roomType = 'Room';
  String _cleaningStatus = 'Clean';
  int _roomFloor = 1; // Default floor
  Map<String, bool> _selectedFacilities = {
    'WiFi': false,
    'TV': false,
    'Mini-bar': false,
    'AC': false,
    'Fridge': false,
  };

  void _submit(BuildContext context) {
    final room = {
      'roomNumber': _roomNumberController.text,
      'roomFloor': _roomFloor,
      'bedType': _bedType,
      'roomType' : _roomType,
      'status': 'Available', // Default status
      'cleaningStatus': _cleaningStatus,
      'roomFacility': _selectedFacilities,
      'currentGuest': null, // Default to null, can be updated later
    };
    widget.onRoomAdded(room);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Room'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _roomNumberController,
              decoration: const InputDecoration(labelText: 'Room Number'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _bedType,
              items: ['Single', 'Double', 'Suite'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _bedType = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Bed Type'),
            ),
            DropdownButtonFormField<String>(
              value: _roomType,
              items: ['Room', 'Mini Suite', 'Suite'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _roomType = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Room Type'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _roomFloor,
              items: [1, 2].map((floor) {
                return DropdownMenuItem(
                  value: floor,
                  child: Text(floor.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _roomFloor = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Floor'),
            ),
            const SizedBox(height: 10),
            const Text('Facilities:'),
            Column(
              children: _selectedFacilities.keys.map((facility) {
                return CheckboxListTile(
                  title: Text(facility),
                  value: _selectedFacilities[facility],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedFacilities[facility] = value!;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _cleaningStatus,
              items: ['Clean', 'Dirty'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _cleaningStatus = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Cleaning Status'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _submit(context),
          child: const Text('Add Room'),
        ),
      ],
    );
  }
}
