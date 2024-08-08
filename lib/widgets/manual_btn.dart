import 'package:flutter/material.dart';

class ManualAddButton extends StatelessWidget {
  final Function(String name, String frequency, List<String> times, List<String> days) onAdd;

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
    final frequencyController = TextEditingController(text: 'Once per day');
    final timesController = List.generate(4, (index) => TextEditingController());
    final daysController = <String>{};
    bool isMoreThanOncePerDay = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Medicine'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter the medicine name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: isMoreThanOncePerDay ? 'More than once per day' : 'Once, multiple days a week',
                        decoration: const InputDecoration(
                          labelText: 'How often',
                          border: OutlineInputBorder(),
                        ),
                        items: <String>[
                          'More than once per day',
                          'Once, multiple days a week',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select how often you take the medicine';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            frequencyController.text = value!;
                            isMoreThanOncePerDay = value == 'More than once per day';
                          });
                        },
                      ),
                      if (isMoreThanOncePerDay) ...[
                        const SizedBox(height: 20),
                        Text('Specify up to 4 times:'),
                        for (int i = 0; i < 4; i++)
                          TextFormField(
                            controller: timesController[i],
                            decoration: InputDecoration(
                              labelText: 'Time ${i + 1}',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                      ],
                      if (frequencyController.text == 'Once, multiple days a week') ...[
                        const SizedBox(height: 20),
                        Text('Select days of the week:'),
                        ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                          return CheckboxListTile(
                            title: Text(day),
                            value: daysController.contains(day),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  daysController.add(day);
                                } else {
                                  daysController.remove(day);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onAdd(
                        medicineNameController.text,
                        frequencyController.text,
                        timesController.map((c) => c.text).toList(),
                        daysController.toList(),
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
      },
    );
  }
}
