import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../consts/constant_color.dart';
import '../helpers/password_visibility_provider.dart';
import 'login_logic.dart';

class LoginScreen extends StatefulWidget {
  final String message;
  final bool showRegister;

  const LoginScreen({
    super.key,
    required this.message,
    this.showRegister = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginLogic _loginLogic = LoginLogic();
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final box = Hive.box('loginBox');
    final savedEmail = box.get('email');
    final savedPassword = box.get('password');
    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      rememberMe = true;
    }
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (rememberMe) {
        final box = Hive.box('loginBox');
        box.put('email', email);
        box.put('password', password);
      } else {
        final box = Hive.box('loginBox');
        box.delete('email');
        box.delete('password');
      }

      _loginLogic.login(
        email: email,
        password: password,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kBackGroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      errorStyle: const TextStyle(color: Colors.white),
                      labelStyle: const TextStyle(color: Colors.black87),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<PasswordVisibilityProvider>(
                    builder: (context, visibilityProvider, child) {
                      return TextFormField(
                        controller: _passwordController,
                        obscureText: !visibilityProvider.isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          errorStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.black87),
                          suffixIcon: IconButton(
                            onPressed: visibilityProvider.toggleVisibility,
                            icon: Icon(
                              color: Colors.black,
                              visibilityProvider.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text("Remember Me"),
                    value: rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                  ),
                  InkWell(
                    onTap: _handleLogin,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      height: 50,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.showRegister)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/studentRegistrationScreen');
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
