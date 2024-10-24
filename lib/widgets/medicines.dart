import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MedicinesWidget extends StatefulWidget {
  @override
  _MedicinesWidgetState createState() => _MedicinesWidgetState();
}

class _MedicinesWidgetState extends State<MedicinesWidget> {
  final PocketBase pb = PocketBase('https://region-generally.pockethost.io');
  List<RecordModel> _medicines = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Set up notifications
    _fetchMedicines(); // Fetch medicines on widget initialization
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone data
    tz.initializeTimeZones();
  }

  Future<void> _scheduleNotification(String medicineName, String time) async {
    var timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(' ')[0]);
    String period = timeParts[1].split(' ')[1];

    // Convert to 24-hour format
    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    final now = DateTime.now();
    final scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Time to take your medicine',
      'Please take your $medicineName',
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id', // Channel ID
          'your_channel_name', // Channel Name
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily notifications
    );
  }

  Future<void> _fetchMedicines() async {
    try {
      final records =
          await pb.collection('medicines').getFullList(sort: '-created');
      setState(() {
        _medicines = records;
      });
    } catch (e) {
      print("Error fetching medicines: $e");
    }
  }

  Future<void> _editMedicine(
      BuildContext context, String recordId, RecordModel medicineRecord) async {
    final formKey = GlobalKey<FormState>();
    final medicineNameController =
        TextEditingController(text: medicineRecord.data['name']);
    final frequencyController =
        TextEditingController(text: medicineRecord.data['frequency']);
    final timesController = List<TextEditingController>.from(
      (medicineRecord.data['time_of_day'] as List<dynamic>)
          .map((time) => TextEditingController(text: time)),
    );
    final Set<String> daysController =
        Set<String>.from(medicineRecord.data['days_of_week'] as List<dynamic>);
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
                            controller: i < timesController.length
                                ? timesController[i]
                                : TextEditingController(),
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
                          controller: timesController.isNotEmpty
                              ? timesController[0]
                              : TextEditingController(),
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
                      if (daysController.isEmpty &&
                          frequencyController.text ==
                              'Once, multiple days a week') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select at least one day of the week.')),
                        );
                      } else {
                        try {
                          final body = <String, dynamic>{
                            "name": medicineNameController.text,
                            "frequency": frequencyController.text,
                            "time_of_day":
                                timesController.map((c) => c.text).toList(),
                            "days_of_week": List<String>.from(daysController),
                          };

                          await pb
                              .collection('medicines')
                              .update(recordId, body: body);

                          // Schedule notification for the medicine
                          for (final timeController in timesController) {
                            if (timeController.text.isNotEmpty) {
                              await _scheduleNotification(
                                  medicineNameController.text,
                                  timeController.text);
                            }
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Medicine updated successfully.')),
                          );
                          Navigator.of(context).pop(); // Close the dialog
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to update medicine: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Update'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
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
        if (_medicines.isNotEmpty)
          Column(
            children: List.generate(_medicines.length, (index) {
              final medicine = _medicines[index];
              var frequency = medicine.data['frequency'] ?? '';
              var times = (medicine.data['time_of_day'] as List<dynamic>?)
                      ?.where((time) => time != null && time.isNotEmpty)
                      .toList() ??
                  [];
              var days = frequency == 'Once, multiple days a week'
                  ? (medicine.data['days_of_week'] as List<dynamic>?)
                          ?.where((day) => day != null && day.isNotEmpty)
                          .toList() ??
                      []
                  : ["Everyday"];

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
                      '$frequency, Times: ${times.join(', ')}, ${days.join(', ')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editMedicine(context, medicine.id, medicine);
                      },
                    ),
                  ),
                ),
              );
            }),
          )
        else
          const Text('Add some medicines by using the buttons below.'),
        const SizedBox(height: 20),
      ],
    );
  }
}
