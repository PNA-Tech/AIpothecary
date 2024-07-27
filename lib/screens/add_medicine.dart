import 'package:flutter/material.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  _AddMedicineState createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _frequencyController = TextEditingController();
  final List<Map<String, String>> _medicines = [];

  void _addMedicine() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _medicines.add({
          'name': _medicineNameController.text,
          'frequency': _frequencyController.text,
        });
        _medicineNameController.clear();
        _frequencyController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Colors.cyanAccent[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_medicines.isNotEmpty)
              Column(
                children: _medicines.map((medicine) {
                  return Card(
                    child: ListTile(
                      title: Text(medicine['name'] ?? ''),
                      subtitle: Text(medicine['frequency'] ?? ''),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _medicineNameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _frequencyController,
                    decoration: const InputDecoration(
                      labelText: 'How often (e.g., 3 times per day)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter how often you take the medicine';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addMedicine,
                    child: const Text('Add Medicine Reminder'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          

        },
        backgroundColor: Colors.cyanAccent[200],
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
