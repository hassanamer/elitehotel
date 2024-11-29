import 'package:flutter/material.dart';

class InvoicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Invoices'),
      ),
      body: Center(
        child: Text(
          'Invoices will be displayed here.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
