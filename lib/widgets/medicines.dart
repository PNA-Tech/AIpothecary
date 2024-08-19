import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class MedicinesWidget extends StatefulWidget {
  @override
  _MedicinesWidgetState createState() => _MedicinesWidgetState();
}

class _MedicinesWidgetState extends State<MedicinesWidget> {
  final PocketBase pb = PocketBase('https://region-generally.pockethost.io');
  List<RecordModel> _medicines = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicines(); // Fetch medicines on widget initialization
  }

  Future<void> _fetchMedicines() async {
    try {
      final records = await pb.collection('medicines').getFullList(sort: '-created');
      setState(() {
        _medicines = records;
      });
    } catch (e) {
      print("Error fetching medicines: $e");
    }
  }

  Future<void> _deleteMedicine(String recordId, int index) async {
    try {
      await pb.collection('medicines').delete(recordId);
      setState(() {
        _medicines.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted')),
      );
    } catch (e) {
      print("Error deleting medicine: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _medicines.isNotEmpty
            ? Column(
                children: List.generate(_medicines.length, (index) {
                  final medicine = _medicines[index];
                  
                  // Check for null values
                  var frequency = medicine.data['frequency'] ?? '';
                  var times = (medicine.data['times'] as List<dynamic>?)?.where((time) => time != null && time.isNotEmpty).toList() ?? [];
                  var days = (medicine.data['days'] as List<dynamic>?)?.where((day) => day != null && day.isNotEmpty).toList() ?? [];

                  return Dismissible(
                    key: Key(medicine.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.red,
                      ),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => _deleteMedicine(medicine.id, index),
                    child: Card(
                      child: ListTile(
                        title: Text(medicine.data['name'] ?? 'Unknown Medicine'),
                        subtitle: Text(
                          '$frequency, Times: ${times.join(', ')}, Days: ${days.join(', ')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  );
                }),
              )
            : const Text('Add some medicines by using the buttons below.'),
        const SizedBox(height: 20),
      ],
    );
  }
}
