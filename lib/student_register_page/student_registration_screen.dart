import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management_system/consts/constant_color.dart';

import '../helpers/password_visibility_provider.dart';
import 'student_model.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _registerStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final student = Student(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Create user in Firebase and get the user ID
        String userId =
            await student.createUser(student.email, student.password);

        // Save student data to Firestore with the user ID
        student.id = userId; // Set the ID to the student object
        await student.saveToFirestore();

        // If successful, navigate and show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!")),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/addProfilePicture',
          (route) => false,
        );

        _formKey.currentState?.reset();
      } catch (e) {
        // Handle errors (e.g., user already exists)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordVisibilityProvider(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kBackGroundColor,
          appBar: AppBar(
            backgroundColor: kBackGroundColor,
            title: const Text("Register as a Student"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                      validator: (value) => value == null || value.isEmpty
                          ? "Name is required"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Email field
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
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field with visibility toggle
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
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1.0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) =>
                              value != null && value.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    Consumer<PasswordVisibilityProvider>(
                      builder: (context, visibilityProvider, child) {
                        return TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !visibilityProvider.isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
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
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1),
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
                              return "Confirm password is required";
                            } else if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Register button
                    InkWell(
                      onTap: _registerStudent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: const Center(
                          child: Text(
                            "Register",
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
        ),
      ),
    );
  }
}
