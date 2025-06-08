import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TemperatureCard2 extends StatefulWidget {
  const TemperatureCard2({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TemperatureCard2State();
  }
}

class _TemperatureCard2State extends State<TemperatureCard2> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  double? _temperature;
  late StreamSubscription<DatabaseEvent> _temperatureSubscription;

  @override
  void initState() {
    super.initState();
    _fetchTemperature();
  }

  void _fetchTemperature() {
    _temperatureSubscription = _database
        .child("/SmartHome/monitoring/temperature2")
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          if (data != null && mounted) {
            setState(() {
              _temperature = double.tryParse(data.toString());
            });
          }
        });
  }

  @override
  void dispose() {
    _temperatureSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color.fromARGB(255, 104, 43, 43)
                : const Color.fromARGB(255, 207, 92, 92),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.thermostat, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            "Living Room",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _temperature != null
                ? "${_temperature!.toStringAsFixed(1)}°C"
                : "Loading...",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
