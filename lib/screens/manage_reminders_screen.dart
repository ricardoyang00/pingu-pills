import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../database/local_medicament_stock.dart';
import '../model/medicaments.dart';
import '../model/reminders.dart';
import 'add_reminder_screen.dart';

class ManageRemindersScreen extends StatefulWidget {
  Future<List<Medicament>> medicamentList;
  final VoidCallback onReminderSaved;
  final VoidCallback onMedicamentListUpdated;

  ManageRemindersScreen({
    super.key,
    required this.onReminderSaved,
    required this.medicamentList,
    required this.onMedicamentListUpdated,
  });

  @override
  _ManageRemindersScreenState createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  List<Reminder> reminders = [];
  List<Medicament> medicaments = [];

  @override
  void initState() {
    super.initState();
    fetchReminders();
    fetchMedicaments();
  }

  fetchReminders() async {
    reminders = await ReminderDatabase().getReminders();
    setState(() {});
  }

  fetchMedicaments() async {
    medicaments = await MedicamentStock().getMedicaments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      appBar: AppBar(
        title: reminders.isEmpty ?  const Text('Manage Reminders') : Text('Manage Reminders (${reminders.length})'),
        backgroundColor: Colors.transparent,
      ),
      body: reminders.isEmpty
        ? SizedBox(
            height: 150,
            child: Card(
              color: const Color.fromRGBO(255, 218, 190, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: const Center(
                child: Text(
                  'No reminders scheduled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(225, 95, 0, 1),
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
        : ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              Reminder reminder = reminders[index];
              Medicament medicament = medicaments.firstWhere((
                  medicament) => medicament.id == reminder.medicament);
              String formattedStartDate = DateFormat('yyyy/MM/dd').format(reminder.startDate);
              String formattedEndDate = DateFormat('yyyy/MM/dd').format(reminder.endDate);
              return Card(
                color: const Color.fromRGBO(255, 95, 0, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: '${medicament.name} ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              TextSpan(
                                text: '($formattedStartDate - $formattedEndDate)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(239, 203, 187, 1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        ),
                      ),
                      child: ListTile(
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'Intake Quantity: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(225, 95, 0, 1),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${reminder.intakeQuantity} piece(s)',
                                    style: const TextStyle(
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'Times: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(225, 95, 0, 1),
                                    ),
                                  ),
                                  TextSpan(
                                    text: reminder.times.map((time) => time.format(context)).join(', '),
                                    style: const TextStyle(
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'Frequency: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(225, 95, 0, 1),
                                    ),
                                  ),
                                  TextSpan(
                                    text: getFrequencyText(reminder.selectedDays),
                                    style: const TextStyle(
                                        color: Colors.black
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'Message: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(225, 95, 0, 1),
                                    ),
                                  ),
                                  TextSpan(
                                    text: reminder.reminderName.isEmpty ? 'It\'s time to take your medicament!' : reminder.reminderName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.pen,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddReminderPage(
                                      onReminderSaved: widget.onReminderSaved,
                                      medicamentList: widget.medicamentList,
                                      onMedicamentListUpdated: widget.onMedicamentListUpdated,
                                      isEditing: true,
                                      editingReminder: reminder,
                                      reminderMedicament: medicament,
                                    ),
                                  ),
                                ).then((value) {
                                  fetchReminders();
                                  fetchMedicaments();
                                  if (value == true) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Reminder Updated'),
                                          content: const Text('Updates will take effect from the start of the next day'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(215, 74, 0, 1),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.trash,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm'),
                                      content: Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Are you sure you want to delete ',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: medicament.name,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ' reminder?',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color.fromRGBO(100, 50, 13 ,1),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                          onPressed: () async {
                                            await ReminderDatabase().deleteReminderByReminderId(reminder.id);
                                            setState(() {
                                              reminders.removeAt(index);
                                            });
                                            Navigator.of(context).pop();
                                            widget.onReminderSaved();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  static String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return '';
    }
  }

  String getFrequencyText(List<bool> selectedDays) {
    if (selectedDays.every((day) => day)) {
      return 'Everyday';
    } else {
      return selectedDays.asMap().entries.where((entry) => entry.value).map((entry) => _getDayName(entry.key)).join(', ');
    }
  }
}