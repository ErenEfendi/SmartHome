import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DoorsScreen extends StatefulWidget {
  const DoorsScreen({super.key});

  @override
  State<DoorsScreen> createState() {
    return _DoorsScreenState();
  }
}

class _DoorsScreenState extends State<DoorsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref(
    "SmartHome/remoteControl/door",
  );
  Map<String, dynamic> _Doors = {};

  final Map<String, String> doorNames = {
    "garageDoor": "Garage Door",
    "mainDoor": "Main Door",
  };

  @override
  void initState() {
    super.initState();
    _fetchDoors();
  }

  void _fetchDoors() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _Doors = Map<String, dynamic>.from(event.snapshot.value as Map);
        });
      }
    });
  }

  void _toggleDoor(String doorKey, bool currentState) {
    _database.child(doorKey).set(!currentState);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doors Control"),
        backgroundColor:
            isDarkMode
                ? const Color(0xFF1F1F1F)
                : const Color.fromARGB(255, 38, 90, 133),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              Theme.of(context).brightness == Brightness.dark
                  ? null
                  : const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 104, 173, 230),
                      Color.fromARGB(255, 224, 232, 240),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF121212)
                  : null,
        ),
        child:
            _Doors.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _Doors.keys.length,
                  itemBuilder: (context, index) {
                    String key = _Doors.keys.elementAt(index);
                    bool isOn = _Doors[key];

                    return Card(
                      color:
                          isOn
                              ? isDarkMode
                                  ? const Color.fromARGB(255, 36, 59, 38)
                                  : Colors.green
                              : isDarkMode
                              ? Colors.grey.shade800
                              : const Color.fromARGB(255, 2, 37, 66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.garage,
                          color:
                              isOn
                                  ? Colors.white
                                  : isDarkMode
                                  ? Colors.white
                                  : Colors.grey[500],
                        ),
                        title: Text(
                          doorNames[key] ?? key,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                isOn
                                    ? Colors.white
                                    : isDarkMode
                                    ? Colors.white
                                    : Colors.grey[500],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Switch(
                          value: isOn,
                          onChanged: (value) => _toggleDoor(key, isOn),
                          activeColor: Colors.white,
                          activeTrackColor:
                              isDarkMode
                                  ? const Color.fromARGB(255, 80, 97, 81)
                                  : Colors.greenAccent,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade500,
                          trackOutlineColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
