import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smarthome/LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        _showMessage(
          "Registration successful! Check your email for verification.",
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      _showMessage("Registration failed: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 20, 20, 20)
                : const Color.fromARGB(255, 104, 173, 230),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 20),
              ElevatedButton(
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
                onPressed: _register,
                child: Text(
                  "Register",
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
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text(
                  "Already have an account? Login",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
