import 'package:flutter/material.dart';
import 'package:smarthome/ACScreen.dart';
import 'package:smarthome/DevicesTile.dart';
import 'package:smarthome/DoorsScreen.dart';
import 'package:smarthome/LightsScreen.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        color: isDarkMode ? Colors.grey[900] : null,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          DeviceTile(
            name: "Air Conditioner",
            icon: Icons.ac_unit,
            color:
                isDarkMode
                    ? const Color.fromARGB(255, 43, 110, 95)
                    : Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ACScreen()),
              );
            },
          ),
          DeviceTile(
            name: "Lights",
            icon: Icons.lightbulb,
            color:
                isDarkMode
                    ? const Color.fromARGB(255, 196, 144, 68)
                    : Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LightsScreen()),
              );
            },
          ),
          DeviceTile(
            name: "Doors",
            icon: Icons.door_front_door,
            color:
                isDarkMode
                    ? const Color.fromARGB(255, 94, 79, 74)
                    : Colors.brown,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoorsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
