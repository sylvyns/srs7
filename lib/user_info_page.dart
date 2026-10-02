import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String _name = '';
  String _phone = '';
  String _email = '';

  // initState вызывается один раз
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Читаем сохранённые данные из SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _email = prefs.getString('email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text(_name),
                subtitle: const Text('Full Name'),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(_phone),
                subtitle: const Text('Phone Number'),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: Text(_email),
                subtitle: const Text('Email Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
