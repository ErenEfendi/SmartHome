import 'package:flutter/material.dart';
import 'package:smarthome/GasCard.dart';
import 'package:smarthome/HumidityCard.dart';
import 'package:smarthome/HumidityCard2.dart';
import 'package:smarthome/HumidityCard3.dart';
import 'package:smarthome/TemperatureCard.dart';
import 'package:smarthome/TemperatureCard2.dart';
import 'package:smarthome/TemperatureCard3.dart';

class SurveillanceScreen extends StatefulWidget {
  const SurveillanceScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SurveillanceScreenState();
  }
}

class _SurveillanceScreenState extends State<SurveillanceScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? null
                  : const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 104, 173, 230),
                      Color.fromARGB(255, 224, 232, 240),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.9,
              shrinkWrap: true,
              children: const [
                TemperatureCard(),
                TemperatureCard2(),
                TemperatureCard3(),
                GasCard(),
                HumidityCard(),
                HumidityCard2(),
                HumidityCard3(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
