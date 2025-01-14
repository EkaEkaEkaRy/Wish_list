import 'package:flutter/material.dart';
import 'package:wish_list/auth/auth_service.dart';
import 'package:wish_list/StartPages/registerPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void login() async {
    final email = mailController.text;
    final password = passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: $e",
              style: TextStyle(color: Colors.black, fontSize: 16.0)),
          backgroundColor: const Color.fromARGB(255, 252, 2, 105),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color.fromARGB(255, 220, 235, 235),
        appBar: AppBar(
          title: const Text('Вход', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 0, 197, 191),
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 200.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 45.0,
                      child: TextField(
                        controller: mailController,
                        decoration: InputDecoration(
                          labelText: 'Почта',
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 239, 218, 227),
                              fontSize: 15.0),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFFC0269),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 239, 218, 227),
                              width: 1.0,
                            ),
                          ),
                        ),
                        cursorHeight: 20,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 15.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 45.0,
                      child: TextField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 239, 218, 227),
                              fontSize: 15.0),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFFC0269),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 239, 218, 227),
                              width: 1.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.black, fontSize: 15.0),
                        cursorHeight: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 197, 191),
                    ),
                    child: const Text('Войти',
                        style: TextStyle(color: Colors.white, fontSize: 15.0)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage())),
                      child: Center(
                          child: Text('Нет аккаунта? Зарегиструйтесь',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 0, 0, 0)))))
                ],
              ),
            )));
  }
}
