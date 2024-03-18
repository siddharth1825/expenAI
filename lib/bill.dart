import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BillScreen extends StatefulWidget {
  final Map<String, dynamic>? data; // Make data optional

  const BillScreen({Key? key, this.data}) : super(key: key); // Adjust constructor

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<Widget> _billCards = [];
  final DatabaseReference _billsRef = FirebaseDatabase.instance.ref().child('userBills');

  @override
  void initState() {
    super.initState();
    // Only save and fetch bills if data is provided
    if (widget.data != null) {
      _saveBillToFirebase(widget.data!).then((_) {
        // After saving, fetch the bills
        _fetchBills();
      });
    } else {
      // If no data is provided, just fetch the existing bills
      _fetchBills();
    }
  }

  Future<void> _saveBillToFirebase(Map<String, dynamic> billData) async {
    final snapshot = await _billsRef.get();
    int nextBillNumber = snapshot.children.length + 1;

    String billKey = 'bill$nextBillNumber';
    await _billsRef.child(billKey).set(billData);
  }

  Future<void> _fetchBills() async {
    DataSnapshot snapshot = await _billsRef.get();

    if (snapshot.exists) {
      List<Widget> billCards = [];
      Map<dynamic, dynamic> billsMap = snapshot.value as Map<dynamic, dynamic>;
      billsMap.forEach((key, value) {
        billCards.add(Card(
          color: Color(0xFFDCD4C5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Category: ${value['category']}',style: TextStyle(color: Color(0xFF292015))),
                Text('Amount: ${value['amount']}',style: TextStyle(color: Color(0xFF292015))),
              ],
            ),
          ),
        ));
      });

      setState(() {
        _billCards = billCards;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC7B6A1),
      appBar: AppBar(
        backgroundColor: Color(0xFFC7B6A1),
        title: Text('Bills'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _billCards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.count(
              crossAxisCount: 2,
              children: _billCards,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
            ),
    );
  }
}
