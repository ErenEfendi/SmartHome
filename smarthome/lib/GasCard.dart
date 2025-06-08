import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GasCard extends StatefulWidget {
  const GasCard({super.key});

  @override
  State<GasCard> createState() {
    return _GasCardState();
  }
}

class _GasCardState extends State<GasCard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  double? _gaslevel;
  late StreamSubscription<DatabaseEvent> _gasSubscription;
  bool _isWarning = false;
  Color _currentColor = Colors.green;
  Timer? _warningTimer;
  Color _currentTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    //_initializeFirebaseMessaging();
    _fetchGasLevel();
  }

  // void _initializeFirebaseMessaging() {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   messaging.requestPermission(alert: true, badge: true, sound: true);

  //   messaging
  //       .subscribeToTopic("gasAlert")
  //       .then((_) {
  //         print("Successfully subscribed to gasAlert topic");
  //       })
  //       .catchError((e) {
  //         print("Failed to subscribe to gasAlert topic: $e");
  //       });

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print(
  //       "Foreground notification received: ${message.notification?.title} - ${message.notification?.body}",
  //     );
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print("App opened from notification: ${message.notification?.title}");
  //   });

  //   messaging.getToken().then((String? token) {
  //     print("FCM Token: $token");
  //   });
  // }

  Future<String> getAccessToken() async {
    try {
      // Load the service account JSON from assets
      final serviceAccountJson = await rootBundle.loadString(
        'assets/accessToken.json',
      );
      final serviceAccount = json.decode(serviceAccountJson);

      // Create the ServiceAccountCredentials object from the JSON data
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        serviceAccount,
      );

      // Define the required scopes for Firebase Messaging
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Create an authenticated client
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      // Extract the access token from the credentials
      final accessToken = client.credentials.accessToken.data;
      print("✅ Access Token: $accessToken");
      return accessToken;
    } catch (e) {
      print("❌ Error generating access token: $e");
      throw Exception("Error generating access token");
    }
  }

  // Future<void> _sendNotification(String title, String message) async {
  //   try {
  //     final String accessToken = await getAccessToken();
  //     const String fcmUrl =
  //         'https://fcm.googleapis.com/v1/projects/capstone-bau-2025/messages:send';

  //     final Map<String, dynamic> data = {
  //       "message": {
  //         "topic": "gasAlert",
  //         "notification": {"title": title, "body": message},
  //         "android": {
  //           "priority": "HIGH",
  //           "notification": {
  //             "sound": "default",
  //             "channel_id": "high_importance_channel",
  //           },
  //         },
  //         "apns": {
  //           "headers": {"apns-priority": "10"},
  //           "payload": {
  //             "aps": {
  //               "alert": {"title": title, "body": message},
  //               "sound": "default",
  //             },
  //           },
  //         },
  //         "data": {
  //           "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //           "status": "done",
  //           "gas_level": _gaslevel.toString(),
  //         },
  //       },
  //     };

  //     final response = await http.post(
  //       Uri.parse(fcmUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       body: jsonEncode(data),
  //     );

  //     if (response.statusCode == 200) {
  //       print("✅ Notification sent successfully.");
  //     } else {
  //       print("❌ Failed to send notification: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("❌ Error sending notification: $e");
  //   }
  // }

  void _fetchGasLevel() {
    _gasSubscription = _database
        .child("/SmartHome/monitoring/gasLevel")
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          if (data != null && mounted) {
            setState(() {
              _gaslevel = double.tryParse(data.toString());
            });
            if (_gaslevel != null && _gaslevel! > 840) {
              _startWarningEffect();
              // _sendNotification(
              //   "Gas Alert",
              //   "Gas level has exceeded safe limits!",
              // );
            } else {
              _stopWarningEffect();
            }
          }
        });
  }

  void _startWarningEffect() {
    if (_isWarning) return;
    _isWarning = true;

    _warningTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _currentColor =
            (_currentColor == Colors.red) ? Colors.white : Colors.red;
        _currentTextColor =
            (_currentColor == Colors.white) ? Colors.red : Colors.white;
      });
    });
  }

  void _stopWarningEffect() {
    if (!_isWarning) return;
    _isWarning = false;
    _warningTimer?.cancel();
    setState(() {
      _currentColor = Colors.green;
      _currentTextColor = Colors.white;
    });
  }

  @override
  void dispose() {
    _gasSubscription.cancel();
    debugPrint("🛑 GasCard disposed and listener removed.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:
            _isWarning
                ? _currentColor
                : (isDarkMode
                    ? const Color.fromARGB(255, 0, 109, 96)
                    : Colors.green),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Icon(
                  FontAwesomeIcons.cloud,
                  size: 40,
                  color: _currentTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Gas Detector",
                    style: TextStyle(
                      color: _currentTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _gaslevel != null
                        ? "${_gaslevel!.toStringAsFixed(1)} PPM"
                        : "Loading...",
                    style: TextStyle(
                      color: _currentTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
