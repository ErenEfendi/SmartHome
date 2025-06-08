import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:smarthome/HomePage.dart';
import 'package:smarthome/LoginPage.dart';
import 'package:smarthome/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
bool isAlertDialogVisible = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
}

Future<void> initApp() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      themeNotifier.value = ThemeMode.light;
    }

    if (Platform.isAndroid) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      await _getFCMToken();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    runApp(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, mode, __) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.all(Colors.white),
                trackColor: WidgetStateProperty.all(Colors.grey),
              ),
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Colors.deepPurple,
              colorScheme: const ColorScheme.light().copyWith(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                secondary: Colors.deepPurpleAccent,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 104, 173, 230),
                foregroundColor: Colors.white,
              ),
              textTheme: const TextTheme(
                titleLarge: TextStyle(color: Colors.black),
                titleMedium: TextStyle(color: Colors.black87),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF1F1F1F),
              primaryColor: Colors.deepPurple,
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.all(Colors.white),
                trackColor: WidgetStateProperty.all(Colors.grey),
              ),
              colorScheme: const ColorScheme.dark().copyWith(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                secondary: Colors.deepPurpleAccent,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
              ),
              textTheme: const TextTheme(
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white70),
              ),
            ),
            themeMode: mode,
            home: const LoginPage(),
          );
        },
      ),
    );

    _setupForegroundNotificationHandler();
  } catch (e) {
    debugPrint("❌ initApp error: $e");
  }
}

void _setupForegroundNotificationHandler() {
  final player = AudioPlayer();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];

    debugPrint("Foreground notification received: $title - $body");

    player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('sounds/alarm.mp3'));

    if ((Platform.isAndroid || Platform.isIOS) && !kIsWeb) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(pattern: [0, 400, 200, 400]);
        }
      } catch (e) {
        debugPrint("Titreşim hatası: $e");
      }
    }

    if (navigatorKey.currentContext != null && !isAlertDialogVisible) {
      isAlertDialogVisible = true;

      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 241, 32, 32),
                          Color.fromARGB(255, 252, 74, 74),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 26),
                        Text(
                          title ?? "Gas Alert",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          body ?? "A notification has been received.",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              player.stop();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "OK",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Transform.scale(
                        scale: 2.2,
                        child: Lottie.asset(
                          'assets/animations/warning_animation.json',
                          repeat: true,
                          animate: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ).then((_) {
        isAlertDialogVisible = false;
        player.stop();
      });
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔔 Background message received: ${message.messageId}");
}

Future<void> _getFCMToken() async {
  if (!Platform.isAndroid) return;

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      debugPrint("🔥 FCM Token: $token");
      await messaging.subscribeToTopic("gasAlert");
    } else {
      debugPrint("❌ Notification permission denied");
    }
  } catch (e) {
    debugPrint("❌ Error getting FCM token: $e");
  }
}
