import 'package:flutter/material.dart';
import 'package:healthassistant/util/auth.dart';
import 'package:healthassistant/util/globals.dart';
import 'package:pocketbase/pocketbase.dart';


class ManualAddButton extends StatelessWidget {
  final pb = PocketBase('https://region-generally.pockethost.io/');
  final AuthService authService;
  final Function(
    String name,
    String frequency,
    List<String> times,
    List<String> days,
  ) onAdd;
  final String? userId; 

   ManualAddButton({
    super.key,
    required this.authService,
    required this.onAdd,
    this.userId,
  });

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

  void _showAddMedicineDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final medicineNameController = TextEditingController();
    final frequencyController =
        TextEditingController(text: 'Once, multiple days a week');
    final timesController =
        List.generate(4, (index) => TextEditingController());
    final Set<String> daysController = <String>{};
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
                        value: frequencyController.text,
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
                      ),
                      if (isMoreThanOncePerDay) ...[
                        const SizedBox(height: 20),
                        const Text('Specify up to 4 times:'),
                        for (int i = 0; i < 4; i++)
                          TextFormField(
                            controller: timesController[i],
                            decoration: InputDecoration(
                              labelText: 'Time ${i + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.datetime,
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  timesController[i].text =
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
                        TextFormField(
                          controller: timesController[0],
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((selectedTime) {
                              if (selectedTime != null) {
                                timesController[0].text =
                                    selectedTime.format(context);
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (daysController.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'The medicine was not added. Please select at least one day of the week.',
                            ),
                          ),
                        );
                      } else {
                        try {
                          print(globalUserId);
                          final body = <String, dynamic>{
                            "name": medicineNameController.text,
                            "frequency": frequencyController.text,
                            "time_of_day":
                                timesController.map((c) => c.text).toList(),
                            "days_of_week": List<String>.from(daysController),
                            "userId": globalUserId, 
                          };

                          final record = await pb
                              .collection('medicines')
                              .create(body: body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Medicine added successfully.'),
                            ),
                          );
                          onAdd(
                            medicineNameController.text,
                            frequencyController.text,
                            timesController.map((c) => c.text).toList(),
                            List<String>.from(daysController),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add medicine: $e'),
                            ),
                          );
                        }
                      }
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
