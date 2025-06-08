import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class ACScreen extends StatefulWidget {
  const ACScreen({super.key});

  @override
  State<ACScreen> createState() {
    return _ACScreenState();
  }
}

class _ACScreenState extends State<ACScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref(
    "SmartHome/remoteControl/ac",
  );
  Map<String, dynamic> _ACs = {};

  @override
  void initState() {
    super.initState();
    _fetchACs();
  }

  void _fetchACs() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _ACs = Map<String, dynamic>.from(event.snapshot.value as Map);
          print("Fetched ACs: $_ACs");
        });
      }
    });
  }

  void _toggleAC(String ACKey, bool currentState) {
    _database
        .child(ACKey)
        .update({"isOn": !currentState})
        .then((_) {
          print("AC state toggled successfully!");
          setState(() {
            _ACs[ACKey]['isOn'] = !currentState;
          });
        })
        .catchError((error) {
          print("Failed to toggle AC state: $error");
        });
  }

  void _showTemperatureDialog(
    BuildContext context,
    String ACKey,
    int temperature,
    bool isOn,
  ) {
    double currentTemperature = temperature.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      Theme.of(context).brightness == Brightness.dark
                          ? null
                          : const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 12, 131, 228),
                              Color.fromARGB(255, 136, 188, 240),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1F1F1F)
                          : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ACKey.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Adjust brightness level",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: SleekCircularSlider(
                        min: 16,
                        max: 35,
                        initialValue: currentTemperature,
                        appearance: CircularSliderAppearance(
                          size: 200,
                          customWidths: CustomSliderWidths(
                            progressBarWidth: 22,
                            trackWidth: 22,
                            shadowWidth: 25,
                          ),
                          customColors: CustomSliderColors(
                            progressBarColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 102, 102, 102)
                                    : const Color.fromARGB(255, 2, 37, 66),
                            trackColor: Colors.grey.shade300,
                            dotColor: Colors.white,
                          ),
                          infoProperties: InfoProperties(
                            mainLabelStyle: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            modifier: (double tempValue) {
                              return ' ${tempValue.toInt()}°';
                            },
                          ),
                        ),
                        onChange: (double tempValue) {
                          setDialogState(() {
                            currentTemperature = tempValue;
                          });
                        },
                        onChangeEnd: (double tempValue) {
                          _database.child(ACKey).update({
                            "tempValue": tempValue.toInt(),
                          });
                          setState(() {
                            _ACs[ACKey]['tempValue'] = tempValue.toInt();
                          });
                        },
                        innerWidget: (double tempValue) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ' ${tempValue.toInt()}°',
                                  style: TextStyle(
                                    fontSize: 65,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 3.14159,
                                  child: Icon(
                                    Icons.ac_unit,
                                    color:
                                        isOn
                                            ? Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color.fromARGB(
                                                  255,
                                                  98,
                                                  241,
                                                  102,
                                                )
                                                : const Color.fromARGB(
                                                  255,
                                                  12,
                                                  241,
                                                  19,
                                                )
                                            : Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("ACs Control"),
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
            _ACs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ACs.keys.length,
                  itemBuilder: (context, index) {
                    List<String> sortedKeys =
                        _ACs.keys.toList()..sort((a, b) => a.compareTo(b));

                    String key = sortedKeys[index];
                    int temperature = _ACs[key]['tempValue'] ?? 24;
                    bool isOn = _ACs[key]['isOn'] ?? false;

                    return Card(
                      color:
                          isDarkMode
                              ? Colors.grey.shade800
                              : const Color.fromARGB(255, 2, 37, 66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          ListTile(
                            title: Text(
                              key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Temperature: $temperature\u00B0C",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap:
                                () => _showTemperatureDialog(
                                  context,
                                  key,
                                  temperature,
                                  isOn,
                                ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: IconButton(
                              icon: Icon(
                                isOn ? Icons.ac_unit : Icons.ac_unit_outlined,
                                color: isOn ? Colors.green : Colors.grey[500],
                                size: 30,
                              ),
                              onPressed: () => _toggleAC(key, isOn),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
