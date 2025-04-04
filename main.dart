import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database.dart';
import 'sms_scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MessageSchedulerScreen(),
    );
  }
}

class MessageSchedulerScreen extends StatefulWidget {
  @override
  _MessageSchedulerScreenState createState() => _MessageSchedulerScreenState();
}

class _MessageSchedulerScreenState extends State<MessageSchedulerScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDateTime;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    await Permission.sms.request();
  }

  void _scheduleMessage() async {
    if (_phoneController.text.isNotEmpty &&
        _messageController.text.isNotEmpty &&
        _selectedDateTime != null) {
      await _dbHelper.insertMessage(
        _phoneController.text,
        _messageController.text,
        _selectedDateTime!.millisecondsSinceEpoch,
      );

      scheduleSms(_phoneController.text, _messageController.text, _selectedDateTime!);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message programmé !")));
      setState(() {
        _phoneController.clear();
        _messageController.clear();
      });
    }
  }

  void _selectDateTime() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Programmation de SMS")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Numéro de téléphone")),
            TextField(controller: _messageController, decoration: InputDecoration(labelText: "Message")),
            ElevatedButton(onPressed: _selectDateTime, child: Text("Choisir date et heure")),
            ElevatedButton(onPressed: _scheduleMessage, child: Text("Programmer SMS")),
          ],
        ),
      ),
    );
  }
}
