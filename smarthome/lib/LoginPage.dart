import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smarthome/HomePage.dart';
import 'package:smarthome/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndLogin();
  }

  Future<void> _checkBiometricsAndLogin() async {
    final available =
        await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
    setState(() => _biometricAvailable = available);

    final biometricPref = await _storage.read(key: 'biometric_enabled');
    print("biometric_enabled: $biometricPref");

    if (biometricPref == 'true' && _biometricAvailable) {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      print("Biometric authenticated: $authenticated");

      if (authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return;
      }
    }

    final savedEmail = await _storage.read(key: 'email');
    final savedPassword = await _storage.read(key: 'password');
    final timestampStr = await _storage.read(key: 'login_timestamp');

    if (savedEmail != null && savedPassword != null && timestampStr != null) {
      final savedTime = DateTime.tryParse(timestampStr);
      final now = DateTime.now();

      if (savedTime != null && now.difference(savedTime).inDays <= 30) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });
      } else {
        await _storage.deleteAll();
      }
    }
  }

  Future<void> _loginUser(String email, String password) async {
    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final now = DateTime.now().toIso8601String();
      if (_rememberMe) {
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'password', value: password);
        await _storage.write(key: 'login_timestamp', value: now);
      } else {
        await _storage.deleteAll();
      }

      if (_biometricAvailable) {
        await _storage.write(key: 'biometric_enabled', value: 'true');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ ${e.message}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 20, 20, 20)
                : const Color.fromARGB(255, 104, 173, 230),
        title: const Text("Login"),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Theme.of(context).colorScheme.primary,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Theme.of(context).colorScheme.primary,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Theme.of(context).colorScheme.primary,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
              ),
              obscureText: true,
            ),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (val) => setState(() => _rememberMe = val!),
                  activeColor: isDarkMode ? Colors.white : Colors.deepPurple,
                  checkColor: isDarkMode ? Colors.black : Colors.white,
                  side: BorderSide(
                    color: isDarkMode ? Colors.white : primaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Text(
                  "Remember me for 30 days",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Theme.of(context).colorScheme.surface,
                    ),
                    side: WidgetStatePropertyAll<BorderSide>(
                      BorderSide(
                        color: isDarkMode ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ),
                  onPressed:
                      () => _loginUser(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      ),
                  child: Text(
                    "Login",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
              child: Text(
                "Don't have an account? Register",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final controller = TextEditingController();

                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          "Reset Password",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : Theme.of(context).colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: "Enter your email",
                            labelStyle: Theme.of(
                              context,
                            ).textTheme.titleMedium!.copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color.fromARGB(255, 255, 255, 255)
                                      : Theme.of(context).colorScheme.primary,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        )
                                        : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        )
                                        : Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              "Cancel",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium!.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        )
                                        : Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final email = controller.text.trim();
                              if (email.isEmpty) return;

                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "📧 Password reset email sent!",
                                    ),
                                  ),
                                );
                              } on FirebaseAuthException catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ Error: ${e.message}"),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Send",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium!.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        )
                                        : Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
              },
              child: Text(
                "Forgot Password ?",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
