import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/constant_color.dart';
import '../helpers/error_provider.dart';
import '../helpers/password_visibility_provider.dart';
import 'login_logic.dart';

class LoginScreen extends StatefulWidget {
  final String message;

  const LoginScreen({super.key, required this.message});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginLogic _loginLogic = LoginLogic();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    final errorProvider = Provider.of<ErrorProvider>(context, listen: false);

    _loginLogic.login(
      email: _emailController.text,
      password: _passwordController.text,
      errorProvider: errorProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => ErrorProvider()),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kBackGroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                Consumer<ErrorProvider>(
                  builder: (context, errorProvider, child) {
                    return TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        errorText: errorProvider.emailError,
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
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer2<PasswordVisibilityProvider, ErrorProvider>(
                  builder: (context, visibilityProvider, errorProvider, child) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: !visibilityProvider.isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        errorText: errorProvider.passwordError,
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
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => _handleLogin(context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
