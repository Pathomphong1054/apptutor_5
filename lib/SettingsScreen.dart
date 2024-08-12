import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 28, 195, 198),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock, color: Colors.blueAccent),
            title: Text('Change Password', style: TextStyle(fontSize: 18)),
            onTap: () {
              // Implement change password functionality
            },
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.blueAccent),
            title: Text('Change Language', style: TextStyle(fontSize: 18)),
            onTap: () {
              // Implement change language functionality
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode', style: TextStyle(fontSize: 18)),
            secondary: Icon(Icons.brightness_6, color: Colors.blueAccent),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                // Implement dark mode functionality
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blueAccent),
            title: Text('About', style: TextStyle(fontSize: 18)),
            onTap: () {
              // Implement about functionality
            },
          ),
        ],
      ),
    );
  }
}
