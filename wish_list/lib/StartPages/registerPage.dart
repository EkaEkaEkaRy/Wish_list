import 'package:flutter/material.dart';
import 'package:wish_list/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void signUp() async {
    final name = nameController.text;
    final email = mailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Пароли не совпадают',
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 2, 105),
      ));
      return;
    }
    try {
      await authService.signUpWithEmailPassword(name, email, password);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Error: $e",
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
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
          title:
              const Text('Регистрация', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 0, 197, 191),
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 45.0,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Имя',
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
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Повторите пароль',
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
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
                          ),
                        ),
                        cursorHeight: 20,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 15.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 197, 191),
                    ),
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ],
              ),
            )));
  }
}
