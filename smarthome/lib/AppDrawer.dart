import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/LoginPage.dart';
import 'package:smarthome/main.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onDevicesSelected;
  final VoidCallback onSurveillanceSelected;

  const AppDrawer({
    super.key,
    required this.onDevicesSelected,
    required this.onSurveillanceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDarkMode
            ? const Color(0xFF121212)
            : const Color.fromARGB(255, 38, 90, 133);
    final headerColor =
        isDarkMode
            ? const Color(0xFF1F1F1F)
            : const Color.fromARGB(255, 24, 59, 88);
    final textColor = Colors.white;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: headerColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Smart Home",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: textColor.withOpacity(0.3), thickness: 1),
              ],
            ),
          ),
          _buildDrawerItem(
            Icons.devices,
            "Devices",
            onDevicesSelected,
            textColor,
          ),
          _buildDrawerItem(
            Icons.videocam,
            "Surveillance",
            onSurveillanceSelected,
            textColor,
          ),
          const Spacer(),
          SwitchListTile(
            title: Text("Dark Mode", style: TextStyle(color: textColor)),
            value: themeNotifier.value == ThemeMode.dark,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              await prefs.setString('theme_mode', val ? 'dark' : 'light');
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.grey,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade500,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Divider(color: textColor.withOpacity(0.3)),

          _buildDrawerItem(Icons.logout, "Logout", () async {
            const storage = FlutterSecureStorage();
            await storage.delete(key: 'email');
            await storage.delete(key: 'password');
            await storage.delete(key: 'login_timestamp');
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }, textColor),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    Color textColor,
  ) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
