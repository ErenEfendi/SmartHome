import 'package:flutter/material.dart';
import 'package:smarthome/AppDrawer.dart';
import 'package:smarthome/DevicesScreen.dart';
import 'package:smarthome/SurveillanceScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool showDevices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          showDevices ? "Devices" : "Surveillance",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A1A)
                : const Color.fromARGB(255, 38, 90, 133),
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
        ),
      ),
      drawer: AppDrawer(
        onDevicesSelected: () {
          setState(() => showDevices = true);
          Navigator.pop(context);
        },
        onSurveillanceSelected: () {
          setState(() => showDevices = false);
          Navigator.pop(context);
        },
      ),
      body: showDevices ? const DevicesScreen() : const SurveillanceScreen(),
    );
  }
}
