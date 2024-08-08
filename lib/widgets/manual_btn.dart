import 'package:flutter/material.dart';

class ManualAddButton extends StatelessWidget {
  final Function(String name, String frequency) onAdd;

  const ManualAddButton({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: FloatingActionButton(
        onPressed: () {
          _showAddMedicineDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final medicineNameController = TextEditingController();
    final frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medicine'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: medicineNameController,
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
                  controller: frequencyController,
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
                if (formKey.currentState!.validate()) {
                  onAdd(
                    medicineNameController.text,
                    frequencyController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
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
}
