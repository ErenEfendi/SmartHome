import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class LightsScreen extends StatefulWidget {
  const LightsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LightsScreenState();
  }
}

class _LightsScreenState extends State<LightsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref(
    "SmartHome/lights",
  );
  Map<String, dynamic> _lights = {};

  @override
  void initState() {
    super.initState();
    _fetchLights();
  }

  void _fetchLights() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _lights = Map<String, dynamic>.from(event.snapshot.value as Map);
        });
      }
    });
  }

  void _toggleLight(String lightKey, bool isOn) {
    int newValue = isOn ? 100 : 0;
    _database.child(lightKey).update({"value": newValue});
  }

  void _showBrightnessDialog(
    BuildContext context,
    String lightKey,
    int brightness,
    bool isOn,
  ) {
    double currentBrightness = brightness.toDouble();

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
                      lightKey.toUpperCase(),
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
                        min: 0,
                        max: 100,
                        initialValue: currentBrightness,
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
                            modifier: (double value) {
                              return ' ${value.toInt()}%';
                            },
                          ),
                        ),
                        onChange: (double value) {
                          setDialogState(() {
                            currentBrightness = value;
                          });
                        },
                        onChangeEnd: (double value) {
                          _database.child(lightKey).update({
                            "value": value.toInt(),
                          });
                          setState(() {
                            _lights[lightKey]['value'] = value.toInt();
                          });
                        },
                        innerWidget: (double value) {
                          bool isOn = value > 0;
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ' ${value.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 65,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Transform.rotate(
                                  angle: 3.14159,
                                  child: Icon(
                                    Icons.wb_incandescent,
                                    color:
                                        isOn
                                            ? Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color.fromARGB(
                                                  255,
                                                  240,
                                                  225,
                                                  91,
                                                )
                                                : Colors.yellow
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
        title: const Text("Lights Control"),
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
            _lights.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _lights.keys.length,
                  itemBuilder: (context, index) {
                    //  Sort keys before displaying
                    List<String> sortedKeys =
                        _lights.keys.toList()..sort((a, b) => a.compareTo(b));

                    String key = sortedKeys[index]; // Use sorted key list
                    int brightness = _lights[key]['value'] ?? 0;
                    bool isOn = brightness > 0;

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
                              key,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Brightness: $brightness%",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap:
                                () => _showBrightnessDialog(
                                  context,
                                  key,
                                  brightness,
                                  isOn,
                                ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: IconButton(
                              icon: Icon(
                                isOn
                                    ? Icons.lightbulb
                                    : Icons.lightbulb_outline,
                                color: isOn ? Colors.yellow : Colors.grey[500],
                                size: 30,
                              ),
                              onPressed: () => _toggleLight(key, !isOn),
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
