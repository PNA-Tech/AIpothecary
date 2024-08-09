import 'package:flutter/material.dart';
import 'package:healthassistant/widgets/manual_btn.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  _AddMedicineState createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final List<Map<String, dynamic>> _medicines = [];
  int? _editingIndex;

  void _addMedicine(
      String name, String frequency, List<String> times, List<String> days) {
    setState(() {
      if (_editingIndex == null) {
        _medicines.add({
          'name': name,
          'frequency': frequency,
          'times': times,
          'days': days,
        });
      } else {
        _medicines[_editingIndex!] = {
          'name': name,
          'frequency': frequency,
          'times': times,
          'days': days,
        };
        _editingIndex = null;
      }
    });
  }

  void _editMedicine(int index) {
    setState(() {
      _editingIndex = index;
    });
    final medicine = _medicines[index];
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: medicine['name']);
    final frequencyController =
        TextEditingController(text: medicine['frequency']);
    final timesControllers = List.generate(
        4, (i) => TextEditingController(text: medicine['times'][i]));
    final days = List<String>.from(medicine['days']);
    bool isMoreThanOncePerDay =
        frequencyController.text == 'More than once per day';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Medicine'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter the medicine name'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: frequencyController.text.isNotEmpty
                            ? frequencyController.text
                            : null,
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
                        onChanged: (value) {
                          setState(() {
                            frequencyController.text = value!;
                            isMoreThanOncePerDay =
                                value == 'More than once per day';
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select how often you take the medicine'
                            : null,
                      ),
                      if (isMoreThanOncePerDay) ...[
                        const SizedBox(height: 20),
                        const Text('Specify up to 4 times:'),
                        for (int i = 0; i < 4; i++)
                          TextFormField(
                            controller: timesControllers[i],
                            decoration: InputDecoration(
                              labelText: 'Time ${i + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.none,
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  timesControllers[i].text =
                                      selectedTime.format(context);
                                }
                              });
                            },
                            validator: (value) {
                              if (i == 0 && (value == null || value.isEmpty)) {
                                return 'Please select at least one time';
                              }
                              return null;
                            },
                          ),
                      ],
                      if (!isMoreThanOncePerDay) ...[
                        const SizedBox(height: 20),
                        const Text('Select days of the week:'),
                        ...[
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',
                          'Sunday'
                        ].map((day) {
                          return CheckboxListTile(
                            title: Text(day),
                            value: days.contains(day),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  days.add(day);
                                } else {
                                  days.remove(day);
                                }
                              });
                            },
                          );
                        }).toList(),
                        TextFormField(
                          controller: timesControllers[0],
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.none,
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((selectedTime) {
                              if (selectedTime != null) {
                                timesControllers[0].text =
                                    selectedTime.format(context);
                              }
                            });
                          },
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return 'Please select at least one time';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _addMedicine(
                        nameController.text,
                        frequencyController.text,
                        timesControllers.map((c) => c.text).toList(),
                        days,
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
                      var value = medicine['frequency'];
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
                            title: Text(medicine['name']),
                            subtitle: Text(
                              '${medicine['frequency']}, Times: '
                                '${(value == 'Once, multiple days a week') ? (medicine['times'][0]) : (medicine['times'] as List<String>).where((time) => time.isNotEmpty).join(', ')}, '
                                '${(value == 'Once, multiple days a week') ? (medicine['days'] as List<String>).join(', ') : ''}',
                            ),
                            
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
            onAdd: (name, frequency, times, days) {
              _addMedicine(name, frequency, times, days);
            },
          ),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
    );
  }
}
