import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HumidityCard2 extends StatefulWidget {
  const HumidityCard2({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HumidityCard2State();
  }
}

class _HumidityCard2State extends State<HumidityCard2> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  double? _humidityLevel;
  late StreamSubscription<DatabaseEvent> _humiditySubscription;

  @override
  void initState() {
    super.initState();
    _fetchHumidityLevel();
  }

  Future<void> _fetchHumidityLevel() async {
    _humiditySubscription = _database
        .child("/SmartHome/monitoring/humidityLevel2")
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          if (data != null && mounted) {
            setState(() {
              _humidityLevel = double.tryParse(data.toString());
            });
          }
        });
  }

  @override
  void dispose() {
    _humiditySubscription.cancel();
    debugPrint("HumidityCard disposed and listener removed.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color.fromARGB(255, 29, 63, 77)
                : const Color.fromARGB(255, 10, 128, 201),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.cloudRain, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              "Living Room",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Humidity",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _humidityLevel != null
                  ? "${_humidityLevel!.toStringAsFixed(1)} %"
                  : "Loading...",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
