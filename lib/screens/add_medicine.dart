import 'package:flutter/material.dart';
import 'package:healthassistant/widgets/manual_btn.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  _AddMedicineState createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final _medicineNameController = TextEditingController();
  final _frequencyController = TextEditingController();
  final List<Map<String, String>> _medicines = [];
  int? _editingIndex;
  final _formKey = GlobalKey<FormState>();

  void _addMedicine(String name, String frequency) {
    setState(() {
      if (_editingIndex == null) {
        _medicines.add({
          'name': name,
          'frequency': frequency,
        });
      } else {
        _medicines[_editingIndex!] = {
          'name': name,
          'frequency': frequency,
        };
        _editingIndex = null;
      }
    });
    // Clear the text fields only if we're adding a new medicine
    if (_editingIndex == null) {
      _medicineNameController.clear();
      _frequencyController.clear();
    }
  }

  void _editMedicine(int index) {
    final medicine = _medicines[index];
    _medicineNameController.text = medicine['name'] ?? '';
    _frequencyController.text = medicine['frequency'] ?? '';
    setState(() {
      _editingIndex = index;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Medicine'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _addMedicine(
                    _medicineNameController.text,
                    _frequencyController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Colors.purple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            (_medicines.isNotEmpty)
                ? Column(
                    children: List.generate(_medicines.length, (index) {
                      final medicine = _medicines[index];
                      return Dismissible(
                        key: Key(index.toString()),
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
                        onDismissed: (direction) {
                          setState(() {
                            _medicines.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Medicine deleted'),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(medicine['name'] ?? ''),
                            subtitle: Text(medicine['frequency'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editMedicine(index),
                            ),
                          ),
                        ),
                      );
                    }),
                  )
                : const Text('Add some medicines by using the buttons below.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_medicine');
              },
              icon: const Icon(Icons.medication),
              color: Colors.purple,
              
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ManualAddButton(
              onAdd: (name, frequency) {
                _addMedicine(name, frequency);
              },
            ),
            FloatingActionButton(
              onPressed: () {
                // Camera AI button action
              },
              child: const Icon(Icons.camera_alt_rounded),
            ),
          ],
        ),
      );
  }
}
